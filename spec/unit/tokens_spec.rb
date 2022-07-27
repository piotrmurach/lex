# frozen_string_literal: true

RSpec.describe Lex::Lexer, "#tokens" do
  it "requires a non-empty list tokens" do
    expect {
      stub_const("MyLexer", Class.new(described_class) do
        tokens
      end)
      MyLexer.new
    }.to raise_error(Lex::Linter::Failure, /No token list defined/)
  end

  it "requires a list of valid tokens" do
    expect {
      stub_const("MyLexer", Class.new(described_class) do
        tokens(:"#token")
      end)
      MyLexer.new
    }.to raise_error(Lex::Linter::Failure, /Bad token name `#token`/)
  end

  it "doesn't allow for multiple same tokens" do
    expect {
      stub_const("MyLexer", Class.new(described_class) do
        tokens(:token, :token)
      end)
      MyLexer.new
    }.to raise_error(Lex::Linter::Failure, /Token `token` already defined/)
  end
end
