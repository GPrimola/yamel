defmodule Yamel.EncoderTest do
  use ExUnit.Case

  alias Yamel.Encoder
  alias Yamel.EncoderTest.{EncodeStructTest, EncodeDerivedExceptStructTest, EncodeDerivedStructTest}

  describe "encode/1" do
    test "default opts" do
      map_set = MapSet.new([1, :two, "three", {:four}, five: :six])
      # => #MapSet<[1, :two, {:four}, {:five, :six}, "three"]>

      expected_yaml = ~S"""
      - 1
      - two
      -
        - four
      -
        five: six
      - three
      """

      encoded_map_set_yaml = Encoder.encode(map_set)
      assert encoded_map_set_yaml == expected_yaml
    end

    test "with custom required opts" do
      map_set = MapSet.new([1, :two, "three", {:four}, five: :six])
      # => #MapSet<[1, :two, {:four}, {:five, :six}, "three"]>

      expected_yaml = ~S"""
          - 1
          - two
          -
              - four
          -
              five: six
          - three
      """

      encoded_map_set_yaml = Encoder.encode(map_set, %{node_level: 1, indent_size: 4})
      assert encoded_map_set_yaml == expected_yaml
    end

    test "type Range" do
      range = 1..10

      expected_yaml = ~S"""
      - 1
      - 2
      - 3
      - 4
      - 5
      - 6
      - 7
      - 8
      - 9
      - 10
      """

      encoded_range_yaml = Encoder.encode(range)
      assert encoded_range_yaml == expected_yaml
    end

    test "type Date.Range" do
      date_range = Date.range(~D[1999-01-01], ~D[1999-01-10])

      expected_yaml = ~S"""
      - 1999-01-01
      - 1999-01-02
      - 1999-01-03
      - 1999-01-04
      - 1999-01-05
      - 1999-01-06
      - 1999-01-07
      - 1999-01-08
      - 1999-01-09
      - 1999-01-10
      """

      encoded_date_range_yaml = Encoder.encode(date_range)
      assert encoded_date_range_yaml == expected_yaml
    end

    test "type MapSet" do
      map_set = MapSet.new([1, :two, "three", {:four}, five: :six])
      # => #MapSet<[1, :two, {:four}, {:five, :six}, "three"]>

      expected_yaml = ~S"""
      - 1
      - two
      -
        - four
      -
        five: six
      - three
      """

      encoded_map_set_yaml = Encoder.encode(map_set)
      assert encoded_map_set_yaml == expected_yaml
    end

    test "type Tuple" do
      tuple = {1, :two, "three", [:four], nil, true, %{foo: :bar}}

      expected_yaml = ~S"""
      - 1
      - two
      - three
      -
        - four
      - null
      - true
      -
        foo: bar
      """

      encoded_tuple_yaml = Encoder.encode(tuple)
      assert encoded_tuple_yaml == expected_yaml
    end

    test "type Stream" do
      stream =
        {1, :two, "three", [:four], nil, true, %{foo: :bar}}
        |> Tuple.to_list()
        |> Stream.cycle()
        |> Stream.take(7)

      expected_yaml = ~S"""
      - 1
      - two
      - three
      -
        - four
      - null
      - true
      -
        foo: bar
      """

      encoded_stream_yaml = Encoder.encode(stream)
      assert encoded_stream_yaml == expected_yaml
    end

    test "type ordinary struct" do
      strct = %EncodeStructTest{field1: "first field", field3: "the third"}

      expected_yaml = ~S"""
      field1: first field
      field2: null
      field3: the third
      field4: true
      """

      encoded_strct_yaml = Encoder.encode(strct)
      assert encoded_strct_yaml == expected_yaml
    end

    test "type derived struct" do
      strct = %EncodeDerivedStructTest{field1: "first field", field3: "the third"}

      expected_yaml = ~S"""
      field4: true
      """

      encoded_strct_yaml = Encoder.encode(strct)
      assert encoded_strct_yaml == expected_yaml
    end

    test "type derived with except fields struct" do
      strct = %EncodeDerivedExceptStructTest{field1: "first field", field3: "the third"}

      expected_yaml = ~S"""
      field1: first field
      field2: null
      field3: the third
      """

      encoded_strct_yaml = Encoder.encode(strct)
      assert encoded_strct_yaml == expected_yaml
    end
  end
end
