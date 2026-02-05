# frozen_string_literal: true

module Engines
  module Tsc
    class Extractor
      METRICS = %i[
        tsc_files
        tsc_lines_of_library
        tsc_lines_of_definitions
        tsc_lines_of_typescript
        tsc_lines_of_javascript
        tsc_lines_of_json
        tsc_lines_of_other
        tsc_identifiers
        tsc_symbols
        tsc_types
        tsc_instantiations
        tsc_memory_used_kb
        tsc_assignability_cache_size
        tsc_identity_cache_size
        tsc_subtype_cache_size
        tsc_strict_subtype_cache_size
        tsc_io_read_time_seconds
        tsc_parse_time_seconds
        tsc_resolve_module_time_seconds
        tsc_resolve_type_reference_time_seconds
        tsc_resolve_library_time_seconds
        tsc_program_time_seconds
        tsc_bind_time_seconds
        tsc_check_time_seconds
        tsc_print_time_seconds
        tsc_emit_time_seconds
        tsc_total_time_seconds
      ].freeze

      def call(provider)
        metrics = METRICS.map do |metric|
          [metric, send(metric)]
        end.to_h

        provider.emit(metrics)
      end

      def requirements?
        File.exist?('tsc.output.txt')
      end

      private

      def tsc_output
        @tsc_output ||= File.read('tsc.output.txt')
      end

      def extract_integer(pattern)
        match = tsc_output.match(pattern)
        return 0 if match.nil?

        match[1].gsub(/\s+/, '').to_i
      end

      def extract_time(pattern)
        match = tsc_output.match(pattern)
        return 0.0 if match.nil?

        time_str = match[1]
        # Convert time format like "0.63s" to 0.63
        time_str.sub(/s$/, '').to_f
      end

      def tsc_files
        extract_integer(/^Files:\s+(\d+)/)
      end

      def tsc_lines_of_library
        extract_integer(/^Lines of Library:\s+(\d+)/)
      end

      def tsc_lines_of_definitions
        extract_integer(/^Lines of Definitions:\s+(\d+)/)
      end

      def tsc_lines_of_typescript
        extract_integer(/^Lines of TypeScript:\s+(\d+)/)
      end

      def tsc_lines_of_javascript
        extract_integer(/^Lines of JavaScript:\s+(\d+)/)
      end

      def tsc_lines_of_json
        extract_integer(/^Lines of JSON:\s+(\d+)/)
      end

      def tsc_lines_of_other
        extract_integer(/^Lines of Other:\s+(\d+)/)
      end

      def tsc_identifiers
        extract_integer(/^Identifiers:\s+(\d+)/)
      end

      def tsc_symbols
        extract_integer(/^Symbols:\s+(\d+)/)
      end

      def tsc_types
        extract_integer(/^Types:\s+(\d+)/)
      end

      def tsc_instantiations
        extract_integer(/^Instantiations:\s+(\d+)/)
      end

      def tsc_memory_used_kb
        # Extract memory in KB (e.g., "6942037K" -> 6942037)
        match = tsc_output.match(/^Memory used:\s+(\d+)K/)
        return 0 if match.nil?

        match[1].to_i
      end

      def tsc_assignability_cache_size
        extract_integer(/^Assignability cache size:\s+(\d+)/)
      end

      def tsc_identity_cache_size
        extract_integer(/^Identity cache size:\s+(\d+)/)
      end

      def tsc_subtype_cache_size
        extract_integer(/^Subtype cache size:\s+(\d+)/)
      end

      def tsc_strict_subtype_cache_size
        extract_integer(/^Strict subtype cache size:\s+(\d+)/)
      end

      def tsc_io_read_time_seconds
        extract_time(/^I\/O Read time:\s+([\d.]+s)/)
      end

      def tsc_parse_time_seconds
        extract_time(/^Parse time:\s+([\d.]+s)/)
      end

      def tsc_resolve_module_time_seconds
        extract_time(/^ResolveModule time:\s+([\d.]+s)/)
      end

      def tsc_resolve_type_reference_time_seconds
        extract_time(/^ResolveTypeReference time:\s+([\d.]+s)/)
      end

      def tsc_resolve_library_time_seconds
        extract_time(/^ResolveLibrary time:\s+([\d.]+s)/)
      end

      def tsc_program_time_seconds
        extract_time(/^Program time:\s+([\d.]+s)/)
      end

      def tsc_bind_time_seconds
        extract_time(/^Bind time:\s+([\d.]+s)/)
      end

      def tsc_check_time_seconds
        extract_time(/^Check time:\s+([\d.]+s)/)
      end

      def tsc_print_time_seconds
        extract_time(/^printTime time:\s+([\d.]+s)/)
      end

      def tsc_emit_time_seconds
        extract_time(/^Emit time:\s+([\d.]+s)/)
      end

      def tsc_total_time_seconds
        extract_time(/^Total time:\s+([\d.]+s)/)
      end
    end
  end
end
