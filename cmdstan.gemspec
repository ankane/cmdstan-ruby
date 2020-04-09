require_relative "lib/cmdstan/version"

Gem::Specification.new do |spec|
  spec.name          = "cmdstan"
  spec.version       = CmdStan::VERSION
  spec.summary       = "Bayesian inference for Ruby, powered by CmdStan"
  spec.homepage      = "https://github.com/ankane/cmdstan"
  spec.license       = "BSD-3-Clause"

  spec.author        = "Andrew Kane"
  spec.email         = "andrew@chartkick.com"

  spec.files         = Dir["*.{md,txt}", "{ext,lib}/**/*"]
  spec.require_path  = "lib"
  spec.extensions    = ["ext/cmdstan/extconf.rb"]

  spec.required_ruby_version = ">= 2.4"

  spec.add_development_dependency "bundler"
  spec.add_development_dependency "rake"
  spec.add_development_dependency "minitest", ">= 5"
end
