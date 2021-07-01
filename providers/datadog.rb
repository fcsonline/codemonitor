# frozen_string_literal: true

require 'dogapi'

module Providers
  class Datadog
    def initialize
      @pending = {}
      @metric_prefix = ENV['DATADOG_PREFIX'] || 'codemonitor.'
      @datadog_client = Dogapi::Client.new(ENV['DATADOG_API_KEY'])
    end

    def emit(metrics)
      @pending = pending.merge(metrics)
    end

    def send
      datadog_client.batch_metrics do
        pending.each do |metric, value|
          metric = "#{metric_prefix}#{metric}"
          puts "#{metric}: #{value}"
          datadog_client.emit_point(metric, value, type: 'gauge')
        end
      end
    end

    private

    attr_reader :pending, :metric_prefix, :datadog_client
  end
end
