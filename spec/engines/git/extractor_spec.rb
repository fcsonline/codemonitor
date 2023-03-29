# frozen_string_literal: true

require_relative '../../../engines/git/extractor'
require_relative '../../../providers/test'
require_relative '../../../lib/shell'

RSpec.describe Engines::Git::Extractor do
  let(:provider) { Providers::Test.new }

  def output(times, token)
    (1..times).map { "#{token}\n" }.join
  end

  subject do
    described_class.new.call(provider)
    provider.pending.transform_keys(&:to_sym)
  end

  it 'emits all the expected metrics' do
    expect(Shell).to receive(:run).with("git log --format='%h'").and_return(output(2, 'commit'))
    expect(Shell).to receive(:run).with('git ls-remote -q').and_return(output(3, 'refs/heads/foo'))
    expect(Shell).to receive(:run).with('git ls-remote -q').and_return(output(4, 'refs/tags/foo'))
    expect(Shell).to receive(:run).with("git log --format='%aN'").and_return(output(5, 'paco'))
    expect(Shell).to receive(:run).with('git ls-tree -r HEAD --name-only').and_return(output(6, 'file'))
    expect(Shell).to receive(:run).with('git check-ignore *').and_return(output(7, 'ignore'))
    expect(Shell).to receive(:run).with('git ls-files').twice.and_return(output(2, 'content'))
    expect(File).to receive(:read).twice.with(File.expand_path('content', Dir.pwd)).and_return(output(10, 'line'))

    expect(subject).to include(
      git_number_of_commits: 2,
      git_number_of_branches: 3,
      git_number_of_tags: 4,
      git_number_of_contributors: 1,
      git_number_of_files: 6,
      git_number_of_ignores_files: 7,
      git_number_of_lines: 10 * 2
    )
  end
end
