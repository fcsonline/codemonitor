# frozen_string_literal: true

require 'json'

module Engines
  module Eslint
    class Extractor
      METRICS = %i[
        eslint_number_of_offended_files
        eslint_number_of_offenses
        eslint_number_of_correctable
      ].freeze

      def initialize
        @threshold = ENV.fetch('CODEMONITOR_ESLINT_THRESHOLD', '10').to_i
      end

      def call(provider)
        return unless requirements?

        metrics = METRICS.map do |metric|
          [metric, send(metric)]
        end.to_h

        metrics
          .merge!(eslint_by_severity)
          .merge!(eslint_by_rule)

        provider.emit(metrics)
      end

      private

      attr_reader :threshold

      def requirements?
        # FIXME: Review if this is the only check we can do or there are more.
        File.exist?('.eslintrc.js')
      end

      # NOTE: This output file must be created by an external command
      def eslint
        @eslint ||= JSON.parse(File.read('eslint.output.json'))
      end

      def eslint_files
        eslint
      end

      def eslint_number_of_offended_files
        eslint_files.length
      end

      def eslint_offenses
        eslint_files
          .map { |offense| offense['messages'] }
          .flatten
      end

      def eslint_number_of_offenses
        eslint_offenses.length
      end

      def eslint_number_of_correctable
        eslint_offenses
          .filter { |offense| offense['correctable'] }
          .length
      end

      def eslint_by_severity
        eslint_offenses
          .each_with_object(Hash.new(0)) do |offense, total|
            total[severity(offense['severity'])] += 1
          end.map do |key, value|
            ["eslint_severity_#{key}", value]
          end.to_h
      end

      def eslint_by_rule
        eslint_offenses
          .each_with_object(Hash.new(0)) do |offense, total|
            total[offense['ruleId']] += 1
          end.map do |key, value|
            ["eslint_rule_#{clean(key)}", value] if value >= threshold
          end.compact.to_h
      end

      def clean(key)
        key.gsub(%r{[-,./ ]}, '_').downcase
      end

      def severity(value)
        return 'warning' if value == 1
        return 'error' if value == 2

        'unknown'
      end
    end
  end
end
