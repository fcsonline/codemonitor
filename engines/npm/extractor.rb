# frozen_string_literal: true

require 'pry'
require 'json'

require_relative '../../lib/shell'

module Engines
  module Npm
    class Extractor
      METRICS = %i[
        npm_number_of_dependencies
        npm_number_of_dev_dependencies
        npm_number_of_scripts
        npm_number_of_vulnerable_dependencies
        npm_number_of_vulnerable_dependencies_low
        npm_number_of_vulnerable_dependencies_moderate
        npm_number_of_vulnerable_dependencies_high
      ].freeze

      def call(provider)
        return unless requirements?

        metrics = METRICS.map do |metric|
          [metric, send(metric) || 0]
        end.to_h

        provider.emit(metrics)
      end

      private

      def requirements?
        File.exist?('package.json')
      end

      def npm_number_of_dependencies
        npm_package['dependencies'].keys.length
      end

      def npm_number_of_dev_dependencies
        npm_package['devDependencies'].keys.length
      end

      def npm_number_of_scripts
        npm_package['scripts'].keys.length
      end

      def npm_number_of_vulnerable_dependencies
        npm_audit['advisories'].length
      end

      def npm_number_of_vulnerable_dependencies_low
        npm_audit_by_severity['low']
      end

      def npm_number_of_vulnerable_dependencies_moderate
        npm_audit_by_severity['moderate']
      end

      def npm_number_of_vulnerable_dependencies_high
        npm_audit_by_severity['high']
      end

      def npm_package
        @npm_package ||= JSON.parse(File.read('package.json'))
      end

      def npm_audit
        @npm_audit ||= JSON.parse(Shell.run('npm audit --json'))
      end

      def npm_audit_by_severity
        npm_audit['advisories']
          .map { |_key, value| value['severity'] }
          .each_with_object(Hash.new(0)) { |e, total| total[e] += 1; }
      end
    end
  end
end
