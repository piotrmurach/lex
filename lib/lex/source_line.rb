# frozen_string_literal: true

module Lex
  # Lexer tokens' source line
  class SourceLine
    attr_accessor :line, :column

    def initialize(line = 1, column = 1)
      @line   = line
      @column = column
    end
  end # SourceLine
end # Lex
