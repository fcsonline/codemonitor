require 'pry'
require 'json'

module Engines
  module Semgrep
    class Extractor
      METRICS = %i[
        semgrep_number_of_offenses
        semgrep_number_of_errors
      ].freeze

      def call(provider)
        return unless requirements?

        metrics = METRICS.map do |metric|
          [metric, send(metric)]
        end.to_h.merge(semgrep_by_check_id)

        provider.emit(metrics)
      end

      private

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
          .inject(Hash.new(0)) do |total, offense|
            total[offense['check_id']] += 1

            total
          end.map do |key, value|
            ["semgrep_#{clean(key)}", value]
          end.to_h
      end

      def clean(key)
        key.gsub(/[-,. ]/, '_')
      end
    end
  end
end
