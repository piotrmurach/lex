# frozen_string_literal: true

RSpec.describe Lex::Lexer, 'position' do
  it "calculates line number and position info from input" do
    code = unindent(<<-EOS)
      x = 1
      y = 2
      s = x + y
    EOS

    stub_const('MyLexer', Class.new(Lex::Lexer) do
      tokens(
        :NUMBER,
        :PLUS,
        :IDENTIFIER,
        :EQUALS
      )

      rule(:PLUS,   /\+/)
      rule(:EQUALS, /=/)
      rule(:IDENTIFIER, /[_\$a-zA-Z][_\$0-9a-zA-Z]*/)

      rule(:NUMBER, /[0-9]+/) do |lexer, token|
        token.value = token.value.to_i
        token
      end

      ignore " \t"

      rule(:newline, /\n+/) do |lexer, token|
        lexer.advance_line(token.value.length)
      end
    end)

    my_lexer = MyLexer.new
    expect(my_lexer.lex(code).map(&:to_ary)).to eq([
      [:IDENTIFIER, 'x', 1, 1],
      [:EQUALS, '=', 1, 3],
      [:NUMBER, 1, 1, 5],
      [:IDENTIFIER, 'y', 2, 1],
      [:EQUALS, '=', 2, 3],
      [:NUMBER, 2, 2, 5],
      [:IDENTIFIER, 's', 3, 1],
      [:EQUALS, '=', 3, 3],
      [:IDENTIFIER, 'x', 3, 5],
      [:PLUS, '+', 3, 7],
      [:IDENTIFIER, 'y', 3, 9]
    ])
  end

  it "correctly tracks multiline content" do
    code = unindent(<<-EOS)
      This is
         <b>webpage!</b>
    EOS
    stub_const('MyLexer', Class.new(Lex::Lexer) do
      tokens(
        :WORD,
        :LANGLE,
        :RANGLE,
        :LANGLESLASH
      )

      rule(:WORD, /[^ <>\n]+/)
      rule(:LANGLE, /</)
      rule(:RANGLE, />/)
      rule(:LANGLESLASH, /<\//)

      rule(:newline, /\n/) do |lexer, token|
        lexer.advance_line(token.value.size)
      end

      ignore " "

      error do |lexer, token|
      end
    end)

    my_lexer = MyLexer.new
    expect(my_lexer.lex(code).map(&:to_ary)).to eq([
      [:WORD, 'This', 1, 1],
      [:WORD, 'is', 1, 6],
      [:LANGLE, '<', 2, 4],
      [:WORD, 'b', 2, 5],
      [:RANGLE, '>', 2, 6],
      [:WORD, 'webpage!', 2, 7],
      [:LANGLESLASH, '</', 2, 15],
      [:WORD, 'b', 2, 17],
      [:RANGLE, '>', 2, 18]
    ])
  end
end
