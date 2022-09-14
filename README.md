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
  FuzzyTrie.Builder.new(distance: 1)
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
prefix_fuzzy_search        1.53 K      653.73 μs   ±104.30%         540 μs     2852.89 μs
fuzzy_search               1.33 K      753.96 μs   ±140.28%         570 μs        4431 μs

Comparison: 
prefix_fuzzy_search        1.53 K
fuzzy_search               1.33 K - 1.15x slower +100.22 μs

##### With input 1 distance, damerau, 1000 items #####
Name                          ips        average  deviation         median         99th %
prefix_fuzzy_search        1.35 K      739.24 μs    ±80.76%         615 μs     3182.40 μs
fuzzy_search               1.22 K      822.30 μs   ±115.54%         642 μs     4399.46 μs

Comparison: 
prefix_fuzzy_search        1.35 K
fuzzy_search               1.22 K - 1.11x slower +83.06 μs

##### With input 1 distance, damerau, 10000 items #####
Name                          ips        average  deviation         median         99th %
prefix_fuzzy_search        1.10 K        0.91 ms    ±99.44%        0.75 ms        4.07 ms
fuzzy_search               0.95 K        1.06 ms   ±140.32%        0.78 ms        6.40 ms

Comparison: 
prefix_fuzzy_search        1.10 K
fuzzy_search               0.95 K - 1.16x slower +0.143 ms

##### With input 1 distance, non damerau, 100 items #####
Name                          ips        average  deviation         median         99th %
prefix_fuzzy_search        1.56 K      639.10 μs    ±75.49%         540 μs        2507 μs
fuzzy_search               1.42 K      705.57 μs   ±111.21%         569 μs     3193.31 μs

Comparison: 
prefix_fuzzy_search        1.56 K
fuzzy_search               1.42 K - 1.10x slower +66.47 μs

##### With input 1 distance, non damerau, 1000 items #####
Name                          ips        average  deviation         median         99th %
prefix_fuzzy_search        1.36 K      734.02 μs    ±83.00%         612 μs     3145.36 μs
fuzzy_search               1.28 K      783.73 μs   ±106.74%         638 μs     3454.97 μs

Comparison: 
prefix_fuzzy_search        1.36 K
fuzzy_search               1.28 K - 1.07x slower +49.71 μs

##### With input 1 distance, non damerau, 10000 items #####
Name                          ips        average  deviation         median         99th %
prefix_fuzzy_search        1.13 K      885.36 μs    ±78.38%         741 μs        3617 μs
fuzzy_search               1.02 K      980.40 μs   ±132.54%         769 μs     4638.94 μs

Comparison: 
prefix_fuzzy_search        1.13 K
fuzzy_search               1.02 K - 1.11x slower +95.04 μs

##### With input 2 distance, damerau, 100 items #####
Name                          ips        average  deviation         median         99th %
prefix_fuzzy_search        500.18        2.00 ms    ±72.37%        1.68 ms        7.64 ms
fuzzy_search               471.89        2.12 ms    ±64.17%        1.80 ms        7.81 ms

Comparison: 
prefix_fuzzy_search        500.18
fuzzy_search               471.89 - 1.06x slower +0.120 ms

##### With input 2 distance, damerau, 1000 items #####
Name                          ips        average  deviation         median         99th %
prefix_fuzzy_search        446.93        2.24 ms    ±59.56%        1.92 ms        7.68 ms
fuzzy_search               421.28        2.37 ms    ±60.49%        2.02 ms        8.42 ms

Comparison: 
prefix_fuzzy_search        446.93
fuzzy_search               421.28 - 1.06x slower +0.136 ms

##### With input 2 distance, damerau, 10000 items #####
Name                          ips        average  deviation         median         99th %
prefix_fuzzy_search        270.75        3.69 ms    ±53.46%        3.14 ms       11.90 ms
fuzzy_search               260.78        3.83 ms    ±53.06%        3.29 ms       12.21 ms

Comparison: 
prefix_fuzzy_search        270.75
fuzzy_search               260.78 - 1.04x slower +0.141 ms

##### With input 2 distance, non damerau, 100 items #####
Name                          ips        average  deviation         median         99th %
prefix_fuzzy_search        522.18        1.92 ms    ±63.25%        1.66 ms        6.87 ms
fuzzy_search               490.97        2.04 ms    ±69.87%        1.77 ms        7.41 ms

Comparison: 
prefix_fuzzy_search        522.18
fuzzy_search               490.97 - 1.06x slower +0.122 ms

##### With input 2 distance, non damerau, 1000 items #####
Name                          ips        average  deviation         median         99th %
fuzzy_search               437.53        2.29 ms    ±60.07%        1.99 ms        8.10 ms
prefix_fuzzy_search        402.06        2.49 ms   ±104.62%        1.97 ms       12.02 ms

Comparison: 
fuzzy_search               437.53
prefix_fuzzy_search        402.06 - 1.09x slower +0.20 ms

##### With input 2 distance, non damerau, 10000 items #####
Name                          ips        average  deviation         median         99th %
fuzzy_search               261.49        3.82 ms    ±54.76%        3.26 ms       12.95 ms
prefix_fuzzy_search        243.13        4.11 ms    ±62.48%        3.41 ms       14.51 ms

Comparison: 
fuzzy_search               261.49
prefix_fuzzy_search        243.13 - 1.08x slower +0.29 ms
```