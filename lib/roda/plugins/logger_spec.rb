# frozen_string_literal: true

require 'pathname'

require 'spec_helper'


describe Roda::RodaPlugins::Logger do
  let(:app) do
    dummy_app do
      plugin :logger

      route do |r|
        r.root { '' }
        r.get('should_raise') { wat }
        r.get('different') { r.response.status = '123' }
        r.post('post_endpoint') { '' }
      end
    end
  end

  before do
    FileUtils.rm_f 'log/test.log'
  end

  it 'has a version number' do
    ::Roda::RodaPlugins::Logger::VERSION.wont_be_nil
  end

  describe 'with default options' do
    it 'creates the log file on startup' do
      Pathname.new('log/test.log').wont_be :exist?
      app # creates the app
      Pathname.new('log/test.log').must_be :exist?
    end

    it 'logs handled requests' do
      req
      lines = File.readlines('log/test.log')
      lines.count.must_equal 3
      lines[0].must_include 'Logfile created'
      lines[1].must_include 'INFO -- GET'
      lines[2].must_include 'INFO -- Finished 200'
    end

    it 'logs not found requests' do
      req '/does_not_exist'
      lines = File.readlines('log/test.log')
      lines.count.must_equal 3
      lines[0].must_include 'Logfile created'
      lines[1].must_include 'INFO -- GET'
      lines[2].must_include 'INFO -- Finished 404'
    end

    it 'logs error requests' do
      begin
        req '/should_raise'
      rescue StandardError
        lines = File.readlines('log/test.log')
        lines[0].must_include 'Logfile created'
        lines[1].must_include 'INFO -- GET'
        lines[2].must_include 'ERROR -- undefined'
        lines.last.must_include 'INFO -- Finished 500'
      end
    end

    it 'logs requests with other return statuses' do
      req '/different'
      lines = File.readlines('log/test.log')
      lines.count.must_equal 3
      lines[0].must_include 'Logfile created'
      lines[1].must_include 'INFO -- GET'
      lines[2].must_include 'INFO -- Finished 123'
    end

    it 'logs requests with other return statuses' do
      req '/different'
      lines = File.readlines('log/test.log')
      lines.count.must_equal 3
      lines[0].must_include 'Logfile created'
      lines[1].must_include 'INFO -- GET'
      lines[2].must_include 'INFO -- Finished 123'
    end
  end
end
