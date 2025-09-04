# frozen_string_literal: true

require_relative 'base_provider'

module Providers
  class Console < BaseProvider
    def send
      pending.map do |metric, value|
        puts "#{metric}: #{value}"
      end
    end
  end
end
