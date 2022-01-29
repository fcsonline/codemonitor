# frozen_string_literal: true

require 'json'

module Engines
  module Scc
    class Extractor
      METRICS = %i[].freeze
      FIELDS = %w[Bytes Lines Code Comment Blank Complexity Count WeightedComplexity]

      def initialize; end

      def call(provider)
        return unless requirements?

        metrics = METRICS.map do |metric|
          [metric, send(metric)]
        end.to_h

        metrics
          .merge!(scc_totals)
          .merge!(scc_by_file_type)

        provider.emit(metrics)
      end

      private

      def requirements?
        File.exist?('scc.output.json')
      end

      # NOTE: This output file must be created by an external command
      def scc
        @scc ||= JSON.parse(File.read('scc.output.json'))
      end

      def scc_totals
        scc.each_with_object({}) do |type, totals|
          FIELDS.each do |field|
            key = "scc_total_#{clean(field)}"
            totals[key] = 0 unless totals.key?(key)

            totals[key] += type[field]
          end
        end
      end

      def scc_by_file_type
        scc.map do |type|
          FIELDS.map do |field|
            ["scc_type_#{clean(type['Name'])}_#{clean(field)}", type[field]]
          end.to_h
        end.inject(&:merge)
      end

      def clean(key)
        key.gsub(%r{[-,./ ]}, '_').downcase
      end
    end
  end
end
