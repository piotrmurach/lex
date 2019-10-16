# frozen_string_literal: true

module Lex
  class State
    include Enumerable

    attr_reader :name, :lexemes

    def initialize(name, lexemes = [])
      @name = name
      @lexemes = lexemes
    end

    def each(&block)
      @lexemes.each(&block)
    end

    def <<(lexeme)
      @lexemes << lexeme
    end

    def update(values)
      values.each do |lexeme|
        lexemes << lexeme unless lexemes.include?(lexeme)
      end
    end

    def ==(other)
      @name == other.name &&
      @lexemes == other.lexemes
    end

    def clone
      self.class.new(@name, @lexemes.map(&:clone))
    end
  end # State
end # Lex
