# frozen_string_literal: true

require_relative '../../lib/shell'

module Engines
  module Git
    class Extractor
      METRICS = %i[
        git_number_of_commits
        git_number_of_branches
        git_number_of_tags
        git_number_of_contributors
        git_number_of_files
        git_number_of_ignores_files
        git_number_of_lines
      ].freeze

      def initialize
        @threshold = ENV.fetch('CODEMONITOR_GIT_FILES_THRESHOLD', '0').to_i
      end

      def call(provider)
        return unless requirements?

        metrics = METRICS.map do |metric|
          [metric, send(metric)]
        end.to_h

        metrics
          .merge!(git_file_extensions)

        provider.emit(metrics)
      end

      private

      attr_reader :threshold

      def requirements?
        File.exist?('.git')
      end

      def git_number_of_commits
        Shell.run("git log --format='%h'").lines.count
      end

      def git_number_of_branches
        Shell.run('git ls-remote -q')
          .lines
          .filter { |line| line =~ %r{\Arefs/heads} }
          .count
      end

      def git_number_of_tags
        Shell.run('git ls-remote -q')
          .lines
          .filter { |line| line =~ %r{\Arefs/tags} }
          .count
      end

      def git_number_of_contributors
        Shell.run("git log --format='%aN'")
          .lines
          .sort
          .uniq
          .count
      end

      def git_number_of_files
        Shell.run('git ls-tree -r HEAD --name-only')
          .lines
          .count
      end

      def git_number_of_ignores_files
        Shell.run('git check-ignore *').lines.count
      end

      def git_number_of_lines
        Shell.run('git ls-files')
          .lines
          .map do |file|
            File.read(File.expand_path(file.strip, Dir.pwd)).lines.count
          end.sum
      end

      def git_file_extensions
        Shell.run('git ls-files')
          .lines
          .map do |file|
            File.extname(file.strip)
          end.each_with_object(Hash.new(0)) do |type, total|
            total[type.gsub('.', '')] += 1
          end.map do |key, value|
            ["git_file_extensions_#{key}", value] if value >= threshold
          end.compact.to_h
      end
    end
  end
end
