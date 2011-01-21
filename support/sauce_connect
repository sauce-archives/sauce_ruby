#!/usr/bin/env python
# encoding: utf-8
from __future__ import with_statement

# TODO:
#   * Move to REST API v1
#   * windows: SSH link healthcheck (PuTTY session file hack?)
#   * Daemonizing
#     * issue: windows: no os.fork()
#     * issue: unix: null file descriptors causes Expect script to fail
#   * Renew tunnel lease (backend not implemented)
#   * Check tunnel machine ports are open (backend not implemented)

import os
import sys
import re
import optparse
import logging
import logging.handlers
import signal
import atexit
import httplib
import urllib2
import subprocess
import socket
import time
import platform
import tempfile
import string
from base64 import b64encode
from collections import defaultdict
from contextlib import closing
from functools import wraps

try:
    import json
except ImportError:
    import simplejson as json  # Python 2.5 dependency

NAME = "sauce_connect"
RELEASE = 25
DISPLAY_VERSION = "%s release %s" % (NAME, RELEASE)
PRODUCT_NAME = u"Sauce Connect"
VERSIONS_URL = "http://saucelabs.com/versions.json"

RETRY_PROVISION_MAX = 4
RETRY_BOOT_MAX = 4
RETRY_REST_WAIT = 5
RETRY_REST_MAX = 6
REST_POLL_WAIT = 3
RETRY_SSH_MAX = 4
HEALTH_CHECK_INTERVAL = 15
HEALTH_CHECK_FAIL = 5 * 60  # no good check after this amount of time == fail
LATENCY_LOG = 150  # log when making connections takes this many ms
LATENCY_WARNING = 350  # warn when making connections takes this many ms
SIGNALS_RECV_MAX = 4  # used with --allow-unclean-exit

is_windows = platform.system().lower() == "windows"
is_openbsd = platform.system().lower() == "openbsd"
logger = logging.getLogger(NAME)


class DeleteRequest(urllib2.Request):

    def get_method(self):
        return "DELETE"


class HTTPResponseError(Exception):

    def __init__(self, msg):
        self.msg = msg

    def __str__(self):
        return "HTTP server responded with '%s' (expected 'OK')" % self.msg


class TunnelMachineError(Exception):
    pass


class TunnelMachineProvisionError(TunnelMachineError):
    pass


class TunnelMachineBootError(TunnelMachineError):
    pass


