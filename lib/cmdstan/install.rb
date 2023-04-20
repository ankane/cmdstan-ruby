module CmdStan
  module Install
    def cmdstan_version
      "2.32.0"
    end

    def cmdstan_installed?
      Dir.exist?(CmdStan.path)
    end

    def install_cmdstan
      version = cmdstan_version
      dir = CmdStan.path

      # no stanc3 binary for Mac ARM
      if RbConfig::CONFIG["host_os"] !~ /darwin/i && RbConfig::CONFIG["host_cpu"] =~ /arm|aarch64/i
        checksum = "e387890fd02c167c38db34c34a09ff2193c354b203d11ca1d34da0ec4b2b0606"
        url = "https://github.com/stan-dev/cmdstan/releases/download/v#{version}/cmdstan-#{version}-linux-arm64.tar.gz"
      else
        checksum = "29fee108d2ae3dca5be7c0a65a70517922e4be671e129d177c84f77a11263d4a"
        url = "https://github.com/stan-dev/cmdstan/releases/download/v#{version}/cmdstan-#{version}.tar.gz"
      end

      puts "Installing CmdStan version: #{version}"
      puts "Install directory: #{dir}"

      # only needed if default path
      FileUtils.mkdir_p(File.expand_path("../../tmp", __dir__)) unless ENV["CMDSTAN"]

      if Dir.exist?(dir)
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

        puts "Building..."
        make_command = Gem.win_platform? ? "mingw32-make" : "make"
        Dir.chdir(path) do
          # disable precompiled header to save space
          output, status = Open3.capture2e(make_command, "build", "PRECOMPILED_HEADERS=false")
          if status.exitstatus != 0
            puts output
            raise Error, "Build failed"
          end
        end

        FileUtils.mv(path, dir)
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
