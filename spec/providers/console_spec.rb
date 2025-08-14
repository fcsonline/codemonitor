# frozen_string_literal: true

require_relative '../../providers/console'

RSpec.describe Providers::Console do
  let(:provider) { described_class.new }

  describe '#send' do
    subject { provider.send }

    before { allow(provider).to receive(:puts) }

    it 'prints metrics' do
      provider.emit('requests' => 100, 'errors' => 5)

      expect(provider).to receive(:puts).with('requests: 100')
      expect(provider).to receive(:puts).with('errors: 5')

      subject
    end

    context 'with metrics containing tags' do
      it 'handles single tag' do
        provider.emit('requests#production' => 200)

        expect(provider).to receive(:puts).with('requests#production: 200')

        subject
      end

      it 'handles multiple tags' do
        provider.emit('latency#backend,region:us-east-1,env:prod' => 150)

        expect(provider).to receive(:puts).with(
          'latency#backend,region:us-east-1,env:prod: 150'
        )

        subject
      end
    end
  end
end
