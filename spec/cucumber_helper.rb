# NOTE: This file is verbatim "borrowed" from the cucumber source tree:
# <https://github.com/cucumber/cucumber/blob/master/spec/cucumber/formatter/spec_helper.rb>

require 'cucumber'

module Sauce
  module Cucumber
    module SpecHelper
      def run_defined_feature(content)
        features = load_features(content || raise("No feature content defined!"))
        run(features)
      end

      def step_mother
        @step_mother ||= ::Cucumber::Runtime.new
      end

      def load_features(content)
        feature_file = ::Cucumber::FeatureFile.new('mock.feature', content)
        features = ::Cucumber::Ast::Features.new
        filters = []
        feature = feature_file.parse(filters, {})
        features.add_feature(feature) if feature
        features
      end

      def run(features)
        configuration = ::Cucumber::Configuration.default
        tree_walker = ::Cucumber::Ast::TreeWalker.new(step_mother, [@formatter], configuration)
        tree_walker.visit_features(features)
      end

      def define_steps(&block)
        rb = step_mother.load_programming_language('rb')
        dsl = Object.new
        dsl.extend ::Cucumber::RbSupport::RbDsl
        dsl.instance_exec &block
      end
    end
  end
end

