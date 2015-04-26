# Lex

> Lex is an implementation of complier construction tool lex in Ruby. The goal is to stay close to the way the original tool works and combine it with the expressivness of Ruby.

## Features
* Very focused tool that mimics the basic lex functionality.
* 100% Ruby implementation.
* Provides comprehensive error reporting to assist in lexer construction.

## Installation

Add this line to your application's Gemfile:

```ruby
gem 'lex'
```

And then execute:

    $ bundle

Or install it yourself as:

    $ gem install lex

## Contents

* [1 Overview](#1-overview)
* [1.1 Example](#11-example)
* [1.2 Tokens list](#12-tokens-list)
* [1.3 Specifying rules](#13-specifying-rules)
* [1.4 Handling keywords](#14-handling-keywords)
* [1.5 Token values](#15-token-values)
* [1.6 Discarded tokens](#16-discarded-tokens)
* [1.7 Line numbers](#17-line-numbers)
* [1.8 Ignored characters](#18-ignored-characters)
* [1.9 Literal characters](#29-literal-characters)
* [1.10 Error handling](#110-error-handling)
* [1.11 Building the lexer](#111-building-the-lexer)
* [1.12 Maintaining state](#112-maintaining-state)
* [1.13 Conditional lexing](#113-conditional-lexing)
* [1.14 Debugging](#114-debugging)

## 1. Overview

**Lex** is a library that processes character input streams. For example, suppose you have the following input string:

```ruby
x = 5 + 44 * (s - t)
```

**Lex** then partitions the input string into tokens that match a series of regular expression rules. In this instance given the tokens definitions:

```ruby
:ID, :EQUALS, :NUMBER, :PLUS, :TIMES, :LPAREN, :RPAREN, :MINUS
```

the output will contain the following tokens:

```ruby
[:ID, 'x', 1, 1], [:EQUALS, '=', 1, 3], [:NUMBER, '5', 1, 5],
[:PLUS, '+', 1, 7], [:NUMBER, 44, 1, 9], [:TIMES, '*', 1, 12],
[:LPAREN, '(', 1, 14], [:ID, 's', 1, 15], [:MINUS, '-', 1, 17],
[:ID, 't', 1, 19], [:RPAREN, ')', 1, 20]
```

The **Lex** rules specified in the lexer will determine how the chunking of the input is performed. The following example demonstrates a high level overview of how this is done.

### 1.1 Example

Given an input:

```ruby
x = 5 + 44 * (s - t)
```

and a simple tokenizer:

```ruby
class MyLexer < Lex::Lexer
  tokens(
    :NUMBER,
    :PLUS,
    :MINUS,
    :TIMES,
    :DIVIDE,
    :LPAREN,
    :RPAREN,
    :EQUALS,
    :IDENTIFIER
  )

  # Regular expression rules for simple tokens
  rule(:PLUS,   /\+/)
  rule(:MINUS,  /\-/)
  rule(:TIMES,  /\*/)
  rule(:DIVIDE, /\//)
  rule(:LPAREN, /\(/)
  rule(:RPAREN, /\)/)
  rule(:IDENTIFIER, /\A[_\$a-zA-Z][_\$0-9a-zA-Z]*/)

  # A regular expression rules with actions
  rule(:NUMBER, /[0-9]+/) do |lexer, token|
    token.value = token.value.to_i
    token
  end

  # Define a rule so we can track line numbers
  rule(:newline, /\n+/) do |lexer, token|
    lexer.advance_line(token.value.length)
  end

  # A string containing ignored characters (spaces and tabs)
  ignore " \t"

  error do |lexer, token|
    puts "Illegal character: #{value}"
  end
end

# build the lexer
my_lexer = MyLexer.new
```

To use the lexer you need to provide it some input using the `lex` method. After that, the method `lex` will either yield tokens to a given block or return an enumereator to allow you to retrieve tokens by repeatedly calling `next` method.

```ruby
input = "x = 5 + 44 * (s - t)"
output = my_lexer.lex(input)
output.next  # =>  Lex::Token(:ID,'x', 1, 1)
output.next  # =>  Lex::Token[:EQUALS, '=', 1, 3]
output.next  # =>  Lex::Token[:NUMBER, '5', 1, 5]
...
```

The tokens returned by the lexer are instances of `Lex::Token`. This object has attributes such as `name`, `value`, `line` and `column`.

### 1.2 Tokens list

A lexer always requires a list of tokens that define all the possible token names that can be produced by the lexer. This list is used to perform validation checks.

The following list is an example of token names:

```ruby
tokens(
  :NUMBER,
  :PLUS,
  :MINUS,
  :TIMES,
  :DIVIDE,
  :LPAREN,
  :RPAREN
)
```

### 1.3 Specifying rules

Each token is specified by writting a regular expression rule defined by by calling the `rule` method. For simple tokens you can just specify the name and regular expression:

```ruby
rule(:PLUS, /\+/)
```

In this case, the first argument is the name of the token that needs to match exactly one of the names supplied in `tokens`. If you need to perform further processing on the matched token, the rule can be further expaned by adding an action inside a block. For instance, this rule matches numbers and converts the matched string into integer type:

```ruby
token(:NUMBER, /\d+/) do |lexer, token|
  token.value = token.value.to_i
  token
end
```

The action block always takes two arguments, the first being the lexer itself and the second the token which is an instance of `Lex::Token`. This object has attributes of `name` which is the token name as string, `value` which is the actual text matched, `line` which is the current line indexed from `1`, `column` which is the position of the token in relation to the current line. By default the `name` is set to the rule name. Inside the block you can modify the token object properties. However, when you change token properties, the token itself needs to be returned. If no value is returned by the action block, the token is simply discarded and lexer moves to another token.

The rules are processed in the same order as they appear in the lexer definition. Therefore, if you wanted to have a separate tokens for "=" and "==", you need to ensure that rule for matching "==" is checked first.

### 1.4 Handling keywords

In order to handle keywords, you should write a single rule to match an identifier and then do a name lookup like so:

```ruby
def self.keywords
  {
    if: :IF,
    then: :THEN,
    else: :ELSE,
    while: WHILE,
    ...
  }
end

tokens(:IDENTIFIER, *keywords.values)

rule(:IDENTIFIER, /\w[\w\d]*/) do |lexer, token|
  token.name = lexer.class.keywords.fetch(token.value.to_sym, :IDENTIFIER
  token
end
```

### 1.5 Token values

By default token value is the text that was matched by the rule. However, the token value can be changed to any object. For example, when processing identifiers you may wish to return both identifier name and actual value.

```ruby
rule(:IDENTIFIER, /\w[\w\d]*/) do |lexer, token|
  token.value = [token.value, lexer.class.keywords[token.value]]
  token
end
```

### 1.6 Discarded tokens

To discard a token, such as comment, define a rule that returns no token. For instance:

```ruby
rule(:COMMENT, /\#.*/) do |lexer, token|
  
end
```

### 1.7 Line numbers

By default **Lex** knows nothing about line numbers since it doesn't understand what a "line" is. To provide this information you need to add a special rule called `:newline`:

```ruby
rule(:newline, /\n+/) do |lexer, token|
  lexer.advance_line(token.value.length)
end
```

Calling the `advance_line` method the `current_line` is updated for the underlying lexer. Only the line is updated and since no token is returned the value is discarded.

**Lex** performs automatic column tracking for each token. This information is available by calling `column` on a `Lex::Token` instance.

### 1.8 Ignored characters

For any character that should be completely ignored in the input stream use the `ignore` rule. Usually this is used to skip over whitespace and other non-essential characters. For example:

```ruby
ignore = " \t" # => Ignore whitespace and tabs
```

You could create a rule to achieve similar behaviour, however you are encourage to use this method as it has increased performance over the rule regular expression matching.

### 1.9 Literal characters

Not implemented yet!

### 1.10 Error handling

In order to handle lexing error conditions use the `error` method. In this case thetoken `value` attribute contains the offending string. For example:

```ruby
error do |lexer, token|
  puts "Illegal character #{token.value}"
end
```

The lexer automatically skips the offending character and increments the column count.

When performing conditional lexing, you can handle errors per state like so:

```ruby
error :foo do |lexer, token|
  puts "Illegal character #{token.value}"
end
```

### 1.11 Building the lexer

```ruby
require 'lex'

class MyLexer < Lex::Lexer
  # required list of tokens
  tokens(
    :NUMBER,
  )
  ...
end

```

You can also provide lexer definition by using block:

```ruby
my_lexer = Lex::Lexer.new do
  # required list of tokens
  tokens(
    :NUMBER,
  )
end
```

### 1.12 Maintaining state

In your lexer you may have a need to store state information.

### 1.13 Conditional lexing

A lexer can maintain internal lexing state. When lexer's state changes, the corresponding tokens for that state are only considered. The start condition is called `:initial`, similar to GNU flex.

To define a new lexical state, it must first be declared. This can be achieved by using a `states` declaration:

```ruby
states(
  foo: :exclusive,
  bar: :inclusive
)
```

The above definition declares two states `:foo` and `:bar`. State may be of two types `:exclusive` and `:inclusive`. In an `:exclusive` state lexer contains no rules, which means that **Lex** will only return tokens and apply rules defined specifically for that state. On the other hand, an `:inclusive` state adds additional tokens and rules to the default set of rules. Thus, `lex` method will return both the tokens defined by default in addition to those defined specificially for the `:inclusive` state.

Once state has been declared, tokens and rules are declared by including the state name in token or rule definition. For example:

```ruby
rule(:foo_NUMBER, /\d+/)
rule(:bar_ID, /[a-z][a-z0-9]+/)
```

The above rules define `:NUMBER` token in state `:foo` and `:ID` token in state `:bar`.

A token can be specified in multiple states by prefixing token name by state names like so:

```ruby
rule(:foo_bar_NUMBER, /\d+/)
```

If no state information is provided, the lexer is assumed to be in `:initial` state. For example, the following declarations are equivalent:

```ruby
rule(:NUMBER, /\d+/)
rule(:initial_NUMBER, /\d+/)
```

By default, lexing operates in `:initial` state. All the normally defined tokens are included in this state. During lexing if you wish to change the lexing state use the `begin` method. For example:

```ruby
rule(:begin_foo, /start_foo/) do |lexer, token|
  lexer.begin(:foo)
end
```

To get out of state you can use `begin` like so:

```ruby
rule(:foo_end, /end_foo/) do |lexer, token|
  lexer.begin(:initial)
end
```

For more complex scenarios with states you can use `push_state` and `pop_state` methods. For example:

```ruby
rule(:begin_foo, /start_foo/) do |lexer, token|
  lexer.push_state(:foo)
end

rule(:foo_end, /end_foo/) do |lexer, token|
  lexer.pop_state(:foo)
end
```

Assume you are parsing HTML and you want to ignore anything inside comment. Here is how you may use lexer states to do this:

```ruby
class MyLexer < Lex::Lexer
  tokens( )

  # Declare the states
  states( htmlcomment: :exclusive )

  # Enter html comment
  rule(:begin_htmlcomment, /<!--/) do |lexer, token|
    lexer.begin(:htmlcomment)
  end

  # Leave html comment
  rule(:htmlcomment, /-->/) do |lexer, token|
    lexer.begin(:initial)
  end

  error :htmlcomment do |lexer, token|
    lexer.logger.info "Ignoring character #{token.value}"
  end

  ignore :htmlcomment, " \t\n"

  ignore " \t"
end
```

### 1.14 Debugging

In order to run lexer in debug mode pass in `:debug` flag set to `true`.

```ruby
MyLexer.new(debug: true)
```

## Contributing

1. Fork it ( https://github.com/[my-github-username]/lex/fork )
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Add some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create a new Pull Request

## Copyright

Copyright (c) 2015 Piotr Murach. See LICENSE for further details.
