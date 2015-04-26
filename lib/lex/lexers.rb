# coding: utf-8

require 'lex'

# Lexer implementations
#
# @note This file is not normally available. You must require
# `lex/lexers` to load it.

lexers = ::File.expand_path(::File.join('..', 'lexers'), __FILE__)
$LOAD_PATH.unshift(lexers) unless $LOAD_PATH.include?(lexers)
