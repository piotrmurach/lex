# frozen_string_literal: true

require_relative "lex/lexer"
require_relative "lex/version"

module Lex
  # A base class for all Lexer errors
  class Error < StandardError; end

  # Raised when lexing fails
  class LexerError < Error; end
end # Lex
