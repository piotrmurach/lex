# frozen_string_literal: true

require "logger"

module Lex
  class Logger
    def initialize(logger = nil)
      @logger = ::Logger.new(STDERR)
    end

    def info(message)
      @logger.info(message)
    end

    def error(message)
      @logger.error(message)
    end

    def warn(message)
      @logger.warn(message)
    end
  end # Logger
end # Lex
