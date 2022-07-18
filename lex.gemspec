# frozen_string_literal: true

require_relative "lib/lex/version"

Gem::Specification.new do |spec|
  spec.name          = "lex"
  spec.version       = Lex::VERSION
  spec.authors       = ["Piotr Murach"]
  spec.email         = ["me@piotrmurach.com"]
  spec.summary       = %q{Lex is an implementation of complier constuction tool lex in Ruby.}
  spec.description   = %q{Lex is an implementation of compiler construction tool lex in Ruby. The goal is to stay close to the way the original tool works and combine it with the expressivness or Ruby.}
  spec.homepage      = "https://github.com/piotrmurach/lex"
  spec.license       = "MIT"

  spec.metadata["allowed_push_host"] = "https://rubygems.org"
  spec.metadata["bug_tracker_uri"] = "https://github.com/piotrmurach/lex/issues"
  spec.metadata["changelog_uri"] = "https://github.com/piotrmurach/lex/blob/master/CHANGELOG.md"
  spec.metadata["documentation_uri"] = "https://www.rubydoc.info/gems/lex"
  spec.metadata["homepage_uri"] = spec.homepage
  spec.metadata["source_code_uri"] = "https://github.com/piotrmurach/lex"

  spec.files         = Dir['{lib,spec,examples}/**/*.rb']
  spec.files        += Dir['tasks/*', 'lex.gemspec']
  spec.files        += Dir['README.md', 'CHANGELOG.md', 'LICENSE.txt', 'Rakefile']
  spec.executables   = spec.files.grep(%r{^bin/}) { |f| File.basename(f) }
  spec.test_files    = spec.files.grep(%r{^(test|spec|features)/})
  spec.require_paths = ["lib"]

  spec.required_ruby_version = ">= 2.0.0"

  spec.add_development_dependency "bundler", ">= 1.5"
  spec.add_development_dependency "rake"
  spec.add_development_dependency "rspec", "~> 3.0"
end
