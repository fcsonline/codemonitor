# frozen_string_literal: true

require_relative '../../../engines/tsc/extractor'
require_relative '../../../providers/test'

RSpec.describe Engines::Tsc::Extractor do
  let(:provider) { Providers::Test.new }
  let(:tsc_output) do
    <<~OUTPUT
      Files:                        19499
      Lines of Library:             50780
      Lines of Definitions:        522989
      Lines of TypeScript:        1674125
      Lines of JavaScript:              0
      Lines of JSON:                53335
      Lines of Other:                   0
      Identifiers:                3158920
      Symbols:                    7954849
      Types:                      2788435
      Instantiations:             5135695
      Memory used:               6942037K
      Assignability cache size:   1242839
      Identity cache size:          80202
      Subtype cache size:           34300
      Strict subtype cache size:   452809
      I/O Read time:                0.63s
      Parse time:                   3.26s
      ResolveModule time:           1.72s
      ResolveTypeReference time:    0.00s
      ResolveLibrary time:          0.01s
      Program time:                 6.54s
      Bind time:                    2.36s
      Check time:                  54.45s
      printTime time:               0.00s
      Emit time:                    0.00s
      Total time:                  63.35s
    OUTPUT
  end

  subject do
    described_class.new.call(provider)
    provider.pending.transform_keys(&:to_sym)
  end

  it 'emits all the expected metrics' do
    expect(File).to receive(:read).with('tsc.output.txt').and_return(tsc_output)

    expect(subject).to include(
      tsc_files: 19499,
      tsc_lines_of_library: 50780,
      tsc_lines_of_definitions: 522989,
      tsc_lines_of_typescript: 1674125,
      tsc_lines_of_javascript: 0,
      tsc_lines_of_json: 53335,
      tsc_lines_of_other: 0,
      tsc_identifiers: 3158920,
      tsc_symbols: 7954849,
      tsc_types: 2788435,
      tsc_instantiations: 5135695,
      tsc_memory_used_kb: 6942037,
      tsc_assignability_cache_size: 1242839,
      tsc_identity_cache_size: 80202,
      tsc_subtype_cache_size: 34300,
      tsc_strict_subtype_cache_size: 452809,
      tsc_io_read_time_seconds: 0.63,
      tsc_parse_time_seconds: 3.26,
      tsc_resolve_module_time_seconds: 1.72,
      tsc_resolve_type_reference_time_seconds: 0.0,
      tsc_resolve_library_time_seconds: 0.01,
      tsc_program_time_seconds: 6.54,
      tsc_bind_time_seconds: 2.36,
      tsc_check_time_seconds: 54.45,
      tsc_print_time_time_seconds: 0.0,
      tsc_emit_time_seconds: 0.0,
      tsc_total_time_seconds: 63.35
    )
  end
end
