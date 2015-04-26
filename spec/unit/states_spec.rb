# coding: utf-8

require 'spec_helper'

RSpec.describe Lex::Lexer, '#states' do

  it "checks states" do
    expect {
      stub_const('MyLexer', Class.new(Lex::Lexer) do
        tokens(:IDENTIFIER)

        states(foo: :unknown)
      end)
      MyLexer.new
    }.to raise_error(Lex::Linter::Failure, /State type for state foo must be/)
  end

  it "lexes ignoring :exclusive state tokens" do
    stub_const('MyLexer', Class.new(Lex::Lexer) do
      tokens(
        :IDENTIFIER,
        :LBRACE,
        :RBRACE
      )
      states( brace: :exclusive )

      rule(:IDENTIFIER, /a|b/)

      rule(:LBRACE, /{/) do |lexer, token|
        lexer.push_state(:brace)
        token
      end

      rule(:brace_RBRACE, /}/) do |lexer, token|
        lexer.pop_state
        token
      end

      error(:brace) do |lexer, token|
      end

      ignore(:brace, " \t")
    end)
    my_lexer = MyLexer.new
    expect(my_lexer.lex("a{bb}a").map(&:to_ary)).to eq([
      [:IDENTIFIER, 'a', 1, 1],
      [:LBRACE, '{', 1, 2],
      [:RBRACE, '}', 1, 5],
      [:IDENTIFIER, 'a', 1, 6]
    ])
  end

  it "lexes in :exclusive state" do
    stub_const('MyLexer', Class.new(Lex::Lexer) do
      tokens( :WORD )

      states( htmlcomment: :exclusive )

      rule(:WORD, /\w+/)

      rule(:htmlcomment, /<!--/) do |lexer, token|
        lexer.push_state(:htmlcomment)
      end

      rule(:htmlcomment_end, /-->/) do |lexer, token|
        lexer.pop_state
      end

      error(:htmlcomment) do |lexer, token|
      end

      ignore(:htmlcomment, " \t")

      ignore " \t"
    end)
    my_lexer = MyLexer.new
    expect(my_lexer.lex("hello <!-- comment --> world").map(&:to_ary)).to eq([
      [:WORD, 'hello', 1, 1],
      [:WORD, 'world', 1, 24]
    ])
  end

  it "warns about lack of error condition in :exclusive state" do
    stub_const('MyLexer', Class.new(Lex::Lexer) do
      tokens( :WORD )

      states( htmlcomment: :exclusive )

      rule(:WORD, /\w+/)

      rule(:htmlcomment_WORD, /\w+/)

      ignore " "
    end)
    expect {
      MyLexer.new
    }.to output(/No error rule is defined for exclusive state 'htmlcomment'/).
      to_stderr_from_any_process
  end

  it "warns about lack of ignore condition in :inclusive state" do
    stub_const('MyLexer', Class.new(Lex::Lexer) do
      tokens( :WORD )

      states( htmlcomment: :exclusive )

      rule(:WORD, /\w+/)

      rule(:htmlcomment_WORD, /\w+/)

      error(:htmlcomment)
    end)
    expect {
      MyLexer.new
    }.to output(/No ignore rule is defined for exclusive state 'htmlcomment'/).
      to_stderr_from_any_process
  end

  it "lexes in :inclusive state" do
    stub_const('MyLexer', Class.new(Lex::Lexer) do
      tokens( :WORD )

      states( htmlcomment: :inclusive )

      rule(:WORD, /\w+/)

      rule(:htmlcomment, /<!--/) do |lexer, token|
        lexer.push_state(:htmlcomment)
      end

      rule(:htmlcomment_end, /-->/) do |lexer, token|
        lexer.pop_state
      end

      error(:htmlcomment) do |lexer, token|
      end

      ignore(:htmlcomment, " \t")

      ignore " \t"
    end)
    my_lexer = MyLexer.new
    expect(my_lexer.lex("hello <!-- comment --> world").map(&:to_ary)).to eq([
      [:WORD, 'hello', 1, 1],
      [:WORD, 'comment', 1, 12],
      [:WORD, 'world', 1, 24]
    ])
  end

  it "includes error condition in :inclusive state" do
    stub_const('MyLexer', Class.new(Lex::Lexer) do
      tokens( :WORD )

      states( htmlcomment: :inclusive )

      rule(:WORD, /\w+/)

      rule(:htmlcomment, /<!--/) do |lexer, token|
        lexer.push_state(:htmlcomment)
      end

      rule(:htmlcomment_end, /-->/) do |lexer, token|
        lexer.pop_state
      end

      error do |lexer, token| end

      ignore " \t"
    end)
    my_lexer = MyLexer.new
    expect(my_lexer.lex("hello <!-- comment --> world").map(&:to_ary)).to eq([
      [:WORD, 'hello', 1, 1],
      [:WORD, 'comment', 1, 12],
      [:WORD, 'world', 1, 24]
    ])
  end

  it "complains if there are no rules for state" do
    stub_const('MyLexer', Class.new(Lex::Lexer) do
      tokens( :WORD )

      states( htmlcomment: :inclusive )

      rule(:WORD, /\w+/)

      error do |lexer, token| end

      ignore " \t"
    end)
    expect {
      MyLexer.new
    }.to raise_error(Lex::Linter::Failure, /No rules defined for state 'htmlcomment'/)
  end
end