class TunnelMachine(object):

    _host_search = re.compile("//([^/]+)").search

    def __init__(self, rest_url, user, password, domains, ssh_port, metadata=None):
        self.user = user
        self.password = password
        self.domains = set(domains)
        self.ssh_port = ssh_port
        self.metadata = metadata or dict()

        self.reverse_ssh = None
        self.is_shutdown = False
        self.base_url = "%(rest_url)s/%(user)s/tunnels" % locals()
        self.rest_host = self._host_search(rest_url).group(1)
        self.basic_auth_header = {"Authorization": "Basic %s"
                                  % b64encode("%s:%s" % (user, password))}

        self._set_urlopen(user, password)

        for attempt in xrange(1, RETRY_PROVISION_MAX):
            try:
                self._provision_tunnel()
                break
            except TunnelMachineProvisionError, e:
                logger.warning(e)
                if attempt == RETRY_PROVISION_MAX:
                    raise TunnelMachineError(
                        "!! Could not provision tunnel host. Please contact "
                        "help@saucelabs.com.")

    def _set_urlopen(self, user, password):
        # always send Basic Auth header (HTTPBasicAuthHandler was unreliable)
        opener = urllib2.build_opener()
        opener.addheaders = self.basic_auth_header.items()
        self.urlopen = opener.open

    # decorator
    def _retry_rest_api(f):
        @wraps(f)
        def wrapper(*args, **kwargs):
            previous_failed = False
            for attempt in xrange(1, RETRY_REST_MAX + 1):
                try:
                    result = f(*args, **kwargs)
                    if previous_failed:
                        logger.info("Connection succeeded")
                    return result
                except (HTTPResponseError,
                        urllib2.URLError, httplib.HTTPException,
                        socket.gaierror, socket.error), e:
                    logger.warning("Problem connecting to Sauce Labs REST API "
                                   "(%s)", str(e))
                    if attempt == RETRY_REST_MAX:
                        raise TunnelMachineError(
                            "Could not reach Sauce Labs REST API after %d "
                            "tries. Is your network down or firewalled?"
                            % attempt)
                    previous_failed = True
                    logger.debug("Retrying in %ds", RETRY_REST_WAIT)
                    time.sleep(RETRY_REST_WAIT)
                except Exception, e:
                    raise TunnelMachineError(
                        "An error occurred while contacting Sauce Labs REST "
                        "API (%s). Please contact help@saucelabs.com." % str(e))
        return wrapper

    @_retry_rest_api
    def _get_doc(self, url_or_req):
        with closing(self.urlopen(url_or_req)) as resp:
            if resp.msg != "OK":
                raise HTTPResponseError(resp.msg)
            return json.loads(resp.read())

    def _provision_tunnel(self):
        # Shutdown any tunnel using a requested domain
        kill_list = set()
        for doc in self._get_doc(self.base_url):
            if not doc.get('DomainNames'):
                continue
            if set(doc['DomainNames']) & self.domains:
                kill_list.add(doc['id'])
        if kill_list:
            logger.info(
                "Shutting down other tunnel hosts using requested domains")
            for tunnel_id in kill_list:
                for attempt in xrange(1, 4):  # try a few times, then bail
                    logger.debug(
                        "Shutting down old tunnel host: %s" % tunnel_id)
                    url = "%s/%s" % (self.base_url, tunnel_id)
                    doc = self._get_doc(DeleteRequest(url=url))
                    if not doc.get('ok'):
                        logger.warning("Old tunnel host failed to shutdown?")
                        continue
                    doc = self._get_doc(url)
                    while doc.get('Status') not in ["halting", "terminated"]:
                        logger.debug(
                            "Waiting for old tunnel host to start halting")
                        time.sleep(REST_POLL_WAIT)
                        doc = self._get_doc(url)
                    break

        # Request a tunnel machine
        headers = {"Content-Type": "application/json"}
        data = json.dumps(dict(DomainNames=list(self.domains),
                               Metadata=self.metadata,
                               SSHPort=self.ssh_port))
        req = urllib2.Request(url=self.base_url, headers=headers, data=data)
        doc = self._get_doc(req)
        if doc.get('error'):
            raise TunnelMachineProvisionError(doc['error'])
        for key in ['ok', 'id']:
            if not doc.get(key):
                raise TunnelMachineProvisionError(
                    "Document for provisioned tunnel host is missing the key "
                    "or value for '%s'" % key)
        self.id = doc['id']
        self.url = "%s/%s" % (self.base_url, self.id)
        logger.info("Tunnel host is provisioned (%s)" % self.id)

    def ready_wait(self):
        """Wait for the machine to reach the 'running' state."""
        previous_status = None
        while True:
            doc = self._get_doc(self.url)
            status = doc.get('Status')
            if status == "running":
                break
            if status in ["halting", "terminated"]:
                raise TunnelMachineBootError("Tunnel host was shutdown")
            if status != previous_status:
                logger.info("Tunnel host is %s .." % status)
            previous_status = status
            time.sleep(REST_POLL_WAIT)
        self.host = doc['Host']
        logger.info("Tunnel host is running at %s" % self.host)

    def shutdown(self):
        if self.is_shutdown:
            return

        if self.reverse_ssh:
            self.reverse_ssh.stop()

        logger.info("Shutting down tunnel host (please wait)")
        logger.debug("Tunnel host ID: %s" % self.id)

        try:
            doc = self._get_doc(DeleteRequest(url=self.url))
        except TunnelMachineError, e:
            logger.warning("Unable to shut down tunnel host")
            logger.debug("Shut down failed because: %s", str(e))
            self.is_shutdown = True  # fuhgeddaboudit
            return
        assert doc.get('ok')

        previous_status = None
        while True:
            doc = self._get_doc(self.url)
            status = doc.get('Status')
            if status == "terminated":
                break
            if status != previous_status:
                logger.info("Tunnel host is %s .." % status)
            previous_status = status
            time.sleep(REST_POLL_WAIT)
        logger.info("Tunnel host is shutdown")
        self.is_shutdown = True

    # Make us usable with contextlib.closing
    close = shutdown

    def check_running(self):
        doc = self._get_doc(self.url)
        if doc.get('Status') == "running":
            return
        raise TunnelMachineError(
            "The tunnel host is no longer running. It may have been shutdown "
            "via the website or by another Sauce Connect script requesting these "
            "domains: %s" % list(self.domains))


