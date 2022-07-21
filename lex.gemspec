# frozen_string_literal: true

require_relative "lib/lex/version"

Gem::Specification.new do |spec|
  spec.name = "lex"
  spec.version = Lex::VERSION
  spec.authors = ["Piotr Murach"]
  spec.email = ["piotr@piotrmurach.com"]
  spec.summary = "Lex is a lexical analyser construction tool in Ruby."
  spec.description = <<-DESC
Lex is a lexical analyser construction tool in Ruby. The goal is to
stay close to how the original lex tool works and combine it with the
expressiveness of Ruby.
  DESC
  spec.homepage = "https://github.com/piotrmurach/lex"
  spec.license = "MIT"

  spec.metadata["allowed_push_host"] = "https://rubygems.org"
  spec.metadata["bug_tracker_uri"] = "https://github.com/piotrmurach/lex/issues"
  spec.metadata["changelog_uri"] = "https://github.com/piotrmurach/lex/blob/master/CHANGELOG.md"
  spec.metadata["documentation_uri"] = "https://www.rubydoc.info/gems/lex"
  spec.metadata["homepage_uri"] = spec.homepage
  spec.metadata["rubygems_mfa_required"] = "true"
  spec.metadata["source_code_uri"] = "https://github.com/piotrmurach/lex"

  spec.files = Dir["lib/**/*"]
  spec.extra_rdoc_files = Dir["README.md", "CHANGELOG.md", "LICENSE.txt"]
  spec.require_paths = ["lib"]
  spec.required_ruby_version = ">= 2.0.0"

  spec.add_development_dependency "bundler", ">= 1.5"
  spec.add_development_dependency "rake"
  spec.add_development_dependency "rspec", "~> 3.0"
end
