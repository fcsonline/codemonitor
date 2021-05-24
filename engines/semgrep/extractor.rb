# frozen_string_literal: true

require 'pry'
require 'json'

module Engines
  module Semgrep
    class Extractor
      METRICS = %i[
        semgrep_number_of_offenses
        semgrep_number_of_errors
      ].freeze

      def initialize(threshold: 50)
        @threshold = threshold
      end

      def call(provider)
        return unless requirements?

        metrics = METRICS.map do |metric|
          [metric, send(metric)]
        end.to_h.merge(semgrep_by_check_id)

        provider.emit(metrics)
      end

      private

      attr_reader :threshold

      def requirements?
        File.exist?('.semgrep.yml')
      end

      # NOTE: This output file must be created by an external command
      def semgrep
        @semgrep ||= JSON.parse(File.read('semgrep.output.json'))
      end

      def semgrep_number_of_offenses
        semgrep['results'].length
      end

      def semgrep_number_of_errors
        semgrep['errors'].length
      end

      def semgrep_by_check_id
        semgrep['results']
          .each_with_object(Hash.new(0)) do |offense, total|
            total[offense['check_id']] += 1
          end.map do |key, value|
            ["semgrep_check_#{clean(key)}", value] if value >= threshold
          end.to_h
      end

      def clean(key)
        key.gsub(/[-,. ]/, '_')
      end
    end
  end
end
