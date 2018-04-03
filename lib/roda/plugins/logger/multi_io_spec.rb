# frozen_string_literal: true

require 'spec_helper'

class Roda
  module RodaPlugins
    module Logger
      describe MultiIO do
        let(:s1) { StringIO.new }
        let(:s2) { StringIO.new }
        let(:io) { MultiIO.new(s1, s2) }

        describe '#write' do
          it 'writes to both IO streams' do
            io.write 'wat up dawg?'
            s1.string.must_equal 'wat up dawg?'
            s2.string.must_equal 'wat up dawg?'
          end
        end

        describe '#close' do
          it 'closes both IO streams' do
            io.close
            s1.must_be :closed?
            s2.must_be :closed?
          end
        end
      end
    end
  end
end
