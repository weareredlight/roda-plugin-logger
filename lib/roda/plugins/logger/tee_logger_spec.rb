# frozen_string_literal: true

require 'securerandom'

require 'spec_helper'

class Roda
  module RodaPlugins
    module Logger
      describe TeeLogger do
        let(:s) { StringIO.new }
        let(:log_path) { "/tmp/tee_logger_spec_#{SecureRandom.uuid}.tmp" }
        let(:tee) { TeeLogger.create(log_path) }

        before do
          STDOUT = s
        end

        describe '.create' do
          it 'returns a Ruby Logger instance' do
            tee.is_a? ::Logger
          end
        end

        it 'writes to STDOUT and the given log file' do
          tee.info 'wat up dawg?'
          s.string.must_include 'wat up dawg?'
          File.read(log_path).must_include 'wat up dawg?'
        end
      end
    end
  end
end
