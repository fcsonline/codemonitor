# frozen_string_literal: true

module Engines
  module Custom
    class Extractor
      def initialize
        @filenames = ENV.fetch('CODEMONITOR_CUSTOMS', nil)
      end

      def call(provider)
        provider.emit(metrics)
      end

      def requirements?
        custom_files.length.positive?
      end

      private

      def custom_files
        return Dir.glob('./.codemonitor/*.rb') if @filenames.nil?

        raise 'Forbidden access to parent folder' unless @filenames.match(/\.\./).nil?

        includes = @filenames.split(',').reject do |filename|
          filename.start_with?('-')
        end.map do |filename|
          "./.codemonitor/#{filename}.rb"
        end

        excludes = @filenames.split(',').filter do |filename|
          filename.start_with?('-')
        end.map do |filename|
          "./.codemonitor/#{filename.gsub(/^-/, '')}.rb"
        end

        raise 'Mixed included and excluded custom paths is not allowed' if includes.size > 0 && excludes.size > 0

        return Dir.glob(includes) if includes.size > 0

        Dir.glob('./.codemonitor/*.rb') - Dir.glob(excludes)
      end

      def metrics
        custom_files.map do |file|
          values = begin
            eval File.read(file)
          rescue SyntaxError => e
            raise "Unable to execute the custom codemonitor script `#{file}` file"
          end

          raise "Malformed return value from `#{file}` file. It must be a hash of metrics" unless values.is_a?(Hash)

          values
        end.reduce({}, :merge)
      end
    end
  end
end
