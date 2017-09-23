defmodule SprocksMapTableTest do
  use ExUnit.Case
  doctest SprocksMapTable

  test "table file_read and get_value" do

    table = "test/data/two_record_file"
    |> SprocksMapTable.read_file
    assert length(table) == 2

    [a,b] = table
    assert {:ok, "22"} == SprocksMapTable.get_value(a,"Event Day")

  end

  test "string table read_file" do

    record = """
    :: TABLE :: main
    test :: value
    key :: another value
    """

    list = record
    |> SprocksMapTable.Reader.parse_string

    [ [{"test", v}, _]] = list
    assert v == "value"

  end
end
