# frozen_string_literal: true

require 'json'

module Engines
  module JestJsonSummary
    class Extractor
      METRICS = %i[].freeze

      def initialize; end

      def call(provider)
        metrics = METRICS.map do |metric|
          [metric, send(metric)]
        end.to_h

        metrics
          .merge!(total_lines)
          .merge!(total_statements)
          .merge!(total_functions)
          .merge!(total_branches)
          .merge!(total_branches_true)

        provider.emit(metrics)
      end

      def requirements?
        File.exist?('jest_json_summary.output.json')
      end

      private

      def json_summary
        @json_summary ||= JSON.parse(File.read('jest_json_summary.output.json'))
      end

      def total_lines
        flatten('lines')
      end

      def total_statements
        flatten('statements')
      end

      def total_functions
        flatten('functions')
      end

      def total_branches
        flatten('branches')
      end

      def total_branches_true
        flatten('branchesTrue', 'branches_true')
      end

      def flatten(member, rename = nil)
        json_summary['total'][member].map do |key, value|
          ["jest_json_summary_#{rename || member}_#{key}", value.to_i]
        end.to_h
      end
    end
  end
end
