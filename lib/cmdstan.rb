# stdlib
require "digest"
require "csv"
require "fileutils"
require "json"
require "net/http"
require "open3"
require "tempfile"

# modules
require_relative "cmdstan/utils"
require_relative "cmdstan/install"
require_relative "cmdstan/mcmc"
require_relative "cmdstan/mle"
require_relative "cmdstan/model"
require_relative "cmdstan/version"

module CmdStan
  class Error < StandardError; end

  extend Install

  class << self
    attr_accessor :path
  end
  self.path = ENV["CMDSTAN"] || File.expand_path("../tmp/cmdstan", __dir__)
end
