module CmdStan
  module Install
    include Utils

    def cmdstan_version
      "2.38.0"
    end

    def cmdstan_installed?
      # last file to be built
      File.exist?(File.join(CmdStan.path, "bin", "diagnose#{extension}"))
    end

    def install_cmdstan
      require "digest"
      require "fileutils"
      require "open-uri"
      require "tmpdir"

      version = cmdstan_version
      dir = CmdStan.path

      # no stanc3 binary for Mac ARM
      if RbConfig::CONFIG["host_os"] !~ /darwin/i && RbConfig::CONFIG["host_cpu"] =~ /arm|aarch64/i
        checksum = "aa61eeb43e02d7fd14fb33afb51a8ceb94daca8fb66d48775ac088a5b2264caf"
        url = "https://github.com/stan-dev/cmdstan/releases/download/v#{version}/cmdstan-#{version}-linux-arm64.tar.gz"
      else
        checksum = "3ae8d290fa7ed6a0f425520e525460a159a32653b6d45f2153e1662d82f85f10"
        url = "https://github.com/stan-dev/cmdstan/releases/download/v#{version}/cmdstan-#{version}.tar.gz"
      end

      puts "Installing CmdStan version: #{version}"
      puts "Install directory: #{dir}"

      # only needed if default path
      FileUtils.mkdir_p(File.expand_path("../../tmp", __dir__)) unless ENV["CMDSTAN"]

      if cmdstan_installed?
        puts "Already installed"
        return true
      end

      unless Dir.exist?(dir)
        Dir.mktmpdir do |tmpdir|
          puts "Downloading..."
          download_path = File.join(tmpdir, "cmdstan-#{version}.tar.gz")
          download_file(url, download_path, checksum)

          puts "Unpacking..."
          path = File.join(tmpdir, "cmdstan-#{version}")
          FileUtils.mkdir_p(path)
          tar_args = Gem.win_platform? ? ["--force-local"] : []
          system "tar", "xzf", download_path, "-C", path, "--strip-components=1", *tar_args

          FileUtils.mv(path, dir)
        end
      end

      # cannot be moved after being built
      puts "Building..."
      make_command = Gem.win_platform? ? "mingw32-make" : "make"
      Dir.chdir(dir) do
        # disable precompiled header to save space
        output, status = Open3.capture2e(make_command, "build", "PRECOMPILED_HEADERS=false")
        if status.exitstatus != 0
          puts output
          raise Error, "Build failed"
        end
      end

      puts "Installed"

      true
    end

    private

    def download_file(url, download_path, checksum)
      IO.copy_stream(URI.parse(url).open(max_redirects: 10), download_path)
      digest = Digest::SHA256.file(download_path)
      raise Error, "Bad checksum: #{digest.hexdigest}" if digest.hexdigest != checksum
    end
  end
end
