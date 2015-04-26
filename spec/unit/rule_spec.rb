# coding: utf-8

require 'spec_helper'

RSpec.describe Lex::Lexer, '#rule' do

  it "raises error with no rules" do
    expect {
      stub_const('MyLexer', Class.new(Lex::Lexer) do
        tokens(:ID)
      end)
      MyLexer.new
    }.to raise_error(Lex::Linter::Failure, /No rules of the form/)
  end

  it "skips rule that has action but doesn't return token" do
    stub_const('MyLexer', Class.new(Lex::Lexer) do
      tokens(
        :IDENTIFIER,
        :LBRACE,
        :RBRACE
      )

      rule(:IDENTIFIER, /a|b/)

      rule(:LBRACE, /{/) do |lexer, token|
      end

      rule(:RBRACE, /}/) do |lexer, token|
        token
      end
    end)
    my_lexer = MyLexer.new
    expect(my_lexer.lex("a{b}a").map(&:to_ary)).to eq([
      [:IDENTIFIER, 'a', 1, 1],
      [:IDENTIFIER, 'b', 1, 3],
      [:RBRACE, '}', 1, 4],
      [:IDENTIFIER, 'a', 1, 5]
    ])
  end

  it "validates uniquness" do
    expect {
      Class.new(Lex::Lexer) do
        tokens( :WORD )

        rule(:WORD, /\w+/)

        rule(:WORD, /\w+/)
      end
    }.to raise_error(Lex::LexerError, /Rule 'WORD' redefined./)
  end

  it "throws error if using token in rule without prior specifying" do
    expect {
      Class.new(Lex::Lexer) do
        tokens(:ID)

        rule(:UNKNOWN, /a/)
      end
    }.to raise_error(Lex::LexerError, /Rule 'UNKNOWN' defined for an unspecified token UNKNOWN/)
  end
end
