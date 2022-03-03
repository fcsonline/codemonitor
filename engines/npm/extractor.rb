# frozen_string_literal: true

require 'json'

require_relative '../../lib/shell'

module Engines
  module Npm
    class Extractor
      METRICS = %i[
        npm_number_of_prod_dependencies
        npm_number_of_dev_dependencies
        npm_number_of_scripts
        npm_number_of_computed_prod_dependencies
        npm_number_of_computed_dev_dependencies
        npm_number_of_computed_optional_dependencies
        npm_number_of_computed_peer_dependencies
        npm_number_of_computed_peer_optional_dependencies
        npm_number_of_computed_total_dependencies
        npm_number_of_vulnerable_dependencies_info
        npm_number_of_vulnerable_dependencies_low
        npm_number_of_vulnerable_dependencies_moderate
        npm_number_of_vulnerable_dependencies_high
        npm_number_of_vulnerable_dependencies_critical
        npm_number_of_vulnerable_dependencies_total
      ].freeze

      def call(provider)
        metrics = METRICS.map do |metric|
          [metric, send(metric) || 0]
        end.to_h

        provider.emit(metrics)
      end

      def requirements?
        File.exist?('package.json') && File.exist?('package-lock.json')
      end

      private

      def npm_number_of_prod_dependencies
        npm_package['dependencies']&.keys&.length
      end

      def npm_number_of_dev_dependencies
        npm_package['devDependencies']&.keys&.length
      end

      def npm_number_of_scripts
        npm_package['scripts'].keys.length
      end

      def npm_number_of_vulnerable_dependencies_info
        npm_audit_by_severity['info']
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

      def npm_number_of_vulnerable_dependencies_critical
        npm_audit_by_severity['critical']
      end

      def npm_number_of_vulnerable_dependencies_total
        npm_audit_by_severity['total']
      end

      def npm_number_of_computed_prod_dependencies
        npm_audit_by_dependencies['prod']
      end

      def npm_number_of_computed_dev_dependencies
        npm_audit_by_dependencies['dev']
      end

      def npm_number_of_computed_optional_dependencies
        npm_audit_by_dependencies['optional']
      end

      def npm_number_of_computed_peer_dependencies
        npm_audit_by_dependencies['peer']
      end

      def npm_number_of_computed_peer_optional_dependencies
        npm_audit_by_dependencies['peerOptional']
      end

      def npm_number_of_computed_total_dependencies
        npm_audit_by_dependencies['total']
      end

      def npm_package
        @npm_package ||= JSON.parse(File.read('package.json'))
      end

      def npm_audit
        @npm_audit ||= JSON.parse(Shell.run('npm audit --json'))
      end

      def npm_audit_by_dependencies
        npm_audit['metadata']['dependencies']
      end

      def npm_audit_by_severity
        npm_audit['metadata']['vulnerabilities']
      end
    end
  end
end