class HealthCheckFail(Exception):
    pass


class HealthChecker(object):

    latency_log = LATENCY_LOG

    def __init__(self, host, ports, fail_msg=None):
        """fail_msg can include '%(host)s' and '%(port)d'"""
        self.host = host
        self.fail_msg = fail_msg
        if not self.fail_msg:
            self.fail_msg = ("!! Your tests will fail while your network "
                             "can not get to %(host)s:%(port)d.")
        self.ports = frozenset(int(p) for p in ports)
        self.last_tcp_connect = defaultdict(time.time)
        self.last_tcp_ping = defaultdict(lambda: None)

    def _tcp_ping(self, port):
        with closing(socket.socket()) as sock:
            start_time = time.time()
            try:
                sock.connect((self.host, port))
                return int(1000 * (time.time() - start_time))
            except (socket.gaierror, socket.error), e:
                logger.warning("Could not connect to %s:%s (%s)",
                               self.host, port, str(e))

    def check(self):
        now = time.time()
        for port in self.ports:
            ping_time = self._tcp_ping(port)
            if ping_time is not None:
                # TCP connection succeeded
                self.last_tcp_connect[port] = now
                result = (self.host, port, ping_time)

                if ping_time >= self.latency_log:
                    logger.debug("Connected to %s:%s in in %dms" % result)

                if ping_time >= LATENCY_WARNING:
                    if (self.last_tcp_ping[port] is None
                        or self.last_tcp_ping[port] < LATENCY_WARNING):
                        logger.warn("High latency to %s:%s (took %dms to "
                                    "connect); tests may run slowly" % result)

                if (ping_time < (LATENCY_WARNING / 2)
                    and self.last_tcp_ping[port]
                    and self.last_tcp_ping[port] >= LATENCY_WARNING):
                    logger.info("Latency to %s:%s has lowered (took %dms to "
                                "connect)" % result)

                if self.last_tcp_ping[port] is None:
                    logger.info("Succesfully connected to %s:%s in %dms" % result)

                self.last_tcp_ping[port] = ping_time
                continue

            # TCP connection failed
            self.last_tcp_ping[port] = ping_time
            logger.warning(self.fail_msg % dict(host=self.host, port=port))
            if now - self.last_tcp_connect[port] > HEALTH_CHECK_FAIL:
                raise HealthCheckFail(
                    "Could not connect to %s:%s for over %s seconds"
                    % (self.host, port, HEALTH_CHECK_FAIL))


class ReverseSSHError(Exception):
    pass


