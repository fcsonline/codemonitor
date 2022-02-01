# frozen_string_literal: true

require 'yaml'

module Engines
  module Packwerk
    class Extractor
      METRICS = %i[
        packwerk_number_of_dependency_violations
        packwerk_number_of_privacy_violations
      ].freeze

      def initialize; end

      def call(provider)
        metrics = METRICS.map do |metric|
          [metric, send(metric)]
        end.to_h

        provider.emit(metrics)
      end

      def requirements?
        packwerk_files.length.positive?
      end

      private

      # NOTE: This output file must be created by an external command
      def packwerk_files
        Dir.glob('./**/deprecated_references.yml')
      end

      def packwerk_number_of_dependency_violations
        packwerk_violations['dependency']
      end

      def packwerk_number_of_privacy_violations
        packwerk_violations['privacy']
      end

      def packwerk_items
        @packwerk_items ||= packwerk_files
          .map { |file| YAML.load_file(file) }
          .reduce({}, :merge)
          .map { |_key, values| values }
          .flatten
          .reduce({}, :merge)
      end

      def packwerk_violations
        packwerk_items
          .values
          .each_with_object(Hash.new(0)) do |offense, total|
            offense['violations'].each do |violation|
              total[violation] += 1
            end
          end
      end
    end
  end
end
