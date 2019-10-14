# coding: utf-8

require 'lex/lexer/dsl'

module Lex
  # An abstract lexer that doesn't provide any lexing rules.
  #
  # @api public
  class Lexer
    extend Forwardable
    include DSL

    attr_reader :input,
                :logger,
                :debug,
                :current_state,
                :current_line

    def_delegators :@dsl,
                   :lex_tokens,
                   :state_info,
                   :state_re,
                   :state_names,
                   :state_ignore,
                   :state_error,
                   :state_lexemes

    def initialize(options = {}, &block)
      rewind

      @logger           = Lex::Logger.new
      @linter           = Lex::Linter.new
      @debug            = options[:debug]
      @dsl              = self.class.dsl

      @dsl.instance_eval(&block) if block
      @linter.lint(self)
    end

    # Tokenizes input and returns all tokens
    #
    # @param [String] input
    #
    # @return [Enumerator]
    #   the tokens found
    #
    # @api public
    def lex(input)
      @input = input

      return enum_for(:lex, input) unless block_given?

      if debug
        logger.info "lex: tokens   = #{@dsl.lex_tokens}"
        logger.info "lex: states   = #{@dsl.state_info}"
        logger.info "lex: ignore   = #{@dsl.state_ignore}"
        logger.info "lex: error    = #{@dsl.state_error}"
      end

      stream_tokens(input) do |token|
        yield token
      end
    end

    # Advances through input and streams tokens
    #
    # @param [String] input
    #
    # @yield [Lex::Token]
    #
    # @api public
    def stream_tokens(input, &block)
      scanner = StringScanner.new(input)
      while !scanner.eos?
        current_char = scanner.peek(1)
        if @dsl.state_ignore[current_state].include?(current_char)
          scanner.pos += current_char.size
          @char_pos_in_line += current_char.size
          next
        end

        if debug
          logger.info "lex: [#{current_state}]: lexemes = #{@dsl.state_lexemes[current_state].map(&:name)}"
        end
        # Look for regex match
        longest_token = nil
        @dsl.state_lexemes[current_state].each do |lexeme|
          match = lexeme.match(scanner)
          next if match.nil?
          longest_token = match if longest_token.nil?
          next if longest_token.value.length >= match.value.length
          longest_token = match
        end

        if longest_token
          longest_token_value_length = longest_token.value.length
          if longest_token.action
            new_token = longest_token.action.call(self, longest_token)
            # No value returned from action move to the next token
            if new_token.nil? || !new_token.is_a?(Token)
              chars_to_skip = longest_token_value_length
              scanner.pos += chars_to_skip
              unless longest_token.name == :newline
                @char_pos_in_line += chars_to_skip
              end
              next
            end
          end
          move_by = longest_token_value_length
          start_char_pos_in_token = @char_pos_in_line + current_char.size
          longest_token.update_line(current_line, start_char_pos_in_token)
          advance_column(move_by)
          scanner.pos += move_by
        end

        # No match
        if longest_token.nil?
          # Check in errors
          if @dsl.state_error[current_state]
            token = Token.new(:error, current_char)
            start_char_pos_in_token = @char_pos_in_line + current_char.size
            token.update_line(current_line, start_char_pos_in_token)
            new_token = @dsl.state_error[current_state].call(self, token)
            advance_column(current_char.length)
            scanner.pos += current_char.length
            if new_token.is_a?(Token) || !new_token.nil?
              longest_token = new_token
            else
              next
            end
          end

          if longest_token.nil?
            complain("Illegal character `#{current_char}`")
          end
        end

        logger.info "lex: #{longest_token}" if debug
        block.call(longest_token)
      end
    end

    # Switches the state
    #
    # @param [Symbol] state
    #   the name of the state
    #
    # @api public
    def begin(state)
      unless @dsl.state_info.key?(state)
        complain("Undefined state: #{state}")
      end
      @current_state = state
    end

    # Enter new state and save old one on stack
    #
    # @param [Symbol] state
    #   the name of the state
    #
    # @api public
    def push_state(state)
      @state_stack << @current_state
      self.begin(state)
    end

    # Restore previous state
    #
    # @param [Symbol] state
    #   the name of the state
    #
    # @api public
    def pop_state
      self.begin(@state_stack.pop)
    end

    # Skip ahead n characters
    #
    # @api public
    def skip(n)
      @current_pos += n
    end

    def advance_line(value)
      @current_line += value
      @char_pos_in_line = 0
    end

    def advance_column(value)
      @char_pos_in_line += value
    end

    # Reset the internal state of the lexer
    # @api public
    def rewind
      @current_line     = 1
      @current_pos      = 1 # Position in input
      @char_pos_in_line = 0
      @current_state    = :initial
      @state_stack      = []
    end

    private

    # @api private
    def complain(*args)
      raise LexerError, *args
    end
  end # Lexer
end # Lex
