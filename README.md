# Yamel

![CI](https://github.com/GPrimola/yamel/workflows/Yamel%20CI/badge.svg)
[![Coverage Status](https://coveralls.io/repos/github/GPrimola/yamel/badge.svg?branch=master)](https://coveralls.io/github/GPrimola/yamel?branch=master)
[![Docs](https://img.shields.io/badge/api-docs-blueviolet.svg?style=flat)](https://hexdocs.pm/yamel)
![Hex.pm](https://img.shields.io/hexpm/v/yamel)
<!-- ![Hex.pm](https://img.shields.io/hexpm/dt/yamel) -->

An [yaml](https://en.wikipedia.org/wiki/YAML) parser and serializer to work with Yaml files in Elixir.

### WELCOME HACKTOBERFEST PARTYPEOPLE!! 🎉🎊🥳👩🏿‍💻👩🏾‍💻👩🏽‍💻👩🏼‍💻👩🏻‍💻👩‍💻👨‍💻👨🏻‍💻👨🏼‍💻👨🏽‍💻👨🏾‍💻👨🏿‍💻

#### Here are some few things I'd like to ask you beforehand for this event!

##### Basic Code of Conduct

1. Be nice to other people, no matter what, should you interact with anyone.
2. Open **short**, but **meaningful** and **valuable**, **PR**(s). This way is easier to review on time.
    - E.g.: Instead of document a whole module, you can document just one function, for instance. This goes with the Quality over Quantity value from Hacktoberfest.
3. This is a fresh repository which I'm already using in production. I apologize for the lack of more information but feel free to interact with me through the Issues or [twitter](https://twitter.com/lu_gico) with the hashtag #elixirJenkiexs.

#### We appreciate your collaboration! Thank you very much!! 🙏🏿🙏🏾🙏🏽🙏🏼🙏🏻🙏✨


## Usage

```elixir
yaml_string = ~S"""
foo: bar
zoo:
  - caa
  - boo
  - vee
"""

Yamel.decode!(yaml_string)
=> %{"foo" => "bar", "zoo" => ["caa", "boo", "vee"]}

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
    {:yamel, "~> 1.0.2"}
  ]
end
```
