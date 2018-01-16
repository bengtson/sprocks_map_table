defmodule SprocksMapTable.Reader do

  @doc """
  Given a Sprocks 'MapTable' formatted file, this returns a list of key/value
  records.
  """
  def read_file path do
    File.read!(path)
    |> String.split("\n")
    |> parse_lines
  end

  def parse_string string do
    string
    |> String.split("\n")
    |> parse_lines
  end

  @doc """
  Given a list of lines in the Sprocks 'MapTable' format, this returns a list
  of key/value records.

  Process requires two passes, one to collect the table and any nested tables
  then a second pass to put the nested tables into the main table.
  """
  def parse_lines([":: TABLE :: main",""]), do: []
  def parse_lines([":: TABLE :: main"]), do: []
  
  def parse_lines lines do
    lines
#      |> String.split("\n")
    |> get_tables(%{})
    |> insert_tables("main")
  end

  # --------- FIRST PASS Code

  # If no more lines provided, return the tables.
  def get_tables [], tables do
    tables
  end

  # Get every table specified in the file.
  def get_tables lines, tables do
    {table, name, lines} = get_next_table lines
    tables = Map.put(tables, name, table)
    get_tables lines, tables
  end

  # Scans forward to the first table in the data.
  # Parses the table found.
  # Returns {table, name, lines}
  def get_next_table [line | lines] do
    case parse_line line do
      [:table, name] ->
        parse_table [], [], name, lines
      _ ->
        get_next_table lines
    end
  end

  defp parse_table table, _record, name, [] do
    {table, name, []}
  end

  defp parse_table table, record, name, [line | lines] do
    case parse_line line do
      [:record, _type, k, v] ->
        parse_table table, record ++ [{k,v}], name, lines
      [:table, _] ->
        {table, name, [line | lines]}
      [:empty] ->
        parse_table table ++ [record], [], name, lines
    end
  end

  # Returns the following:
  #   {table: name}
  #   {:record, :string, key, value}
  #   {:record, :float, key, value}
  #   {:record, :integer, key, value}
  #   {:record, :maptable, key, {:maptable, name}}
  #   {:error, reason}
  def parse_line line do
    case String.split(line, ":") do
      [""] ->
        [:empty]
      ["", "", " TABLE ", "", name] ->
        [:table, trim(name)]
      [key, "" | value] ->
        [:record, :string, trim(key), trim(Enum.join(value, ":"))]
      [key, "Double", value] ->
        {float, _} = value |> trim |> Float.parse
        [:record, :float, trim(key), float]
      [key, "Integer", value] ->
        {int, _} = value |> trim |> Integer.parse
        [:record, :integer, trim(key), int]
      [key, "MapTable", value] ->
        [:record, :maptable, trim(key), {:maptable, trim(value)}]
      _ ->
        [:error, "Line Parse Problem: #{line}"]
    end
  end

  def trim string do
    String.trim string
  end

  # Scan the specified table inserting any nested tables.
  defp insert_tables tables, name do
    tables[name]
    |> Enum.map(&(insert_scan_record(&1, [name], tables)))
  end

  # Scan the provided record for nested tables.
  defp insert_scan_record record, _path, tables do
    record
    |> Enum.map(&(insert_scan_kv(&1, tables)))
  end

  # Scan the kv pair in the record for a nested table.
  defp insert_scan_kv {key, value}, tables do
    case value do
      {:maptable, name} ->
        {key, tables[String.trim(name)]}
      _ ->
        {key, value}
    end
  end

end
