defmodule Yamel.IOTest do
  use ExUnit.Case

  @valid_yml "test/fixtures/valid.yml"
  @invalid_yml "test/fixtures/invalid.yml"

  describe "read!/1" do
    test "should read a valid YAML file" do
      assert is_map(Yamel.IO.read!(@valid_yml))
    end

    test "should raise FileNotFoundError when file doesn't exist" do
      assert_raise(YamlElixir.FileNotFoundError, fn ->
        Yamel.IO.read!("file/doesnt/exist.yml")
      end)
    end

    test "should raise ? with an invalid YAML file" do
      assert_raise(
        YamlElixir.ParsingError,
        "Unexpected \"yamerl_collection_start\" token following a \"yamerl_collection_end\" token (line: 3, column: 1)",
        fn ->
          Yamel.IO.read!(@invalid_yml)
        end
      )
    end
  end

  describe "read/1" do
    test "should read a valid YAML file" do
      assert {:ok, result} = Yamel.IO.read(@valid_yml)
      assert is_map(result)
    end

    test "should return {:error, reason} with an invalid YAML file" do
      assert {:error, reason} = Yamel.IO.read(@invalid_yml)

      assert %YamlElixir.ParsingError{
               column: 1,
               line: 3,
               message:
                 "Unexpected \"yamerl_collection_start\" token following a \"yamerl_collection_end\" token",
               type: :unexpected_token
             } = reason
    end
  end

  describe "write/2" do
    test "should write to file when yaml string is valid" do
      yaml = "foo: bar"
      yaml_path = "test/fixtures/test.yaml"
      refute File.exists?(yaml_path)
      :ok = Yamel.IO.write(yaml, yaml_path)
      assert File.exists?(yaml_path)
      File.rm!(yaml_path)
    end

    test "should return {:error, reason} and not write to file when yaml string is invalid" do
      yaml = """
      invalid: foo: bar: zoo:
      """

      yaml_path = "test/fixtures/test.yaml"
      refute File.exists?(yaml_path)

      assert {:error,
              %YamlElixir.ParsingError{
                column: 13,
                line: 1,
                message: "Block mapping value not allowed here",
                type: :block_mapping_value_not_allowed
              }} = Yamel.IO.write(yaml, yaml_path)

      refute File.exists?(yaml_path)
    end
  end

  describe "write!/2" do
    test "should write to file when yaml string is valid" do
      yaml = "foo: bar"
      yaml_path = "test/fixtures/test.yaml"
      refute File.exists?(yaml_path)
      :ok = Yamel.IO.write!(yaml, yaml_path)
      assert File.exists?(yaml_path)
      File.rm!(yaml_path)
    end

    test "should raise error and not write to file when yaml string is invalid" do
      yaml = """
      invalid: foo: bar: zoo:
      """

      yaml_path = "test/fixtures/test.yaml"
      refute File.exists?(yaml_path)

      assert_raise YamlElixir.ParsingError,
                   "Block mapping value not allowed here (line: 1, column: 13)",
                   fn ->
                     Yamel.IO.write!(yaml, yaml_path)
                   end

      refute File.exists?(yaml_path)
    end
  end
end
