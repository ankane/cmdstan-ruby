# stdlib
require "csv"
require "json"
require "open3"

# modules
require "cmdstan/utils"
require "cmdstan/mcmc"
require "cmdstan/mle"
require "cmdstan/model"
require "cmdstan/version"

module CmdStan
  class Error < StandardError; end

  class << self
    attr_accessor :path
  end
  self.path = ENV["CMDSTAN"] || File.expand_path("../tmp/cmdstan", __dir__)
end
