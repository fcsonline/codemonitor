# frozen_string_literal: true

require_relative '../../providers/datadog'

RSpec.describe Providers::Datadog do
  let(:datadog_client) { double('Dogapi::Client') }
  let(:provider) { described_class.new }

  before do
    allow(ENV).to receive(:[]).with('DATADOG_API_KEY').and_return('test-key')
    allow(ENV).to receive(:[]).with('DATADOG_PREFIX').and_return('prefix.')
    allow(Dogapi::Client).to receive(:new).with('test-key').and_return(
      datadog_client
    )
  end

  describe '#send' do
    subject { provider.send }

    before do
      allow(datadog_client).to receive(:batch_metrics).and_yield
      allow(datadog_client).to receive(:emit_point)
    end

    context 'with metrics without tags' do
      it 'sends metrics without tags to datadog' do
        provider.emit('requests' => 100, 'errors' => 5)

        expect(datadog_client).to receive(:emit_point).with('prefix.requests', 100, type: 'gauge', tags: nil)
        expect(datadog_client).to receive(:emit_point).with('prefix.errors', 5, type: 'gauge', tags: nil)

        subject
      end
    end

    context 'with metrics containing tags' do
      it 'parses tags from metric names with # delimiter' do
        provider.emit('metric_name#frontend,app:webserver' => 42)

        expect(datadog_client).to receive(:emit_point)
          .with('prefix.metric_name', 42, type: 'gauge', tags: ['frontend', 'app:webserver'])

        subject
      end

      it 'handles single tag' do
        provider.emit('requests#production' => 200)

        expect(datadog_client).to receive(:emit_point).with('prefix.requests', 200, type: 'gauge', tags: ['production'])

        subject
      end

      it 'handles multiple tags' do
        provider.emit('latency#backend,region:us-east-1,env:prod' => 150)

        expect(datadog_client).to receive(:emit_point)
          .with('prefix.latency', 150, type: 'gauge', tags: %w[backend region:us-east-1 env:prod])

        subject
      end
    end

    context 'with mixed metrics' do
      it 'handles both tagged and untagged metrics' do
        provider.emit(
          'simple_metric' => 10,
          'tagged_metric#tag1,tag2:value' => 20
        )

        expect(datadog_client).to receive(:emit_point)
          .with('prefix.simple_metric', 10, type: 'gauge', tags: nil)
        expect(datadog_client).to receive(:emit_point)
          .with('prefix.tagged_metric', 20, type: 'gauge', tags: ['tag1', 'tag2:value'])

        subject
      end
    end
  end
end
