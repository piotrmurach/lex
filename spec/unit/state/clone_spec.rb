# frozen_string_literal: true

RSpec.describe Lex::State, "#clone" do
  it "clones state instance" do
    lexeme = instance_double("Lexeme")
    lexemes = [lexeme, lexeme]
    state = described_class.new(:initial, lexemes)
    new_state = state.clone

    expect(new_state).not_to eql(state)
    expect(new_state.lexemes).not_to eql(state.lexemes)
  end
end
