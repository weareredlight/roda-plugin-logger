# frozen_string_literal: true

require_relative 'multi_io'

class Roda
  module RodaPlugins
    module Logger
      class TeeLogger
        def self.create(path)
          f = File.open(path, 'a')
          f.sync = true
          ::Logger.new(MultiIO.new(STDOUT, f))
        end
      end
    end
  end
end
