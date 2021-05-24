# frozen_string_literal: true

require_relative '../../../engines/npm/extractor'
require_relative '../../../providers/test'
require_relative '../../../lib/shell'

RSpec.describe Engines::Npm::Extractor do
  let(:provider) { Providers::Test.new }
  let(:payload) do
    {
      dependencies: {
        'react': '17.0.0',
        'node-fetch': '2.5.0',
        'typescript': '4.2.0'
      },
      devDependencies: {
        'gh-pages': '3.1.0',
        'react-script': '3.4.0'
      },
      scripts: {
        'start': 'react-scripts start',
        'build': 'react-scripts build',
        'predeploy': 'npm run build',
        'deploy': 'gh-pages -d build'
      }
    }
  end

  let(:audit) do
    {
      advisories: {
        foo: {
          severity: 'high'
        },
        bar: {
          severity: 'high'
        },
        lol: {
          severity: 'high'
        },
        baz: {
          severity: 'moderate'
        }
      }
    }
  end

  subject do
    described_class.new.call(provider)
    provider.pending.transform_keys(&:to_sym)
  end

  it 'emits all the expected metrics' do
    expect(File).to receive(:exist?).with('package.json').and_return(true)
    expect(File).to receive(:read).with('package.json').and_return(payload.to_json)
    expect(Shell).to receive(:run).with('npm audit --json').and_return(audit.to_json)

    expect(subject).to include(
      npm_number_of_dependencies: 3,
      npm_number_of_dev_dependencies: 2,
      npm_number_of_scripts: 4,
      npm_number_of_vulnerable_dependencies: 4,
      npm_number_of_vulnerable_dependencies_low: 0,
      npm_number_of_vulnerable_dependencies_moderate: 1,
      npm_number_of_vulnerable_dependencies_high: 3
    )
  end
end