class ReverseSSH(object):

    def __init__(self, tunnel, host, ports, tunnel_ports, ssh_port,
                 use_ssh_config=False, debug=False):
        self.tunnel = tunnel
        self.host = host
        self.ports = ports
        self.tunnel_ports = tunnel_ports
        self.use_ssh_config = use_ssh_config
        self.ssh_port = ssh_port
        self.debug = debug

        self.proc = None
        self.readyfile = None
        self.stdout_f = None
        self.stderr_f = None

        if self.debug:
            logger.debug("ReverseSSH debugging is on.")

    def _check_dot_ssh_files(self):
        if not os.environ.get('HOME'):
            logger.debug("No HOME env, skipping .ssh file checks")
            return

        ssh_config_file = os.path.join(os.environ['HOME'], ".ssh", "config")
        if os.path.exists(ssh_config_file):
            logger.debug("Found %s" % ssh_config_file)
            if self.use_ssh_config:
                logger.warn("Using local SSH config")

    @property
    def _dash_Rs(self):
        dash_Rs = ""
        for port, tunnel_port in zip(self.ports, self.tunnel_ports):
            dash_Rs += "-R 0.0.0.0:%s:%s:%s " % (tunnel_port, self.host, port)
        return dash_Rs

    def get_plink_command(self):
        """Return the Windows SSH command."""
        verbosity = "-v" if self.debug else ""
        return ("plink\plink %s -P %s -l %s -pw %s -N %s %s"
                % (verbosity, self.ssh_port, self.tunnel.user, self.tunnel.password,
                   self._dash_Rs, self.tunnel.host))

    def get_expect_script(self):
        """Return the Unix SSH command."""
        wait = "wait"
        if is_openbsd:  # using 'wait;' hangs the script on OpenBSD
            wait = "wait -nowait;sleep 1"  # hack

        verbosity = "-v" if self.debug else "-q"
        config_file = "" if self.use_ssh_config else "-F /dev/null"
        host_ip = socket.gethostbyname(self.tunnel.host)
        script = (
            "spawn ssh %s %s -p %s -l %s -o ServerAliveInterval=%s -o StrictHostKeyChecking=no -o UserKnownHostsFile=/dev/null -N %s %s;"
                % (verbosity, config_file, self.ssh_port, self.tunnel.user,
                   HEALTH_CHECK_INTERVAL, self._dash_Rs, self.tunnel.host) +
            "expect *password:;send -- %s\\r;" % self.tunnel.password +
            "expect -timeout -1 timeout")
        return script

    def _start_reverse_ssh(self, readyfile=None):
        self._check_dot_ssh_files()
        logger.info("Starting SSH process ..")
        if is_windows:
            cmd = "echo 'n' | %s" % self.get_plink_command()
        else:
            cmd = 'exec expect -c "%s"' % self.get_expect_script()

        # start ssh process
        if self.debug:
            self.stdout_f = tempfile.TemporaryFile()
        else:
            self.stdout_f = open(os.devnull)
        self.stderr_f = tempfile.TemporaryFile()
        self.proc = subprocess.Popen(
            cmd, shell=True, stdout=self.stdout_f, stderr=self.stderr_f)
        self.tunnel.reverse_ssh = self  # BUG: circular ref
        time.sleep(3)  # HACK: some startup time

        # ssh process is running
        announced_running = False

        # setup recurring healthchecks
        forwarded_health = HealthChecker(self.host, self.ports)
        tunnel_health = HealthChecker(host=self.tunnel.host, ports=[self.ssh_port],
            fail_msg="!! Your tests may fail because your network can not get "
                     "to the tunnel host (%s:%d)." % (self.tunnel.host, self.ssh_port))

        start_time = int(time.time())
        while self.proc.poll() is None:
            now = int(time.time())
            if not announced_running:
                # guarantee we health check on first iteration
                now = start_time
            if (now - start_time) % HEALTH_CHECK_INTERVAL == 0:
                self.tunnel.check_running()
                try:
                    forwarded_health.check()
                    tunnel_health.check()
                except HealthCheckFail, e:
                    raise ReverseSSHError(e)
            if not announced_running:
                logger.info("SSH is running. You may start your tests.")
                if readyfile:
                    self.readyfile = readyfile
                    f = open(readyfile, 'w')
                    f.close()
                announced_running = True
            time.sleep(1)

        # ssh process has exited
        self._log_output()
        if self.proc.returncode != 0:
            logger.warning("SSH process exited with error code %d",
                           self.proc.returncode)
        else:
            logger.info("SSH process exited (maybe due to network problems)")

        return self.proc.returncode

    def _log_output(self):
        if not self.stderr_f.closed:
            self.stderr_f.seek(0)
            reverse_ssh_stderr = self.stderr_f.read().strip()
            self.stderr_f.close()

            if reverse_ssh_stderr:
                logger.debug("ReverseSSH stderr was:\n%s\n" % reverse_ssh_stderr)

        if not self.stdout_f.closed:
            self.stdout_f.seek(0)
            reverse_ssh_stdout = self.stdout_f.read().strip()
            self.stdout_f.close()

            if self.debug:
                logger.debug("ReverseSSH stdout was:\n%s\n" % reverse_ssh_stdout)

    def _rm_readyfile(self):
        if self.readyfile and os.path.exists(self.readyfile):
            try:
                os.remove(self.readyfile)
            except OSError, e:
                logger.error("Couldn't remove %s: %s", self.readyfile, str(e))

    def stop(self):
        self._rm_readyfile()
        if not self.proc or self.proc.poll() is not None:  # not running, done
            return

        if not is_windows:  # windows no have kill()
            try:
                os.kill(self.proc.pid, signal.SIGHUP)
                logger.debug("Sent SIGHUP to PID %d", self.proc.pid)
            except OSError:
                pass
        self._log_output()

    def run(self, readyfile=None):
        clean_exit = False
        for attempt in xrange(1, RETRY_SSH_MAX + 1):
            # returncode 0 will happen due to ServerAlive checks failing.
            # this may result in a listening port forwarding nowhere, so
            # don't bother restarting the SSH connection.
            # TODO: revisit if server uses OpenSSH instead of Twisted SSH
            if self._start_reverse_ssh(readyfile) == 0:
                clean_exit = True
                break
            if attempt < RETRY_SSH_MAX:
                logger.debug("Will restart SSH in 3 seconds")
                time.sleep(3)  # wait a bit for old connections to close
        self._rm_readyfile()
        if not clean_exit:
            raise ReverseSSHError(
                "SSH process errored %d times (bad network?)" % attempt)


