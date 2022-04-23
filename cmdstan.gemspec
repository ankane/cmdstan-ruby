require_relative "lib/cmdstan/version"

Gem::Specification.new do |spec|
  spec.name          = "cmdstan"
  spec.version       = CmdStan::VERSION
  spec.summary       = "Bayesian inference for Ruby, powered by CmdStan"
  spec.homepage      = "https://github.com/ankane/cmdstan-ruby"
  spec.license       = "BSD-3-Clause"

  spec.author        = "Andrew Kane"
  spec.email         = "andrew@ankane.org"

  spec.files         = Dir["*.{md,txt}", "{lib}/**/*"]
  spec.require_path  = "lib"

  spec.required_ruby_version = ">= 2.7"
end
