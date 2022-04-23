# stdlib
require "digest"
require "csv"
require "fileutils"
require "json"
require "net/http"
require "open3"
require "tempfile"

# modules
require "cmdstan/install"
require "cmdstan/utils"
require "cmdstan/mcmc"
require "cmdstan/mle"
require "cmdstan/model"
require "cmdstan/version"

module CmdStan
  class Error < StandardError; end

  extend Install

  class << self
    attr_accessor :path
  end
  self.path = ENV["CMDSTAN"] || File.expand_path("../tmp/cmdstan", __dir__)
end