def peace_out(tunnel=None, returncode=0, atexit=False):
    """Shutdown the tunnel and raise SystemExit."""
    if tunnel:
        tunnel.shutdown()
    if not atexit:
        logger.info("\ Exiting /")
        raise SystemExit(returncode)
    else:
        logger.debug("-- fin --")


def setup_signal_handler(tunnel, options):
    signal_count = defaultdict(int)
    signal_name = {}

    def sig_handler(signum, frame):
        if options.allow_unclean_exit:
            signal_count[signum] += 1
            if signal_count[signum] > SIGNALS_RECV_MAX:
                logger.info(
                    "Received %s too many times (%d). Making unclean "
                    "exit now!", signal_name[signum], signal_count[signum])
                raise SystemExit(1)
        logger.info("Received signal %s", signal_name[signum])
        peace_out(tunnel)  # exits

    # TODO: ?? remove SIGTERM when we implement tunnel leases
    if is_windows:
        supported_signals = ["SIGABRT", "SIGBREAK", "SIGINT", "SIGTERM"]
    else:
        supported_signals = ["SIGHUP", "SIGINT", "SIGQUIT", "SIGTERM"]
    for sig in supported_signals:
        signum = getattr(signal, sig)
        signal_name[signum] = sig
        signal.signal(signum, sig_handler)


def check_version():
    failed_msg = "Skipping version check"
    logger.debug("Checking version")
    try:
        with closing(urllib2.urlopen(VERSIONS_URL)) as resp:
            assert resp.msg == "OK", "Got HTTP response %s" % resp.msg
            version_doc = json.loads(resp.read())
    except (urllib2.URLError, AssertionError, ValueError), e:
        logger.debug("Could not check version: %s", str(e))
        logger.info(failed_msg)
        return
    try:
        version = version_doc[PRODUCT_NAME][u'version']
        download_url = version_doc[PRODUCT_NAME][u'download_url']
    except KeyError, e:
        logger.debug("Bad version doc, missing key: %s", str(e))
        logger.info(failed_msg)
        return

    try:
        latest = int(version.partition("-")[2].strip(string.ascii_letters))
    except (IndexError, ValueError), e:
        logger.debug("Couldn't parse release number: %s", str(e))
        logger.info(failed_msg)
        return
    if RELEASE < latest:
        msgs = ["** This version of %s is outdated." % PRODUCT_NAME,
                "** Please update with %s" % download_url]
        for update_msg in msgs:
            logger.warning(update_msg)
        for update_msg in msgs:
            sys.stderr.write("%s\n" % update_msg)
        time.sleep(15)


def setup_logging(logfile=None, quiet=False):
    logger.setLevel(logging.DEBUG)

    if not quiet:
        stdout = logging.StreamHandler(sys.stdout)
        stdout.setLevel(logging.INFO)
        stdout.setFormatter(logging.Formatter("%(asctime)s - %(message)s"))
        logger.addHandler(stdout)

    if logfile:
        if not quiet:
            print "* Debug messages will be sent to %s" % logfile
        fileout = logging.handlers.RotatingFileHandler(
            filename=logfile, maxBytes=128 * 1024, backupCount=8)
        fileout.setLevel(logging.DEBUG)
        fileout.setFormatter(logging.Formatter(
            "%(asctime)s - %(name)s:%(lineno)d - %(levelname)s - %(message)s"))
        logger.addHandler(fileout)


