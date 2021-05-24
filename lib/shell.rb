# frozen_string_literal: true

class Shell
  def self.run(command)
    `#{command}`.strip
  end
end
