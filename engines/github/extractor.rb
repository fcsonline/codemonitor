# frozen_string_literal: true

require 'octokit'
require 'date'

Octokit.configure do |c|
  c.auto_paginate = true
end

module Engines
  module Github
    class Extractor
      METRICS = %i[
        github_number_of_open_pull_requests
        github_number_of_lead_time_in_days
      ].freeze

      def initialize
        @access_token = ENV['GITHUB_TOKEN']
        @repository = ENV['GITHUB_REPOSITORY']
        @since_days = ENV['GITHUB_SINCE_DAYS'] || 30
      end

      def call(provider)
        return unless requirements?

        metrics = METRICS.map do |metric|
          [metric, send(metric)]
        end.to_h

        provider.emit(metrics)
      end

      private

      attr_reader :access_token, :repository, :since_days

      def github
        @github ||= Octokit::Client.new(access_token: access_token)
      end

      def requirements?
        !access_token.nil? && !repository.nil?
      end

      def since
        (Date.today - since_days).to_time.iso8601
      end

      def github_number_of_open_pull_requests
        github.issues(repository, state: 'open').length
      end

      def github_number_of_lead_time_in_days
        diffs = github
          .issues(repository, since: since, state: 'closed')
          .map do |issue|
            next nil if issue[:pull_request][:merged_at].nil? || issue[:created_at].nil?

            merged_at = Time.at(issue[:pull_request][:merged_at])
            created_at = Time.at(issue[:created_at])

            merged_at - created_at
          end.reject do |diff|
            diff.nil?
          end

        value = (diffs.reduce(:+) / diffs.size.to_f / (24 * 60 * 60))

        value.round(2)
      end
    end
  end
end
