defmodule Grakn.Graql do
  alias Grakn.Query

  defmodule Datatypes do
    defstruct string: :string,
              long: :long,
              double: :double,
              boolean: :boolean,
              date: :date
  end

  defmacro __using__([]) do
    quote do
      import Grakn.Graql
    end
  end

  def datatypes, do: %Datatypes{}

  defmacro define(label, [sub: :entity] = opts), do: define_body(label, opts)
  defmacro define(label, [sub: :entity, has: _] = opts), do: define_body(label, opts)
  defmacro define(label, [sub: :entity, plays: _] = opts), do: define_body(label, opts)
  defmacro define(label, [sub: :entity, has: _, plays: _] = opts), do: define_body(label, opts)
  defmacro define(label, [sub: :entity, plays: _, has: _] = opts), do: define_body(label, opts)
  defmacro define(label, sub: :attribute), do: define_body(label, sub: :attribute)
  defmacro define(label, [sub: :attribute, datatype: _] = opts), do: define_body(label, opts)
  defmacro define(label, [sub: :relationship, relates: _] = opts), do: define_body(label, opts)

  defmacro define(label, [sub: :relationship, relates: _, has: _] = opts),
    do: define_body(label, opts)

  # Allow any arbitrary sub types
  defmacro define(label, [sub: _type] = opts), do: define_body(label, opts)
  defmacro define(label, [sub: _type, has: _] = opts), do: define_body(label, opts)
  defmacro define(label, [sub: _type, plays: _] = opts), do: define_body(label, opts)
  defmacro define(label, [sub: _type, has: _, plays: _] = opts), do: define_body(label, opts)
  defmacro define(label, [sub: _type, plays: _, has: _] = opts), do: define_body(label, opts)
  defmacro define(label, [sub: _type, relates: _] = opts), do: define_body(label, opts)

  defmacro define(label, opts), do: error(label, opts)

  defp error(label, opts), do: raise("Graql compile error: #{inspect({label, opts})}")

  defp define_body(label, opts) do
    quote do
      modifiers =
        unquote(opts)
        |> Enum.map(&expand_key_values/1)
        |> Enum.join(", ")

      Query.graql("define #{unquote(label)} #{modifiers};")
    end
  end

  def expand_key_values({key, [_ | _] = values}) do
    values
    |> Enum.map(fn value -> "#{key} #{value}" end)
    |> Enum.join(", ")
  end

  def expand_key_values({key, value}), do: "#{key} #{value}"
end
