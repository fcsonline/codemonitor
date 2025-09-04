# frozen_string_literal: true

require_relative 'base_provider'
require 'dogapi'

module Providers
  class Datadog < BaseProvider
    def initialize
      super
      @metric_prefix = ENV['DATADOG_PREFIX'] || 'codemonitor.'
      @datadog_client = Dogapi::Client.new(ENV['DATADOG_API_KEY'])
    end

    def send
      datadog_client.batch_metrics do
        pending.each do |metric, value|
          metric_name, tags = extract_tags(metric)
          metric_name = "#{metric_prefix}#{metric_name}"
          puts "#{metric_name}#{tags ? "[#{tags.join(',')}]" : ''}: #{value}"
          datadog_client.emit_point(metric_name, value, type: 'gauge', tags: tags)
        end
      end
    end

    private

    attr_reader :metric_prefix, :datadog_client

    def extract_tags(metric)
      if metric.include?('#')
        metric_name, tag_string = metric.split('#', 2)
        tags = tag_string.split(',')
        [metric_name, tags]
      else
        [metric, nil]
      end
    end
  end
end
