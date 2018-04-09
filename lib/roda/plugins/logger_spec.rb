# frozen_string_literal: true

require 'pathname'

require 'spec_helper'


describe Roda::RodaPlugins::Logger do
  include Rack::Test::Methods

  before do
    FileUtils.rm_f 'log/test.log'
  end

  it 'has a version number' do
    ::Roda::RodaPlugins::Logger::VERSION.wont_be_nil
  end

  describe 'with default options' do
    let(:app) do
      create_app do
        plugin :logger

        route do |r|
          r.root { '' }
          r.get('should_raise') { wat }
          r.get('different') { r.response.status = '123' }
          r.post('post_endpoint') { '' }
        end
      end
    end

    it 'creates the log file on startup' do
      Pathname.new('log/test.log').wont_be :exist?
      app # creates the app
      Pathname.new('log/test.log').must_be :exist?
    end

    it 'logs handled requests' do
      get '/'
      lines = File.readlines('log/test.log')
      lines.count.must_equal 3
      lines[0].must_include 'Logfile created'
      lines[1].must_include 'INFO -- GET'
      lines[2].must_include 'INFO -- Finished 200'
    end

    it 'logs not found requests' do
      get '/does_not_exist'
      lines = File.readlines('log/test.log')
      lines.count.must_equal 3
      lines[0].must_include 'Logfile created'
      lines[1].must_include 'INFO -- GET'
      lines[2].must_include 'INFO -- Finished 404'
    end

    it 'logs error requests' do
      begin
        get '/should_raise'
      rescue StandardError
        lines = File.readlines('log/test.log')
        lines[0].must_include 'Logfile created'
        lines[1].must_include 'INFO -- GET'
        lines[2].must_include 'ERROR -- undefined'
        lines.last.must_include 'INFO -- Finished 500'
      end
    end

    it 'logs requests with other return statuses' do
      get '/different'
      lines = File.readlines('log/test.log')
      lines.count.must_equal 3
      lines[0].must_include 'Logfile created'
      lines[1].must_include 'INFO -- GET'
      lines[2].must_include 'INFO -- Finished 123'
    end

    it 'logs params' do
      get '/different?param1=hips&param2=dontlie'
      lines = File.readlines('log/test.log')
      lines.count.must_equal 7
      lines[0].must_include 'Logfile created'
      lines[1].must_include 'INFO -- GET'
      lines[2].must_equal "Params: {\n"
      lines[3].must_equal %(  \"param1\": \"hips\",\n)
      lines[4].must_equal %(  \"param2\": \"dontlie\"\n)
      lines[5].must_equal "}\n"
      lines[6].must_include 'INFO -- Finished 123'
    end
  end

  describe 'with proc' do
    before do
      create_app do
        plugin :logger, proc: ->(logger) { logger.info "hips don't lie" }
      end
    end

    it 'calls the given proc passing the logger as argument' do
      lines = File.readlines('log/test.log')
      lines.last.must_be :include?, "hips don't lie"
    end
  end

  describe 'with logger_instance' do
    let(:stream) { StringIO.new }
    let(:app) do
      l = Logger.new stream
      l.formatter = proc { "hips don't lie" }
      create_app do
        plugin :logger, logger_instance: l
        route {}
      end
    end

    it 'uses the given logger object to log' do
      get '/'
      stream.string.must_be :include?, "hips don't lie"
    end
  end

  describe 'with log level' do
    let(:app) do
      create_app do
        plugin :logger, level: :warn
      end
    end

    it 'only logs requests of equal or higher level' do
      app.logger.info "hips don't lie"
      File.readlines('log/test.log').length.must_equal 1
      app.logger.warn "hips don't lie"
      lines = File.readlines('log/test.log')
      lines.length.must_equal 2
      lines.last.must_be :include?, "hips don't lie"
    end
  end
end
