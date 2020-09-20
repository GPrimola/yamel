# Yamel

[![Coverage Status](https://coveralls.io/repos/github/GPrimola/yamel/badge.svg?branch=master)](https://coveralls.io/github/GPrimola/yamel?branch=master)
[![Docs](https://img.shields.io/badge/api-docs-blueviolet.svg?style=flat)](https://hexdocs.pm/yamel)
![Hex.pm](https://img.shields.io/hexpm/v/yamel)
<!-- ![Hex.pm](https://img.shields.io/hexpm/dt/yamel) -->

An [yaml](https://en.wikipedia.org/wiki/YAML) parser and serializer to work with Yaml files in Elixir.

## Usage

```elixir
yaml_string = ~S"""
foo: bar
zoo:
  - caa
  - boo
  - vee
"""

%{"foo" => foo_value, "zoo" => [first_elem, sec_elem, third_elem]} = Yamel.decode!(yaml_string)

Yamel.encode!(["caa", :boo, :"\"foo\""])
=> "- caa\n- boo\n- \"foo\"\n\n"

%{foo: :bar, zoo: :caa}
|> Yamel.encode!()
|> Yamel.IO.write!("/to/file.yml")
=> :ok

%{foo: value} = Yamel.IO.read!("/from/file.yaml")
```

## Installation

Add `yamel` to your list of dependencies in `mix.exs`:

```elixir
def deps do
  [
    {:yamel, "~> 1.0.0"}
  ]
end
```
