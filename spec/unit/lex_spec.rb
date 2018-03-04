# coding: utf-8

require 'spec_helper'

RSpec.describe Lex::Lexer, 'lex' do

  it "tokenizes simple input" do
    code = unindent(<<-EOS)
      x = 5 + 44 * (s - t)
    EOS

    stub_const('MyLexer', Class.new(Lex::Lexer) do
      tokens(
        :NUMBER,
        :PLUS,
        :MINUS,
        :TIMES,
        :DIVIDE,
        :LPAREN,
        :RPAREN,
        :EQUALS,
        :IDENTIFIER
      )

      rule(:PLUS,   /\+/)
      rule(:MINUS,  /\-/)
      rule(:TIMES,  /\*/)
      rule(:DIVIDE, /\//)
      rule(:LPAREN, /\(/)
      rule(:RPAREN, /\)/)
      rule(:EQUALS, /=/)
      rule(:IDENTIFIER, /[_\$a-zA-Z][_\$0-9a-zA-Z]*/)

      rule(:NUMBER, /[0-9]+/) do |lexer, token|
        token.value = token.value.to_i
        token
      end

      rule(:newline, /\n+/) do |lexer, token|
        lexer.advance_line(token.value.length)
      end

      ignore " \t"
    end)
    my_lexer = MyLexer.new
    expect(my_lexer.lex(code).map(&:to_ary)).to eq([
      [:IDENTIFIER, 'x', 1, 1],
      [:EQUALS, '=', 1, 3],
      [:NUMBER, 5, 1, 5],
      [:PLUS, '+', 1, 7],
      [:NUMBER, 44, 1, 9],
      [:TIMES, '*', 1, 12],
      [:LPAREN, '(', 1, 14],
      [:IDENTIFIER, 's', 1, 15],
      [:MINUS, '-', 1, 17],
      [:IDENTIFIER, 't', 1, 19],
      [:RPAREN, ')', 1, 20]
    ])
  end
end
