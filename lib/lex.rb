# coding: utf-8

require 'strscan'
require 'logger'
require 'forwardable'

require 'lex/logger'
require 'lex/linter'
require 'lex/lexeme'
require 'lex/source_line'
require 'lex/state'
require 'lex/token'
require 'lex/lexer'
require "lex/version"

module Lex
  # A base class for all Lexer errors
  class Error < StandardError; end

  # Raised when lexing fails
  class LexerError < Error; end
end # Lex
