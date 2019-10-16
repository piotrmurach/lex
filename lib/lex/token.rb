# frozen_string_literal: true

require "forwardable"

require_relative "source_line"

module Lex
  # Used to represent the tokens produced
  class Token
    extend Forwardable

    attr_accessor :name, :value

    attr_reader :action

    def_delegators :@source_line, :line, :column

    def initialize(name, value, &action)
      @name        = name
      @value       = value
      @action      = action
      @source_line = SourceLine.new
    end

    def update_line(line, column)
      @source_line.line = line
      @source_line.column = column
    end

    # Return this token as array of values
    #
    # @return [Symbol, String, Integer, Integer]
    #
    # @api public
    def to_ary
      [name, value, line, column]
    end

    # Return a string representation
    #
    # @return String
    #
    # @api public
    def to_s
      "Lex::Token(#{to_ary.join(',')})"
    end
    alias_method :inspect, :to_s
  end # Token
end # Lex
