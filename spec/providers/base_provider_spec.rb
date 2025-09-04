# frozen_string_literal: true

require_relative '../../providers/base_provider'

RSpec.describe Providers::BaseProvider do
  let(:provider) { described_class.new }

  describe '#emit' do
    context 'with symbol keys' do
      it 'converts symbol keys to strings' do
        provider.emit(requests: 100, errors: 5)

        expect(provider.instance_variable_get(:@pending)).to eq('requests' => 100, 'errors' => 5)
      end
    end

    context 'with mixed symbol and string keys' do
      it 'converts all keys to strings' do
        provider.emit(:requests => 100, 'errors' => 5)

        expect(provider.instance_variable_get(:@pending)).to eq('requests' => 100, 'errors' => 5)
      end
    end

    context 'with duplicate keys (symbol and string)' do
      it 'handles duplicate keys by keeping the latest value' do
        provider.emit(test: 1)
        provider.emit('test' => 2)

        expect(provider.instance_variable_get(:@pending)).to eq('test' => 2)
      end
    end

    context 'with multiple emit calls' do
      it 'merges metrics correctly' do
        provider.emit('requests' => 100)
        provider.emit(errors: 5)
        provider.emit('latency' => 150)

        expect(provider.instance_variable_get(:@pending)).to eq(
          'requests' => 100,
          'errors' => 5,
          'latency' => 150
        )
      end
    end
  end
end
