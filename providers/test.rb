module Providers
  class Test
    def initialize
      @pending = {}
    end

    def emit(metrics)
      @pending = pending.merge(metrics)
    end

    def send; end

    attr_reader :pending
  end
end
