# coding: utf-8

require 'lex/lexer/rule_dsl'

module Lex
  class Lexer
    # Lexer DSL
    module DSL
      # Extend lexer class with DSL methods
      #
      # @api private
      def self.included(klass)
        klass.extend(ClassMethods)
      end

      # Class methods for a lexer
      #
      # @api private
      module ClassMethods
        # Set dsl for lexer
        #
        # @api private
        def inherited(klass)
          super

          klass.instance_variable_set('@dsl', nil)
        end

        # Return the rule DSL used by Lexer
        #
        # @api private
        def dsl
          @dsl ||= RuleDSL.new
        end

        # Delegate calls to RuleDSL
        #
        # @api private
        def method_missing(name, *args, &block)
          if dsl.respond_to?(name)
            dsl.public_send(name, *args, &block)
          else
            super
          end
        end
      end # ClassMethods
    end # DSL
  end # Lexer
end # Lex
