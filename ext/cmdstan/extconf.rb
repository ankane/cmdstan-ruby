require "digest"
require "fileutils"
require "net/http"
require "tmpdir"

version = "2.28.2"
# TODO figure out Mac ARM
if RbConfig::CONFIG["host_os"] !~ /darwin/i && RbConfig::CONFIG["host_cpu"] =~ /arm|aarch64/i
  checksum = "cd8f588a1267e3e36761b7bcdff1b7f36bf43b8ec119667654995bfa5f921fa4"
  url =  "https://github.com/stan-dev/cmdstan/releases/download/v#{version}/cmdstan-#{version}-linux-arm64.tar.gz"
else
  checksum = "4e6ed2685460d7f33ddbc81ccb1e59befa7efd91e46d5b040027aab8daec4526"
  url = "https://github.com/stan-dev/cmdstan/releases/download/v#{version}/cmdstan-#{version}.tar.gz"
end

path = ENV["CMDSTAN"] || File.expand_path("../../tmp/cmdstan", __dir__)
FileUtils.mkdir_p(path)
raise "Directory not empty. Run: rake clean" unless Dir.empty?(path)

$stdout.sync = true

def download_file(url, download_path, checksum, redirects = 0)
  raise "Too many redirects" if redirects > 10

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

        i = 0
        File.open(download_path, "wb") do |f|
          response.read_body do |chunk|
            f.write(chunk)
            digest.update(chunk)

            # print progress
            putc "." if i % 50 == 0
            i += 1
          end
        end
        puts # newline

        abort "Bad checksum: #{digest.hexdigest}" if digest.hexdigest != checksum
      else
        abort "Bad response"
      end
    end
  end

  # outside of Net::HTTP block to close previous connection
  download_file(location, download_path, checksum, redirects + 1) if location
end

# download
puts "Downloading #{url}..."
download_path = "#{Dir.tmpdir}/cmdstan-#{version}.tar.gz"
download_file(url, download_path, checksum)

# extract
Dir.chdir(path)
# TODO use Gem::Package::TarReader from Rubygems
tar_args = Gem.win_platform? ? ["--force-local"] : []
system "tar", "zxf", download_path, "-C", path, "--strip-components=1", *tar_args

# build
make_command = Gem.win_platform? ? "mingw32-make" : "make"
success = system(make_command, "build")
raise "Build failed" unless success
