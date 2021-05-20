module Providers
  class Console
    def initialize
      @pending = {}
      puts '# process start'
    end

    def emit(metrics)
      @pending = pending.merge(metrics)
    end

    def send
      pending.map do |metric, value|
        puts "#{metric}: #{value}"
      end
      puts '# process complete'
    end

    private

    attr_reader :pending
  end
end
