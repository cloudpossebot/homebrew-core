class Jackett < Formula
  desc "API Support for your favorite torrent trackers"
  homepage "https://github.com/Jackett/Jackett"
  url "https://github.com/Jackett/Jackett/archive/refs/tags/v0.22.2163.tar.gz"
  sha256 "7e7d1099aa6dd333deb5deec4a896ff6a44f1bd680e60b5e7d8542602b13b188"
  license "GPL-2.0-only"
  head "https://github.com/Jackett/Jackett.git", branch: "master"

  bottle do
    sha256 cellar: :any,                 arm64_sequoia: "fc20e0e927376ca30974d0e1fb5d34a0f92aab372de3a4ba75dc78a21652312c"
    sha256 cellar: :any,                 arm64_sonoma:  "b544a3830257a5ac816e71d3022d4cba5add71909e8916ad3ee41ecc198531f4"
    sha256 cellar: :any,                 arm64_ventura: "932503ff641a22b8d0d7285098348fc955895b026da4572b637bc87a547e5c1d"
    sha256 cellar: :any,                 ventura:       "55a632c818cf9d999ed2e9ae91bb9e076876b8781771c40080ba8fa504224c1a"
    sha256 cellar: :any_skip_relocation, arm64_linux:   "efaef811a9be7cdb55f64ab371162050d51169a8dbb9b926e52ea25d09c499e4"
    sha256 cellar: :any_skip_relocation, x86_64_linux:  "69d1be85df0df8d30799b5bb8722cfec7fddeb992581d9a49259ec22fc3f8da2"
  end

  depends_on "dotnet@8"

  def install
    ENV["DOTNET_CLI_TELEMETRY_OPTOUT"] = "1"
    ENV["DOTNET_SYSTEM_GLOBALIZATION_INVARIANT"] = "1"

    dotnet = Formula["dotnet@8"]

    args = %W[
      --configuration Release
      --framework net#{dotnet.version.major_minor}
      --output #{libexec}
      --no-self-contained
      --use-current-runtime
    ]
    if build.stable?
      args += %W[
        /p:AssemblyVersion=#{version}
        /p:FileVersion=#{version}
        /p:InformationalVersion=#{version}
        /p:Version=#{version}
      ]
    end

    system "dotnet", "publish", "src/Jackett.Server", *args

    (bin/"jackett").write_env_script libexec/"jackett", "--NoUpdates",
      DOTNET_ROOT: "${DOTNET_ROOT:-#{dotnet.opt_libexec}}"
  end

  service do
    run opt_bin/"jackett"
    keep_alive true
    working_dir opt_libexec
    log_path var/"log/jackett.log"
    error_log_path var/"log/jackett.log"
  end

  test do
    assert_match(/^Jackett v#{Regexp.escape(version)}$/, shell_output("#{bin}/jackett --version 2>&1; true"))

    port = free_port

    pid = fork do
      exec bin/"jackett", "-d", testpath, "-p", port.to_s
    end

    begin
      sleep 15
      assert_match "<title>Jackett</title>", shell_output("curl -b cookiefile -c cookiefile -L --silent http://localhost:#{port}")
    ensure
      Process.kill "TERM", pid
      Process.wait pid
    end
  end
end
