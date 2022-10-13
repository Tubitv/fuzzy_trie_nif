defmodule FuzzyTrieNif.MixProject do
  use Mix.Project

  @version "0.1.0"
  @repo_url "https://github.com/Tubitv/fuzzy_trie_nif"

  def project do
    [
      app: :fuzzy_trie_nif,
      compilers: [:domo_compiler] ++ Mix.compilers(),
      version: @version,
      elixir: "~> 1.13",
      start_permanent: Mix.env() == :prod,
      elixirc_options: [warnings_as_errors: true, verbose: true],
      deps: deps(),
      docs: docs(),
      package: package()
    ]
  end

  # Run "mix help compile.app" to learn about applications.
  def application do
    [
      extra_applications: [:logger]
    ]
  end

  # Run "mix help deps" to learn about dependencies.
  defp deps do
    [
      {:rustler_precompiled, "~> 0.5.2"},
      {:rustler, ">= 0.0.0", optional: true},
      {:domo, "~> 1.5"},
      {:typed_struct, "~> 0.3.0"},
      {:credo, "~> 1.6", only: [:dev, :test], runtime: false},
      {:dialyxir, "~> 1.0", only: [:dev], runtime: false},
      {:benchee, "~> 1.0", only: :dev},
      {:ex_doc, ">= 0.0.0", only: :dev}
    ]
  end

  defp docs do
    [
      main: "FuzzyTrieNif",
      extras: ["CHANGELOG.md"],
      skip_undefined_reference_warnings_on: ["CHANGELOG.md"],
      source_ref: "v#{@version}",
      source_url: @repo_url
    ]
  end

  defp package do
    [
      organization: "tubitv",
      files: [
        "lib",
        "native/fuzzy_trie_nif/.cargo",
        "native/fuzzy_trie_nif/src",
        "native/fuzzy_trie_nif/Cargo*",
        "checksum-*.exs",
        "mix.exs",
        "README.md",
        "CHANGELOG.md",
        "LICENSE-APACHE",
        "LICENSE-MIT"
      ],
      maintainers: ["tubi"],
      licenses: ["MIT", "Apache-2.0"],
      links: %{"GitHub" => @repo_url}
    ]
  end
end
