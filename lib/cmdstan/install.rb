module CmdStan
  module Install
    include Utils

    def cmdstan_version
      "2.40.0"
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
        checksum = "c31e9f45a701c47f547381080ee804bf7e2428aace68eff68d4262b5c406aa63"
        url = "https://github.com/stan-dev/cmdstan/releases/download/v#{version}/cmdstan-#{version}-linux-arm64.tar.gz"
      else
        checksum = "26d21c9737b35728e926f9b7a5d7362b38dc23e2e7d5e166c890e1fa74dac90c"
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
        puts "Downloading..."
        URI.parse(url).open(max_redirects: 10) do |download|
          digest =
            if download.respond_to?(:path)
              download.flush
              Digest::SHA256.file(download.path).hexdigest
            else
              Digest::SHA256.hexdigest(download.string)
            end

          if digest != checksum
            raise Error, "Bad checksum: #{digest}"
          end

          # should never happen
          raise "Expected file" if !download.respond_to?(:path)

          puts "Unpacking..."
          Dir.mktmpdir do |tmpdir|
            path = File.join(tmpdir, "cmdstan-#{version}")
            FileUtils.mkdir_p(path)
            tar_args = Gem.win_platform? ? ["--force-local"] : []
            system "tar", "xzf", download.path, "-C", path, "--strip-components=1", *tar_args

            FileUtils.mv(path, dir)
          end
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
  end
end
