# frozen_string_literal: true

RSpec.describe 'Interactive mode' do
  let(:executable) { File.expand_path('../exe/codemonitor', __dir__) }

  it 'reads hash from stdin until two empty lines and outputs to console' do
    input = <<~INPUT
      {
        test_metric_1: 100,
        test_metric_2: 200,
        "requests#frontend": 300
      }


    INPUT

    output = IO.popen([executable, '--interactive'], 'r+') do |io|
      io.write(input)
      io.close_write
      io.read
    end

    expect(output).to include('# process start')
    expect(output).to include('test_metric_1: 100')
    expect(output).to include('test_metric_2: 200')
    expect(output).to include('requests#frontend: 300')
    expect(output).to include('# process end')
  end

  it 'handles empty hash' do
    input = <<~INPUT
      {}


    INPUT

    output = IO.popen([executable, '--interactive'], 'r+') do |io|
      io.write(input)
      io.close_write
      io.read
    end

    expect(output).to include('# process start')
    expect(output).to include('# process end')
  end

  it 'handles syntax errors gracefully' do
    input = <<~INPUT
      { invalid syntax


    INPUT

    output = IO.popen([executable, '--interactive'], 'r+') do |io|
      io.write(input)
      io.close_write
      io.read
    end

    expect(output).to include('# process start')
    expect(output).to include('Error parsing input')
    expect(output).to include('syntax error')
  end

  it 'rejects non-hash input' do
    input = <<~INPUT
      [1, 2, 3]


    INPUT

    output = IO.popen([executable, '--interactive'], 'r+') do |io|
      io.write(input)
      io.close_write
      io.read
    end

    expect(output).to include('# process start')
    expect(output).to include('Error parsing input: Input must be a Hash')
  end

  it 'works with Datadog provider', skip: 'requires network access' do
    input = <<~INPUT
      {
        test_metric: 42
      }


    INPUT

    output = IO.popen(
      { 'CODEMONITOR_PROVIDER' => 'datadog', 'DATADOG_API_KEY' => 'test_key' },
      [executable, '--interactive'],
      'r+'
    ) do |io|
      io.write(input)
      io.close_write
      io.read
    end

    expect(output).to include('# process start')
    expect(output).to include('codemonitor.test_metric: 42')
  end
end
