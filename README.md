# Yamel - Yaml Serializer and Parser

![CI](https://github.com/GPrimola/yamel/workflows/Main%20CI/badge.svg)
[![Coverage Status](https://coveralls.io/repos/github/GPrimola/yamel/badge.svg?branch=master)](https://coveralls.io/github/GPrimola/yamel?branch=master)
[![Docs](https://img.shields.io/badge/api-docs-blueviolet.svg?style=flat)](https://hexdocs.pm/yamel)
![Hex.pm](https://img.shields.io/hexpm/v/yamel)
<!-- ![Hex.pm](https://img.shields.io/hexpm/dt/yamel) -->

---

An [yaml](https://en.wikipedia.org/wiki/YAML) parser and serializer to work with Yaml files in Elixir.

## Installation

Add `yamel` to your list of dependencies in `mix.exs`:

```elixir
def deps do
  [
    {:yamel, "~> 2.0.4"}
  ]
end
```


## Usage

```elixir
yaml_string = ~S"""
foo: bar
zoo:
  - caa
  - boo
  - vee
"""

Yamel.decode!(yaml_string) # equivalent to Yamel.decode!(yaml_string, keys: :string)
=> %{"foo" => "bar", "zoo" => ["caa", "boo", "vee"]}

Yamel.decode!(yaml_string, keys: :atom)
=> %{foo: "bar", zoo: ["caa", "boo", "vee"]}

Yamel.encode!(["caa", :boo, :"\"foo\""])
=> "- caa\n- boo\n- \"foo\"\n\n"

%{foo: :bar, zoo: :caa}
|> Yamel.encode!()
|> Yamel.IO.write!("/to/file.yml")
=> :ok

%{foo: value} = Yamel.IO.read!("/from/file.yaml")
```

### Deriving

```elixir
defmodule MyApp.MyStruct do
  defstruct [:field1, :field2, :field3, field4: true]
  @derive {Yamel.Encoder, only: [:field2, :field4]}
end
```
