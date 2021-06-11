# frozen_string_literal: true

module Providers
  class Console
    def initialize
      @pending = {}
    end

    def emit(metrics)
      @pending = pending.merge(metrics)
    end

    def send
      pending.map do |metric, value|
        puts "#{metric}: #{value}"
      end
    end

    private

    attr_reader :pending
  end
end
