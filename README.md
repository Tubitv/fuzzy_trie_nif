# FuzzyTrieNif
FuzzyTrieNif is a Elixir nif which wrapper the Rust crate [fuzzy_trie](https://crates.io/crates/fuzzy_trie), the nif is built by [Rustler](https://github.com/hansihe/rustler) crate.

## Installation

If [available in Hex](https://hex.pm/docs/publish), the package can be installed
by adding `fuzzy_trie_nif` to your list of dependencies in `mix.exs`:

```elixir
def deps do
  [
    {:fuzzy_trie_nif, "~> 0.1.0"}
  ]
end
```

Documentation can be generated with [ExDoc](https://github.com/elixir-lang/ex_doc)
and published on [HexDocs](https://hexdocs.pm). Once published, the docs can
be found at <https://hexdocs.pm/fuzzy_trie_nif>.

## Forcing compilation

By default **you don't need Rust installed** because the lib will try to download a precompiled NIF file. In case you want to force compilation set the `FUZZY_TRIE_FORCE_BUILD` environment variable to `true` or `1`.

## Usage
```elixir
trie =
  FuzzyTrie.new(1, true)
  |> FuzzyTrie.insert("something", 0)
  |> FuzzyTrie.insert("something", 1)
  |> FuzzyTrie.insert("something else", 2)
  |> FuzzyTrie.insert("somewhere", 3)

FuzzyTrie.prefix_fuzzy_search(trie, "s0me") # [0, 1, 2, 3]
FuzzyTrie.fuzzy_search(trie, "s0me") # []
FuzzyTrie.fuzzy_search(trie, "s0mething") # [0, 1]
```
The fuzzy trie can also be built by `FuzzyTrie.Builder`
```elixir
{:ok, trie} =
  FuzzyTrie.Builder.new!(distance: 1)
  |> FuzzyTrie.Builder.insert("something", 0)
  |> FuzzyTrie.Builder.insert("something", 1)
  |> FuzzyTrie.Builder.insert("something else", 2)
  |> FuzzyTrie.Builder.insert("somewhere", 3)
  |> FuzzyTrie.Builder.build()
```

## Benchmark
```
$ OPTIMIZE_NIF=true mix run benchmark/run.exs
Operating System: macOS
CPU Information: Apple M1 Max
Number of Available Cores: 10
Available memory: 64 GB
Elixir 1.13.3
Erlang 24.1.7

Benchmark suite executing with the following configuration:
warmup: 2 s
time: 5 s
memory time: 0 ns
reduction time: 0 ns
parallel: 10

##### With input 1 distance, damerau, 100 items #####
Name                          ips        average  deviation         median         99th %
prefix_fuzzy_search        1.60 K      623.22 μs    ±64.10%         539 μs        2279 μs
fuzzy_search               1.50 K      666.22 μs    ±95.01%         564 μs     2550.79 μs

Comparison: 
prefix_fuzzy_search        1.60 K
fuzzy_search               1.50 K - 1.07x slower +43.00 μs

##### With input 1 distance, damerau, 1000 items #####
Name                          ips        average  deviation         median         99th %
prefix_fuzzy_search        1.42 K      704.53 μs    ±61.27%         610 μs        2545 μs
fuzzy_search               1.36 K      735.24 μs    ±66.79%         634 μs     2752.84 μs

Comparison: 
prefix_fuzzy_search        1.42 K
fuzzy_search               1.36 K - 1.04x slower +30.71 μs

##### With input 1 distance, damerau, 10000 items #####
Name                          ips        average  deviation         median         99th %
prefix_fuzzy_search        1.16 K      859.40 μs    ±66.34%         739 μs     3132.36 μs
fuzzy_search               1.13 K      886.79 μs    ±60.69%         764 μs     3204.35 μs

Comparison: 
prefix_fuzzy_search        1.16 K
fuzzy_search               1.13 K - 1.03x slower +27.39 μs

##### With input 1 distance, non damerau, 100 items #####
Name                          ips        average  deviation         median         99th %
prefix_fuzzy_search        1.60 K      623.71 μs    ±68.44%         538 μs        2330 μs
fuzzy_search               1.54 K      651.01 μs    ±67.60%         562 μs        2403 μs

Comparison: 
prefix_fuzzy_search        1.60 K
fuzzy_search               1.54 K - 1.04x slower +27.30 μs

##### With input 1 distance, non damerau, 1000 items #####
Name                          ips        average  deviation         median         99th %
prefix_fuzzy_search        1.39 K      718.17 μs    ±72.12%         611 μs     2828.63 μs
fuzzy_search               1.36 K      736.00 μs    ±62.94%         636 μs        2678 μs

Comparison: 
prefix_fuzzy_search        1.39 K
fuzzy_search               1.36 K - 1.02x slower +17.83 μs

##### With input 1 distance, non damerau, 10000 items #####
Name                          ips        average  deviation         median         99th %
prefix_fuzzy_search        1.16 K      859.57 μs    ±62.32%         739 μs        3124 μs
fuzzy_search               1.13 K      884.98 μs    ±61.56%         763 μs     3294.10 μs

Comparison: 
prefix_fuzzy_search        1.16 K
fuzzy_search               1.13 K - 1.03x slower +25.41 μs

##### With input 2 distance, damerau, 100 items #####
Name                          ips        average  deviation         median         99th %
prefix_fuzzy_search        521.11        1.92 ms    ±66.07%        1.66 ms        6.75 ms
fuzzy_search               492.22        2.03 ms    ±57.60%        1.79 ms        7.04 ms

Comparison: 
prefix_fuzzy_search        521.11
fuzzy_search               492.22 - 1.06x slower +0.113 ms

##### With input 2 distance, damerau, 1000 items #####
Name                          ips        average  deviation         median         99th %
prefix_fuzzy_search        461.92        2.16 ms    ±56.22%        1.89 ms        7.35 ms
fuzzy_search               425.48        2.35 ms    ±62.25%        2.02 ms        8.41 ms

Comparison: 
prefix_fuzzy_search        461.92
fuzzy_search               425.48 - 1.09x slower +0.185 ms

##### With input 2 distance, damerau, 10000 items #####
Name                          ips        average  deviation         median         99th %
prefix_fuzzy_search        273.29        3.66 ms    ±51.46%        3.13 ms       11.37 ms
fuzzy_search               264.24        3.78 ms    ±53.23%        3.25 ms       11.93 ms

Comparison: 
prefix_fuzzy_search        273.29
fuzzy_search               264.24 - 1.03x slower +0.125 ms

##### With input 2 distance, non damerau, 100 items #####
Name                          ips        average  deviation         median         99th %
prefix_fuzzy_search        548.99        1.82 ms    ±59.18%        1.62 ms        6.39 ms
fuzzy_search               502.91        1.99 ms    ±57.04%        1.76 ms        6.72 ms

Comparison: 
prefix_fuzzy_search        548.99
fuzzy_search               502.91 - 1.09x slower +0.167 ms

##### With input 2 distance, non damerau, 1000 items #####
Name                          ips        average  deviation         median         99th %
prefix_fuzzy_search        476.95        2.10 ms    ±57.03%        1.85 ms        7.38 ms
fuzzy_search               443.59        2.25 ms    ±55.43%        1.99 ms        7.55 ms

Comparison: 
prefix_fuzzy_search        476.95
fuzzy_search               443.59 - 1.08x slower +0.158 ms

##### With input 2 distance, non damerau, 10000 items #####
Name                          ips        average  deviation         median         99th %
prefix_fuzzy_search        279.04        3.58 ms    ±51.13%        3.07 ms       11.26 ms
fuzzy_search               270.45        3.70 ms    ±52.49%        3.21 ms       11.76 ms

Comparison: 
prefix_fuzzy_search        279.04
fuzzy_search               270.45 - 1.03x slower +0.114 ms
```

## License

Licensed under either of

 * Apache License, Version 2.0, ([LICENSE-APACHE](LICENSE-APACHE) or http://www.apache.org/licenses/LICENSE-2.0)
 * MIT license ([LICENSE-MIT](LICENSE-MIT) or http://opensource.org/licenses/MIT)

at your option.
