# frozen_string_literal: true

module Lex
  # A class responsible for checking lexer definitions
  #
  # @api public
  class Linter
    IDENTIFIER_RE = /^[a-zA-Z0-9]+$/.freeze

    # Failure raised by +complain+
    Failure = Class.new(StandardError)

    # Run linting of lexer
    #
    # @param [Lex::Lexer]
    #
    # @raise [Lex::Linter::Failure]
    #
    # @api public
    def lint(lexer)
      validate_tokens(lexer)
      validate_states(lexer)
      validate_rules(lexer)
    end

    private

    # Check if token has valid name
    #
    # @param [Symbol,String] value
    #   token to check
    #
    # @return [Boolean]
    #
    # @api private
    def identifier?(value)
      value =~ IDENTIFIER_RE
    end

    # Validate provided tokens
    #
    # @api private
    def validate_tokens(lexer)
      if lexer.lex_tokens.empty?
        complain("No token list defined")
      end
      if !lexer.lex_tokens.respond_to?(:to_ary)
        complain("Tokens must be a list or enumerable")
      end

      terminals = []
      lexer.lex_tokens.each do |token|
        if !identifier?(token)
          complain("Bad token name `#{token}`")
        end
        if terminals.include?(token)
          complain("Token `#{token}` already defined")
        end
        terminals << token
      end
    end

    # Validate provided state names
    #
    # @api private
    def validate_states(lexer)
      if !lexer.state_info.respond_to?(:each_pair)
        complain("States must be defined as a hash")
      end

      lexer.state_info.each do |state_name, state_type|
        if ![:inclusive, :exclusive].include?(state_type)
          complain("State type for state #{state_name}" \
                   " must be :inclusive or :exclusive")
        end

        if state_type == :exclusive
          if !lexer.state_error.key?(state_name)
            lexer.logger.warn("No error rule is defined " \
                              "for exclusive state '#{state_name}'")
          end
          if !lexer.state_ignore.key?(state_name)
            lexer.logger.warn("No ignore rule is defined " \
                              "for exclusive state '#{state_name}'")
          end
        end
      end
    end

    # Validate rules
    #
    # @api private
    def validate_rules(lexer)
      if lexer.state_re.empty?
        complain("No rules of the form rule(name, pattern) are defined")
      end

      lexer.state_info.each do |state_name, state_type|
        if !lexer.state_re.key?(state_name.to_sym)
          complain("No rules defined for state '#{state_name}'")
        end
      end
    end

    # Raise a failure if validation of a lexer fails
    #
    # @raise [Lex::Linter::Failure]
    #
    # @api private
    def complain(*args)
      raise Failure, *args
    end
  end # Linter
end # Lex
