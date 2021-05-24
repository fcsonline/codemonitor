# frozen_string_literal: true

require_relative '../../../engines/rubocop/extractor'
require_relative '../../../providers/test'

RSpec.describe Engines::Rubocop::Extractor do
  let(:provider) { Providers::Test.new }
  let(:payload) do
    {
      files: [
        {
          path: 'sample.rb',
          offenses: [
            {
              severity: 'warning',
              cop_name: 'Style/RedundantRegexpEscape',
              corrected: false,
              correctable: false
            }
          ]
        },
        {
          path: 'test.rb',
          offenses: [
            {
              severity: 'warning',
              cop_name: 'Style/RedundantRegexpEscape',
              corrected: false,
              correctable: false
            },
            {
              severity: 'convention',
              cop_name: 'Metrics/BlockLength',
              corrected: false,
              correctable: true
            }
          ]
        }
      ]
    }
  end

  subject do
    described_class.new(threshold: 0).call(provider)
    provider.pending.transform_keys(&:to_sym)
  end

  it 'emits all the expected metrics' do
    expect(File).to receive(:exist?).with('.rubocop.yml').and_return(true)
    expect(File).to receive(:read).with('rubocop.output.json').and_return(payload.to_json)

    expect(subject).to include(
      rubocop_number_of_offenses: 3,
      rubocop_number_of_correctable: 1,
      rubocop_severity_convention: 1,
      rubocop_severity_warning: 2,
      rubocop_cop_style_redundantregexpescape: 2,
      rubocop_cop_metrics_blocklength: 1
    )
  end
end
