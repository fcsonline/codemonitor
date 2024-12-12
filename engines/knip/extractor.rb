# frozen_string_literal: true

module Engines
  module Knip
    class Extractor
      METRICS = %i[
        knip_number_of_dependecies
        knip_number_of_devDependencies
        knip_number_of_optionalPeerDependencies
        knip_number_of_unlisted
        knip_number_of_binaries
        knip_number_of_unresolved
        knip_number_of_exports
        knip_number_of_types
        knip_number_of_enumMembers
        knip_number_of_duplicates
      ].freeze

      def initialize
      end

      def call(provider)
        metrics = METRICS.map do |metric|
          [metric, send(metric)]
        end.to_h

        provider.emit(metrics)
      end

      def requirements?
        File.exist?('knip.output.json')
      end

      private

      def knip
        @knip ||= JSON.parse(File.read('knip.output.json'))
      end

      def by_type(type)
        knip['issues'].reduce(0) do |total, issue|
          total + issue[type].length
        end
      end

      def knip_number_of_dependecies
        by_type('dependencies')
      end

      def knip_number_of_devDependencies
        by_type('devDependencies')
      end

      def knip_number_of_optionalPeerDependencies
        by_type('optionalPeerDependencies')
      end

      def knip_number_of_unlisted
        by_type('unlisted')
      end

      def knip_number_of_binaries
        by_type('binaries')
      end

      def knip_number_of_unresolved
        by_type('unresolved')
      end

      def knip_number_of_exports
        by_type('exports')
      end

      def knip_number_of_types
        by_type('types')
      end

      def knip_number_of_enumMembers
        by_type('enumMembers')
      end

      def knip_number_of_duplicates
        by_type('duplicates')
      end
    end
  end
end
