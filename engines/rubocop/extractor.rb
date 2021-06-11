# frozen_string_literal: true

require 'pry'
require 'json'

module Engines
  module Rubocop
    class Extractor
      METRICS = %i[
        rubocop_number_of_offenses
        rubocop_number_of_correctable
      ].freeze

      def initialize
        @threshold = ENV.fetch('CODEMETRICS_RUBOCOP_THRESHOLD', '50').to_i
      end

      def call(provider)
        return unless requirements?

        metrics = METRICS.map do |metric|
          [metric, send(metric)]
        end.to_h

        metrics
          .merge!(rubocop_by_severity)
          .merge!(rubocop_by_cop_name)

        provider.emit(metrics)
      end

      private

      attr_reader :threshold

      def requirements?
        File.exist?('.rubocop.yml')
      end

      # NOTE: This output file must be created by an external command
      def rubocop
        @rubocop ||= JSON.parse(File.read('rubocop.output.json'))
      end

      def rubocop_number_of_offenses
        rubocop_offenses.length
      end

      def rubocop_number_of_correctable
        rubocop_offenses
          .filter { |offense| offense['correctable'] }
          .length
      end

      def rubocop_offenses
        rubocop['files']
          .map { |file| file['offenses'] }
          .flatten
      end

      def rubocop_by_severity
        rubocop_offenses
          .each_with_object(Hash.new(0)) do |offense, total|
            total[offense['severity']] += 1
          end.map do |key, value|
            ["rubocop_severity_#{key}", value]
          end.to_h
      end

      def rubocop_by_cop_name
        rubocop_offenses
          .each_with_object(Hash.new(0)) do |offense, total|
            total[offense['cop_name']] += 1
          end.map do |key, value|
            ["rubocop_cop_#{clean(key)}", value] if value >= threshold
          end.compact.to_h
      end

      def clean(key)
        key.gsub(%r{[-,./ ]}, '_').downcase
      end
    end
  end
end