def check_domains(domains):
    """Display error and exit script if any requested domains are invalid."""

    for dom in domains:
        # no URLs
        if '/' in dom:
            sys.stderr.write(
                "Error: Domain contains illegal character '/' in it.\n")
            print "       Did you use a URL instead of just the domain?\n"
            print "Examples: -d example.com -d '*.example.com' -d another.site"
            print
            raise SystemExit(1)

        # no numerical addresses
        if all(map(lambda c: c.isdigit() or c == '.', dom)):
            sys.stderr.write("Error: Domain must be a hostname not an IP\n")
            print
            print "Examples: -d example.com -d '*.example.com' -d another.site"
            print
            raise SystemExit(1)

        # need a dot and 2 char TLD
        # NOTE: if this restriction is relaxed, still check for "localhost"
        if '.' not in dom or len(dom.rpartition('.')[2]) < 2:
            sys.stderr.write(
                "Error: Domain requires a TLD of 2 characters or more\n")
            print
            print "Example: -d example.tld -d '*.example.tld' -d another.tld"
            print
            raise SystemExit(1)

        # *.com will break uploading to S3
        if dom == "*.com":
            sys.stderr.write(
                "Error: Matching *.com will break videos and logs. Use a hostname.\n")
            print
            print "Example: -d example.com -d *.example.com"
            print
            raise SystemExit(1)


def get_options():
    usage = """
Usage: %(name)s -u <user> -k <api_key> -s <webserver> -d <domain> [options]

Examples:
  Have tests for example.com go to a staging server on your intranet:
    %(name)s -u user -k 123-abc -s staging.local -d example.com

  Have HTTP and HTTPS traffic for *.example.com go to the staging server:
    %(name)s -u user -k 123-abc -s staging.local -p 80 -p 443 \\
                 -d example.com -d *.example.com

  Have tests for example.com go to your local machine on port 5000:
    %(name)s -u user -k 123-abc -s 127.0.0.1 -t 80 -p 5000 -d example.com

Performance tip:
  It is highly recommended you run this script on the same machine as your
  test server (i.e., you would use "-s 127.0.0.1" or "-s localhost"). Using
  a remote server introduces higher latency (slower web requests) and is
  another failure point.
""" % dict(name=NAME)

    usage = usage.strip()
    logfile = "%s.log" % NAME

    op = optparse.OptionParser(usage=usage, version=DISPLAY_VERSION)
    op.add_option("-u", "--user", "--username",
                  help="Your Sauce Labs account name.")
    op.add_option("-k", "--api-key",
                  help="On your account at https://saucelabs.com/account")
    op.add_option("-s", "--host", default="localhost",
                  help="Host to forward requests to. [%default]")
    op.add_option("-p", "--port", metavar="PORT",
                  action="append", dest="ports", default=[],
                  help="Forward to this port on HOST. Can be specified "
                       "multiple times. [80]")
    op.add_option("-d", "--domain", action="append", dest="domains",
            help="Repeat for each domain you want to forward requests for. "
                 "Example: -d example.test -d '*.example.test'")
    op.add_option("-q", "--quiet", action="store_true", default=False,
                  help="Minimize standard output (see %s)" % logfile)

    og = optparse.OptionGroup(op, "Advanced options")
    og.add_option("-t", "--tunnel-port", metavar="TUNNEL_PORT",
        action="append", dest="tunnel_ports", default=[],
        help="The port your tests expect to hit when they run."
             " By default, we use the same ports as the HOST."
             " If you know for sure _all_ your tests use something like"
             " http://site.test:8080/ then set this 8080.")
    og.add_option("--logfile", default=logfile,
          help="Path of the logfile to write to. [%default]")
    og.add_option("--readyfile",
                  help="Path of the file to drop when the tunnel is ready "
                       "for tests to run. By default, no file is dropped.")
    og.add_option("--use-ssh-config", action="store_true", default=False,
                  help="Use the local SSH config. WARNING: Turning this on "
                       "may break the script!")
    og.add_option("--rest-url", default="https://saucelabs.com/rest",
                  help=optparse.SUPPRESS_HELP)
    og.add_option("--allow-unclean-exit", action="store_true", default=False,
                  help=optparse.SUPPRESS_HELP)
    og.add_option("--ssh-port", default=22, type="int",
                  help=optparse.SUPPRESS_HELP)
    op.add_option_group(og)

    og = optparse.OptionGroup(op, "Script debugging options")
    og.add_option("--debug-ssh", action="store_true", default=False,
                  help="Log SSH output.")
    og.add_option("--latency-log", type=int, default=LATENCY_LOG,
                  help="Threshold for logging latency (ms) [%default]")
    op.add_option_group(og)

    (options, args) = op.parse_args()

    # check ports are numbers
    try:
        map(int, options.ports)
        map(int, options.tunnel_ports)
    except ValueError:
        sys.stderr.write("Error: Ports must be integers\n\n")
        print "Help with options -t and -p:"
        print "  All ports must be integers. You used:"
        if options.ports:
            print "    -p", " -p ".join(options.ports)
        if options.tunnel_ports:
            print "    -t", " -t ".join(options.tunnel_ports)
        raise SystemExit(1)

    # default to 80 and default to matching host ports with tunnel ports
    if not options.ports and not options.tunnel_ports:
        options.ports = ["80"]
    if options.ports and not options.tunnel_ports:
        options.tunnel_ports = options.ports[:]

    if len(options.ports) != len(options.tunnel_ports):
        sys.stderr.write("Error: Options -t and -p need to be paired\n\n")
        print "Help with options -t and -p:"
        print "  When forwarding multiple ports, you must pair the tunnel port"
        print "  to forward with the host port to forward to."
        print ""
        print "Example option usage:"
        print "  To have your test's requests to 80 and 443 go to your test"
        print "  server on ports 5000 and 5001: -t 80 -p 5000 -t 443 -p 5001"
        raise SystemExit(1)

    # check for required options without defaults
    for opt in ["user", "api_key", "host", "domains"]:
        if not hasattr(options, opt) or not getattr(options, opt):
            sys.stderr.write("Error: Missing required argument(s)\n\n")
            op.print_help()
            raise SystemExit(1)

    check_domains(options.domains)
    return options


