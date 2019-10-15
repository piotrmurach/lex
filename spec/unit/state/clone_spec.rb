# frozen_string_literal: true

RSpec.describe Lex::State, '.clone' do
  it "clones state instance" do
    lexeme = double(:lexeme)
    lexemes = [lexeme, lexeme]
    state = Lex::State.new(:initial, lexemes)
    new_state = state.clone

    expect(new_state).to_not eql(state)
    expect(new_state.lexemes).to_not eql(state.lexemes)
  end
end
