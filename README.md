# SprocksMapTable

Version 0.2.0 : Fixed problem with zero record files returning with an empty
record instead of no records. Added checks to quickly return empty table.

## Installation

```elixir
def deps do
  [
    {:sprocks_map_table, "~> 0.2.0"}
  ]
end
`
