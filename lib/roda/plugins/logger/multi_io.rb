# frozen_string_literal: true

class Roda
  module RodaPlugins
    module Logger
      class MultiIO
        def initialize(*targets)
          @targets = targets
        end


        def write(*args)
          @targets.each { |t| t.write(*args) }
        end


        def close
          @targets.each(&:close)
        end
      end
    end
  end
end
