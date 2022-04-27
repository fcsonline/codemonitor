# frozen_string_literal: true

require 'json'

module Engines
  module SimpleCovJsonCoverage
    class Extractor
      METRICS = %i[
        simplecov_json_coverage_metrics_covered_percent
        simplecov_json_coverage_metrics_covered_strength
        simplecov_json_coverage_metrics_covered_lines
        simplecov_json_coverage_metrics_total_lines
      ].freeze

      def initialize; end

      def call(provider)
        metrics = METRICS.map do |metric|
          [metric, send(metric)]
        end.to_h

        provider.emit(metrics)
      end

      def requirements?
        File.exist?('simplecov_json_coverage.output.json')
      end

      private

      def json_summary
        @json_summary ||= JSON.parse(File.read('simplecov_json_coverage.output.json'))
      end

      def metrics
        @metrics ||= json_summary['metrics']
      end

      def simplecov_json_coverage_metrics_covered_percent
        metrics['covered_percent']
      end

      def simplecov_json_coverage_metrics_covered_strength
        metrics['covered_strength']
      end

      def simplecov_json_coverage_metrics_covered_lines
        metrics['covered_lines']
      end

      def simplecov_json_coverage_metrics_total_lines
        metrics['total_lines']
      end
    end
  end
end