class MissingDependenciesError(Exception):

    deb_pkg = dict(ssh="openssh-client", expect="expect")

    def __init__(self, dependency, included=False, extra_msg=None):
        self.dependency = dependency
        self.included = included
        self.extra_msg = extra_msg

    def __str__(self):
        msg = ("%s\n\n" % self.extra_msg) if self.extra_msg else ""
        msg += "You are missing '%s'." % self.dependency
        if self.included:
            return (msg + " This should have come with the zip\n"
                    "you downloaded. If you need assistance, please "
                    "contact help@saucelabs.com.")

        msg += " Please install it or contact\nhelp@saucelabs.com for help."
        try:
            linux_distro = platform.linux_distribution
        except AttributeError:  # Python 2.5
            linux_distro = platform.dist
        if linux_distro()[0].lower() in ['ubuntu', 'debian']:
            if self.dependency in self.deb_pkg:
                msg += ("\n\nTo install: sudo aptitude install %s"
                        % self.deb_pkg[self.dependency])
        return msg


def check_dependencies():
    if is_windows:
        if not os.path.exists("plink\plink.exe"):
            raise MissingDependenciesError("plink\plink.exe", included=True)
        return

    def check(command):
        # on unix
        with tempfile.TemporaryFile() as output:
            try:
                subprocess.check_call(command, shell=True, stdout=output,
                                               stderr=subprocess.STDOUT)
            except subprocess.CalledProcessError:
                dependency = command.split(" ")[0]
                raise MissingDependenciesError(dependency)
            output.seek(0)
            return output.read().strip()

    version = {}
    version['expect'] = check("expect -v")

    version['ssh'] = check("ssh -V")
    if not version['ssh'].startswith("OpenSSH"):
        msg = "You have '%s' installed,\nbut %s only supports OpenSSH." % (
              version['ssh'], PRODUCT_NAME)
        raise MissingDependenciesError("OpenSSH", extra_msg=msg)

    return version


