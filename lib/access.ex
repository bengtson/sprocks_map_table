defmodule SprocksMapTable.Access do

  @doc """
  Returns the value for the FIRST matching key in the record, or error.

    {ok, value}
    {error, :not_found}
  """
  def get_value(record, key) do
    with {key, v} <- get_key_value(record, key)
    do
      {:ok, v}
    else
      nil -> {:error, :not_found}
    end
  end

  @doc """
  Returns the first key/value pair with the specified key or else nil.
  """
  def get_key_value record, key do
    record
    |> Enum.find(fn {a,_} -> a == key end)
  end

  @doc """
  Returns a list of all key/value pairs matching key.
  """
  def get_key_values record, key do
    record
    |> Enum.filter(fn {a, _} -> a == key end)
  end
end
