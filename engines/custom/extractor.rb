# frozen_string_literal: true

module Engines
  module Custom
    class Extractor
      def call(provider)
        return unless requirements?

        provider.emit(metrics)
      end

      private

      def requirements?
        custom_files.length.positive?
      end

      def custom_files
        Dir.glob('./.codemonitor/*.rb')
      end

      def metrics
        custom_files.map do |file|
          values = begin
            eval File.read(file)
          rescue SyntaxError => e
            raise "Unable to execute the custom codemonitor script `#{file}` file"
          end

          raise "Malformed return value from `#{file}` file. It must be a hash of metrics" unless values.is_a?(Hash)

          values
        end.reduce({}, :merge)
      end
    end
  end
end
