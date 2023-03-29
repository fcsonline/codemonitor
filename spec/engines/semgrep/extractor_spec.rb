# frozen_string_literal: true

require_relative '../../../engines/semgrep/extractor'
require_relative '../../../providers/test'

RSpec.describe Engines::Semgrep::Extractor do
  let(:provider) { Providers::Test.new }
  let(:payload) do
    {
      results: [
        {
          path: 'sample.rb',
          severity: 'warning',
          check_id: 'style-redundantregexpescape',
          corrected: false,
          correctable: false
        },
        {
          path: 'test.rb',
          severity: 'warning',
          check_id: 'style-redundantregexpescape',
          corrected: false,
          correctable: false
        },
        {
          path: 'test.rb',
          severity: 'convention',
          check_id: 'metrics-blocklength',
          corrected: false,
          correctable: true
        }
      ],
      errors: []
    }
  end

  before do
    ENV['CODEMONITOR_SEMGREP_THRESHOLD'] = '0'
  end

  subject do
    described_class.new.call(provider)
    provider.pending.transform_keys(&:to_sym)
  end

  it 'emits all the expected metrics' do
    expect(File).to receive(:read).with('semgrep.output.json').and_return(payload.to_json)

    expect(subject).to include(
      semgrep_number_of_offenses: 3,
      semgrep_number_of_errors: 0,
      semgrep_check_style_redundantregexpescape: 2,
      semgrep_check_metrics_blocklength: 1
    )
  end
end
