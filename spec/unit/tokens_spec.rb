# coding: utf-8

require 'spec_helper'

RSpec.describe Lex::Lexer, '#tokens' do
  it "requires a non-empty list tokens" do
    expect {
      stub_const('MyLexer', Class.new(Lex::Lexer) do
        tokens()
      end)
      MyLexer.new
    }.to raise_error(Lex::Linter::Failure, /No token list defined/)
  end

  it "requires a list of valid tokens" do
    expect {
      stub_const('MyLexer', Class.new(Lex::Lexer) do
        tokens(:"#token")
      end)
      MyLexer.new
    }.to raise_error(Lex::Linter::Failure, /Bad token name `#token`/)
  end

  it "doesn't allow for multiple same tokens" do
    expect {
      stub_const('MyLexer', Class.new(Lex::Lexer) do
        tokens(:token, :token)
      end)
      MyLexer.new
    }.to raise_error(Lex::Linter::Failure, /Token `token` already defined/)
  end
end
