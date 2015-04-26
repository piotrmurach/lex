# coding: utf-8

module Lex
  # Represents token definition
  class Lexeme
    attr_reader :name, :pattern, :action

    def initialize(name, pattern, &action)
      @name    = name
      @pattern = pattern
      @action  = action
    end

    def match(scanner)
      match = scanner.check(pattern)
      if match
        return Token.new(name, match.to_s, &action)
      end
      match
    end

    # @api public
    def ==(other)
      @name == other.name
    end
  end # Lexeme
end # Lex
