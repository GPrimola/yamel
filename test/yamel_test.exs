defmodule YamelTest do
  use ExUnit.Case

  @doc """
  This test cases were extracted from https://yaml.org/YAML_for_ruby.html
  """
  describe "encode!/1" do
    test "when value is Simple Sequence" do
      simple_sequence = ["apple", "banana", "carrot"]

      simple_sequence_yaml = ~S"""
      - apple
      - banana
      - carrot

      """

      encoded_simple_sequence = Yamel.encode!(simple_sequence)
      assert encoded_simple_sequence == simple_sequence_yaml
    end

    test "when value is Nested Sequences" do
      nested_sequence = [["foo", "bar", "zoo"]]

      nested_sequence_yaml = ~S"""
      -
        - foo
        - bar
        - zoo

      """

      encoded_nested_sequence = Yamel.encode!(nested_sequence)
      assert encoded_nested_sequence == nested_sequence_yaml
    end

    test "when value is Mixed Sequence" do
      mixed_sequence = ["apple", ["foo", "bar", "zoo"], "banana", "carrot"]

      mixed_sequence_yaml = ~S"""
      - apple
      -
        - foo
        - bar
        - zoo
      - banana
      - carrot

      """

      encoded_mixed_sequence = Yamel.encode!(mixed_sequence)
      assert encoded_mixed_sequence == mixed_sequence_yaml
    end

    test "when value is Deeply Nested Sequence" do
      deeply_nested_sequence = [[["uno", "dos"]]]

      deeply_nested_sequence_yaml = ~S"""
      -
        -
          - uno
          - dos

      """

      encoded_deeply_nested_sequence = Yamel.encode!(deeply_nested_sequence)
      assert encoded_deeply_nested_sequence == deeply_nested_sequence_yaml
    end

    test "when value is Simple Mapping" do
      simple_map = %{foo: "bar", zoo: "caa"}

      simple_map_yaml = ~S"""
      foo: bar
      zoo: caa

      """

      encoded_simple_map = Yamel.encode!(simple_map)
      assert encoded_simple_map == simple_map_yaml
    end

    test "when value is Sequence in a Mapping" do
      sequence_in_a_map = %{foo: "bar", zoo: ["uno", "dos"]}

      sequence_in_a_map_yaml = ~S"""
      foo: bar
      zoo:
        - uno
        - dos

      """

      encoded_sequence_in_a_map = Yamel.encode!(sequence_in_a_map)
      assert encoded_sequence_in_a_map == sequence_in_a_map_yaml
    end

    test "when value is Nested Mappings" do
      nested_map = %{foo: "bar", zoo: %{fruit: "apple", name: "steve", sport: "baseball"}}

      nested_map_yaml = ~S"""
      foo: bar
      zoo:
        fruit: apple
        name: steve
        sport: baseball

      """

      encoded_nested_map = Yamel.encode!(nested_map)
      assert encoded_nested_map == nested_map_yaml
    end

    test "when value is Mixed Mapping" do
      mixed_map = %{
        foo: "bar",
        zoo: [
          %{fruit: "apple", name: "steve", sport: "baseball"},
          "more",
          %{python: "rocks", javascript: "papers", ruby: "scissorses"}
        ]
      }

      mixed_map_yaml = ~S"""
      foo: bar
      zoo:
        -
          fruit: apple
          name: steve
          sport: baseball
        - more
        -
          javascript: papers
          python: rocks
          ruby: scissorses

      """

      encoded_mixed_map = Yamel.encode!(mixed_map)
      assert encoded_mixed_map == mixed_map_yaml
    end

    test "when value is Mapping-in-Sequence" do
      map_in_sequence = [%{"work on yamel.ex" => ["work on Store"]}]

      map_in_sequence_yaml = ~S"""
      -
        work on yamel.ex:
          - work on Store

      """

      encoded_map_in_sequence = Yamel.encode!(map_in_sequence)
      assert encoded_map_in_sequence == map_in_sequence_yaml
    end

    test "when value is Sequence-in-Mapping" do
      sequence_in_map = %{allow: ["localhost", "%.sourceforge.net", "%.freepan.org"]}

      sequence_in_map_yaml = ~S"""
      allow:
        - localhost
        - %.sourceforge.net
        - %.freepan.org

      """

      encoded_sequence_in_a_map = Yamel.encode!(sequence_in_map)
      assert encoded_sequence_in_a_map == sequence_in_map_yaml
    end

    test "when value is Mapping-in-Sequence Shortcut" do
      map_in_sequence_shortcut = [%{"work on yamel.ex" => ["work on Store"]}]

      map_in_sequence_shortcut_yaml = ~S"""
      - work on yamel.ex:
        - work on Store

      """

      map_in_sequence_yaml = ~S"""
      -
        work on yamel.ex:
          - work on Store

      """

      encoded_map_in_sequence_shortcut = Yamel.encode!(map_in_sequence_shortcut)
      refute encoded_map_in_sequence_shortcut == map_in_sequence_shortcut_yaml
      assert encoded_map_in_sequence_shortcut == map_in_sequence_yaml
    end

    test "when value is Sequence-in-Mapping Shortcut" do
      sequence_in_map_shortcut = %{allow: ["localhost", "%.sourceforge.net", "%.freepan.org"]}

      sequence_in_map_shortcut_yaml = ~S"""
      allow:
      - localhost
      - %.sourceforge.net
      - %.freepan.org

      """

      sequence_in_map_yaml = ~S"""
      allow:
        - localhost
        - %.sourceforge.net
        - %.freepan.org

      """

      encoded_sequence_in_a_map = Yamel.encode!(sequence_in_map_shortcut)
      refute encoded_sequence_in_a_map == sequence_in_map_shortcut_yaml
      assert encoded_sequence_in_a_map == sequence_in_map_yaml
    end

    test "when structure has different value types" do
      value = ["açaí", :banana, :"whey protein", 300, :g, total: 10.23]

      different_value_types_yaml = ~S"""
      - açaí
      - banana
      - whey protein
      - 300
      - g
      -
        total: 10.23

      """

      encoded_different_value_types = Yamel.encode!(value)
      assert encoded_different_value_types == different_value_types_yaml
    end

    test "when value is other than map or list" do
      assert_raise ArgumentError, fn ->
        Yamel.encode!(124)
      end
    end
  end

  describe "encode/1" do
    test "when value is other than map or list" do
      assert {:error, "Unsupported value: 123"} = Yamel.encode(123)
    end
  end
end
