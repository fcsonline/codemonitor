# frozen_string_literal: true

module Providers
  class BaseProvider
    attr_reader :pending

    def initialize
      @pending = {}
    end

    def emit(metrics)
      @pending = pending.merge(metrics.transform_keys(&:to_s))
    end
  end
end
