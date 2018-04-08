# frozen_string_literal: true

require 'logger'
require 'securerandom'
require 'json'

require 'roda'

require_relative 'logger/version'
require_relative 'logger/tee_logger'


class Roda
  module RodaPlugins
    module Logger
      def self.configure(
        app,
        level: ENV['LOG_LEVEL'] ||
          (ENV['RACK_ENV'] == 'production' ? :info : :debug),
        rotate: ENV['RACK_ENV'] == 'production' ? 'monthly' : nil,
        logger_instance: nil,
        proc: nil
      )
        logger = app.logger = logger_instance || (
          f = "log/#{ENV['RACK_ENV']}.log"
          development = ENV['RACK_ENV'] == 'development'
          development ? TeeLogger.create(f) : ::Logger.new(f, rotate)
        )
        logger.formatter ||= proc do |severity, datetime, progname, msg|
          "[#{datetime}] #{Thread.current['request_id']} "\
            "#{severity}#{progname && " #{progname}"} -- #{msg}\n"
        end
        logger.level = ::Logger.const_get(level.upcase)
        proc&.call logger
      end


      module ClassMethods
        attr_accessor :logger
      end


      module InstanceMethods
        def call(&block)
          start = Time.now
          logger = self.class.logger
          Thread.current[:request_id] = SecureRandom.uuid
          logger.info do
            params = @_request.params
            if params.any?
              param_str = "\nParams: #{JSON.pretty_generate params}"
            end
            "#{env['REQUEST_METHOD']} #{@_request.path}#{param_str}"
          end
          super
        rescue StandardError => e
          logger.error "#{e.message}\n#{e.backtrace.join("\n")}"
          raise
        ensure
          logger.info do
            time = (Time.now - start) * 1000
            "Finished #{@_response.status || 500} #{time.to_i}ms"
          end
        end
      end
    end


    register_plugin(:logger, Logger)
  end
end
