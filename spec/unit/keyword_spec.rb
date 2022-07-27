# frozen_string_literal: true

RSpec.describe Lex::Lexer, ".keywords" do
  it "allows to easily create keyword tokens" do
    stub_const("MyLexer", Class.new(described_class) do
      def self.keywords
        {
          if: :IF,
          then: :THEN,
          else: :ELSE,
          while: :WHILE
        }
      end

      tokens(:IDENTIFIER, *keywords.values)

      rule(:IDENTIFIER, /[_[:alpha:]][_[:alnum:]]*/) do |lexer, token|
        token.name = lexer.class.keywords.fetch(token.value.to_sym, :IDENTIFIER)
        token
      end

      ignore(" ")
    end)
    my_lexer = MyLexer.new

    expect(my_lexer.lex("if then else").map(&:to_ary)).to eq([
      [:IF, "if", 1, 1],
      [:THEN, "then", 1, 4],
      [:ELSE, "else", 1, 9]
    ])
  end
end
