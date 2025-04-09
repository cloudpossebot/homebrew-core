class Uv < Formula
  desc "Extremely fast Python package installer and resolver, written in Rust"
  homepage "https://docs.astral.sh/uv/"
  url "https://github.com/astral-sh/uv/archive/refs/tags/0.6.14.tar.gz"
  sha256 "8aa675d84e42d3531fb5494bd519c418cdb419385d768f350a73a5e7a428bf70"
  license any_of: ["Apache-2.0", "MIT"]
  head "https://github.com/astral-sh/uv.git", branch: "main"

  bottle do
    sha256 cellar: :any_skip_relocation, arm64_sequoia: "04253d8959d96513191a33a8a7fc351cfb3339ef05c42f7c46d4c7947c55aa66"
    sha256 cellar: :any_skip_relocation, arm64_sonoma:  "6736c6ee8dd65b85f40a45e928b95397a85b68f721c04ea9ecfbec0364c9c2e3"
    sha256 cellar: :any_skip_relocation, arm64_ventura: "5128f6a4231e51279e0e9a01b68e850d80f0cd8770ea5536aa59fa9617cce01a"
    sha256 cellar: :any_skip_relocation, sonoma:        "ffcb3a79935bc45341b847d7845c2f2ca2c7da5f2c0203d3263c332c9cf4cc0b"
    sha256 cellar: :any_skip_relocation, ventura:       "c26c6e55092029925525db211542dea4b681fd4b478a52860b32622d897e43a7"
    sha256 cellar: :any_skip_relocation, arm64_linux:   "06ad5fdda7d03171ea310cdf37f08d07101a398bb664c3438dd61f98b34d62fe"
    sha256 cellar: :any_skip_relocation, x86_64_linux:  "0ead804fb0acb47d4e0a3970a903daa5cab7833ee0955353c20dc4eadba70668"
  end

  depends_on "pkgconf" => :build
  depends_on "rust" => :build

  uses_from_macos "python" => :test
  uses_from_macos "bzip2"
  uses_from_macos "xz"

  def install
    ENV["UV_COMMIT_HASH"] = ENV["UV_COMMIT_SHORT_HASH"] = tap.user
    ENV["UV_COMMIT_DATE"] = time.strftime("%F")
    system "cargo", "install", "--no-default-features", *std_cargo_args(path: "crates/uv")
    generate_completions_from_executable(bin/"uv", "generate-shell-completion")
    generate_completions_from_executable(bin/"uvx", "--generate-shell-completion")
  end

  test do
    (testpath/"requirements.in").write <<~REQUIREMENTS
      requests
    REQUIREMENTS

    compiled = shell_output("#{bin}/uv pip compile -q requirements.in")
    assert_match "This file was autogenerated by uv", compiled
    assert_match "# via requests", compiled

    assert_match "ruff 0.5.1", shell_output("#{bin}/uvx -q ruff@0.5.1 --version")
  end
end
