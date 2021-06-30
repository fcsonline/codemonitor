# frozen_string_literal: true

module Engines
  module Debug
    class Extractor
      METRICS = %i[
        debug_random
      ].freeze

      def call(provider)
        return unless requirements?

        metrics = METRICS.map do |metric|
          [metric, send(metric) || 0]
        end.to_h

        provider.emit(metrics)
      end

      private

      def requirements?
        true
      end

      def debug_random
        rand(0..100)
      end
    end
  end
end
