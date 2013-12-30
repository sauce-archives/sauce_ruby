require 'spec_helper'

describe 'parse_task_args' do
  before :all do
    Sauce::TestBroker.stub(:concurrency) {20}
  end
  
  it 'returns the saucerspec type when using rspec' do
    actual_args = parse_task_args(:rspec, {}).join ' '
    actual_args.should include '--type saucerspec'
  end

  it 'returns the saucecucumber type when using cucumber' do
    actual_args = parse_task_args(:cucumber, {}).join ' '
    actual_args.should include '--type saucecucumber'
  end

  context 'files' do
    it 'is parsed from the :files argument' do
      task_args = {:files => 'proscuitto/iberico.spec'}
      actual_args = parse_task_args(task_args).join ' '
      actual_args.end_with?('proscuitto/iberico.spec').should be_true
    end

    it 'defaults to spec when rspec is used' do
      actual_args = parse_task_args(:rspec, {}).join ' '
      actual_args.end_with?('spec').should be_true
    end

    it 'defaults to features when cucumber is used' do
      actual_args = parse_task_args(:cucumber, {}).join ' '
      actual_args.end_with?('features').should be_true
    end

    context 'when set by environment variable' do
      before :each do
        @stored_test_files = ENV['test_files']
        ENV['test_files'] = nil
      end

      after :each do
        ENV['test_files'] = @stored_test_files
      end

      it 'comes from the test_files variable' do
        ENV['test_files'] = 'pancetta'
        actual_args = parse_task_args(:rspec, {}).join ' '
        actual_args.end_with?('pancetta').should be_true
      end

      it 'is overridden by the CLI' do
        ENV['test_files'] = 'spam'
        test_args = {:files => 'bacon'}
        actual_args = parse_task_args(:rspec, test_args).join ' '
        actual_args.end_with?('bacon').should be_true
        actual_args.should_not include 'spam'
      end
    end
  end

  context 'concurrency' do
    it 'parses the second argument' do
      task_args = {:features => 'features', :concurrency => '4'}
      actual_args = parse_task_args(task_args).join ' '
      actual_args.should include '-n 4'
    end

    context 'when set by environment variable' do
      before :each do
        @stored_concurrency = ENV['concurrency']
        ENV['concurrency'] = nil
      end

      after :each do
        ENV['concurrency'] = @stored_concurrency
      end

      it 'is parsed out' do
        ENV['concurrency'] = '18'
        actual_args = parse_task_args({}).join ' '
        actual_args.should include '-n 18'
      end

      it 'is overridden by the CLI' do
        ENV['concurrency'] = '14'
        task_args = {:files => 'features', :concurrency => '12'}
        actual_args = parse_task_args(task_args).join ' '
        actual_args.should include '-n 12'
      end
    end

    context 'test options' do
      it 'are parsed from the test_options argument' do
        task_args = {:test_options => '--no-derp'}
        actual_args = parse_task_args(task_args).join ' '
        actual_args.should include '-o --no-derp'
      end

      context 'when not supplied' do
        it 'default to -t sauce for rspec' do
          actual_args = parse_task_args(:rspec, {}).join ' '
          actual_args.should include '-o -t sauce'
        end

        it 'defaults to not being present for cucumber' do
          actual_args = parse_task_args(:cucmber, {}).join ' '
          actual_args.should_not include '-o'
        end
      end

      context 'when set from environment options' do
        before :each do
          @stored_rspec_options = ENV['test_options']
          ENV['test_options'] = nil
        end

        after :each do
          ENV['test_options'] = @stored_rspec_options
        end

        it 'is read from the test_options variable' do
          ENV['test_options'] = '-derp_level some'
          actual_args = parse_task_args({}).join ' '
          actual_args.should include '-o -derp_level some'
        end

        it 'is overridden by the CLI' do
          ENV['test_options'] = '-derp_level maximum'
          task_args = {:test_options => '--no-derp'}
          actual_args = parse_task_args(task_args).join ' '
          actual_args.should_not include '-derp_level maximum'
          actual_args.should include '-o --no-derp'
        end
      end
    end

    context "parallel tests options" do
      it 'is parsed from the parallel_options argument' do
        test_args = {:parallel_options => 'wow'}
        actual_args = parse_task_args(test_args).join ' '
        actual_args.should include 'wow'
      end

      it 'is broken into individual options' do
        test_args = {:parallel_options => '--scared so'}
        actual_args = parse_task_args(:rspec, test_args)
        
        actual_args.should include '--scared'
        actual_args.should include 'so'
        index = actual_args.index '--scared'
        actual_args[index + 1].should eq 'so'
      end

      context 'read from environment variables' do
        before :each do
          @@stored_rspec_options = ENV['rspec_options']
          ENV['parallel_test_options'] = nil
        end

        after :each do
          ENV['parallel_test_options'] = @@stored_rspec_options
        end

        it 'is read from the parallel_test_options variable' do
          ENV['parallel_test_options'] = '-such option'
          actual_args = parse_task_args({}).join ' '
          actual_args.should include '-such option'
        end

        it 'is overridden by the CLI' do
          ENV['parallel_test_options'] = '-such option'
          task_args = {:parallel_options => 'many override'}
          actual_args = parse_task_args(task_args).join ' '
          actual_args.should_not include '-such option'
          actual_args.should include 'many override'
        end
      end
    end
  end
end