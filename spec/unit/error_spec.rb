# frozen_string_literal: true

RSpec.describe Lex::Lexer, '#error' do

  it "registers error handler" do
    stub_const('MyLexer', Class.new(Lex::Lexer) do
      tokens(:IDENTIFIER)

      rule(:IDENTIFIER, /a|b/)

      error do |lexer, token|
        token
      end

      ignore " \t"
    end)
    my_lexer = MyLexer.new
    expect(my_lexer.lex("a(b)a").map(&:to_ary)).to eq([
      [:IDENTIFIER, 'a', 1, 1],
      [:error, '(', 1, 2],
      [:IDENTIFIER, 'b', 1, 3],
      [:error, ')', 1, 4],
      [:IDENTIFIER, 'a', 1, 5]
    ])
  end

  it "raises error without error handler" do
    stub_const('MyLexer', Class.new(Lex::Lexer) do
      tokens(:IDENTIFIER)

      rule(:IDENTIFIER, /a|b/)

      ignore " \t"
    end)
    my_lexer = MyLexer.new
    expect {
      my_lexer.lex("a(b)a").to_a
    }.to raise_error(Lex::LexerError, /Illegal character `\(`/)
  end
end
