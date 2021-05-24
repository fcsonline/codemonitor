# frozen_string_literal: true

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

      def call(provider)
        return unless requirements?

        metrics = METRICS.map do |metric|
          [metric, send(metric)]
        end.to_h

        provider.emit(metrics)
      end

      private

      def requirements?
        File.exist?('.git')
      end

      def git_number_of_commits
        `git log --format='%h' | wc -l`
      end

      def git_number_of_branches
        `git ls-remote -q | grep heads | wc -l`
      end

      def git_number_of_tags
        `git ls-remote -q | grep tags | wc -l`
      end

      def git_number_of_contributors
        `git log --format='%aN' | sort -u | wc -l`
      end

      def git_number_of_files
        `git ls-tree -r master --name-only | wc -l`
      end

      def git_number_of_ignores_files
        `git check-ignore * | wc -l`
      end

      def git_number_of_lines
        `git ls-files | xargs cat | wc -l`
      end
    end
  end
end
