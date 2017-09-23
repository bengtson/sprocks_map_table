defmodule SprocksMapTable do
  @moduledoc """
  Documentation for SprocksMapTable.
  """

  def read_file file do
    SprocksMapTable.Reader.read_file file
  end

  def read_string string do
    SprocksMapTable.Reader.parse_string string
  end

  def get_value record, key do
    SprocksMapTable.Access.get_value record, key
  end

end
