module CmdStan
  module Install
    include Utils

    def cmdstan_version
      "2.34.1"
    end

    def cmdstan_installed?
      # last file to be built
      File.exist?(File.join(CmdStan.path, "bin", "diagnose#{extension}"))
    end

    def install_cmdstan
      version = cmdstan_version
      dir = CmdStan.path

      # no stanc3 binary for Mac ARM
      if RbConfig::CONFIG["host_os"] !~ /darwin/i && RbConfig::CONFIG["host_cpu"] =~ /arm|aarch64/i
        checksum = "04eabc41b6221176a661818852e7187407e4590ee462e608df149ff37eede859"
        url = "https://github.com/stan-dev/cmdstan/releases/download/v#{version}/cmdstan-#{version}-linux-arm64.tar.gz"
      else
        checksum = "9a6efc817a473768cf21f1e4bb1303be7ade2e26fc971856a7f9cf0bc3355f2b"
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

    def download_file(url, download_path, checksum, redirects = 0)
      raise Error, "Too many redirects" if redirects > 10

      uri = URI(url)
      location = nil

      Net::HTTP.start(uri.host, uri.port, use_ssl: true) do |http|
        request = Net::HTTP::Get.new(uri)
        http.request(request) do |response|
          case response
          when Net::HTTPRedirection
            location = response["location"]
          when Net::HTTPSuccess
            digest = Digest::SHA2.new

            File.open(download_path, "wb") do |f|
              response.read_body do |chunk|
                f.write(chunk)
                digest.update(chunk)
              end
            end

            raise Error, "Bad checksum: #{digest.hexdigest}" if digest.hexdigest != checksum
          else
            raise Error, "Bad response"
          end
        end
      end

      # outside of Net::HTTP block to close previous connection
      download_file(location, download_path, checksum, redirects + 1) if location
    end
  end
end
