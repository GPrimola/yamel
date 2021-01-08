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
      assert_raise(YamlElixir.ParsingError, "malformed yaml", fn ->
        Yamel.IO.read!(@invalid_yml)
      end)
    end
  end

  describe "read/1" do
    test "should read a valid YAML file" do
      assert {:ok, result} = Yamel.IO.read(@valid_yml)
      assert is_map(result)
    end

    test "should return {:error, reason} with an invalid YAML file" do
      assert {:error, reason} = Yamel.IO.read(@invalid_yml)
      assert %YamlElixir.ParsingError{message: "malformed yaml"} = reason
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
      assert {:error, %{message: "malformed yaml"}} = Yamel.IO.write(yaml, yaml_path)
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

      assert_raise YamlElixir.ParsingError, "malformed yaml", fn ->
        Yamel.IO.write!(yaml, yaml_path)
      end

      refute File.exists?(yaml_path)
    end
  end
end