def _get_loggable_options(options):
    ops = dict(options.__dict__)
    del ops['api_key']  # no need to log the API key
    return ops


def run(options, dependency_versions=None):
    if not options.quiet:
        print ".---------------------------------------------------."
        print "|  Have questions or need help with Sauce Connect?  |"
        print "|  Contact us: http://saucelabs.com/forums          |"
        print "-----------------------------------------------------"
    logger.info("/ Starting \\")
    logger.info('Please wait for "You may start your tests" to start your tests.')
    logger.info("%s" % DISPLAY_VERSION)
    check_version()

    metadata = dict(ScriptName=NAME,
                    ScriptRelease=RELEASE,
                    Platform=platform.platform(),
                    PythonVersion=platform.python_version(),
                    OwnerHost=options.host,
                    OwnerPorts=options.ports,
                    Ports=options.tunnel_ports, )
    if dependency_versions:
        metadata['DependencyVersions'] = dependency_versions

    logger.debug("System is %s hours off UTC" %
                 (- (time.timezone, time.altzone)[time.daylight] / 3600.))
    logger.debug("options: %s" % _get_loggable_options(options))
    logger.debug("metadata: %s" % metadata)

    logger.info("Forwarding: %s:%s -> %s:%s", options.domains,
                options.tunnel_ports, options.host, options.ports)

    # Setup HealthChecker latency and make initial check of forwarded ports
    HealthChecker.latency_log = options.latency_log
    fail_msg = ("!! Are you sure this machine can get to your web server on "
                "host '%(host)s' listening on port %(port)d? Your tests will "
                "fail while the server is unreachable.")
    HealthChecker(options.host, options.ports, fail_msg=fail_msg).check()

    for attempt in xrange(1, RETRY_BOOT_MAX + 1):
        try:
            tunnel = TunnelMachine(options.rest_url, options.user,
                                   options.api_key, options.domains,
                                   options.ssh_port, metadata)
        except TunnelMachineError, e:
            logger.error(e)
            peace_out(returncode=1)  # exits
        setup_signal_handler(tunnel, options)
        atexit.register(peace_out, tunnel, atexit=True)
        try:
            tunnel.ready_wait()
            break
        except TunnelMachineError, e:
            logger.warning(e)
            if attempt < RETRY_BOOT_MAX:
                logger.info("Requesting new tunnel")
                continue
            logger.error("!! Could not get tunnel host")
            logger.info("** Please contact help@saucelabs.com")
            peace_out(tunnel, returncode=1)  # exits

    ssh = ReverseSSH(tunnel=tunnel, host=options.host,
                     ports=options.ports, tunnel_ports=options.tunnel_ports,
                     ssh_port=options.ssh_port,
                     use_ssh_config=options.use_ssh_config,
                     debug=options.debug_ssh)
    try:
        ssh.run(options.readyfile)
    except (ReverseSSHError, TunnelMachineError), e:
        logger.error(e)
    peace_out(tunnel)  # exits


def main():
    if map(int, platform.python_version_tuple ()) < [2, 5]:
        print "%s requires Python 2.5 (2006) or newer." % PRODUCT_NAME
        raise SystemExit(1)

    try:
        dependency_versions = check_dependencies()
    except MissingDependenciesError, e:
        print "\n== Missing requirements ==\n"
        print e
        raise SystemExit(1)

    options = get_options()
    setup_logging(options.logfile, options.quiet)

    try:
        run(options, dependency_versions)
    except Exception, e:
        logger.exception("Unhandled exception: %s", str(e))
        msg = "*** Please send this error to help@saucelabs.com. ***"
        logger.critical(msg)
        sys.stderr.write("\noptions: %s\n\n%s\n"
                         % (_get_loggable_options(options), msg))


if __name__ == '__main__':
    try:
        main()
    except Exception, e:
        msg = "*** Please send this error to help@saucelabs.com. ***"
        msg = "*" * len(msg) + "\n%s\n" % msg + "*" * len(msg)
        sys.stderr.write("\n%s\n\n" % msg)
        raise
