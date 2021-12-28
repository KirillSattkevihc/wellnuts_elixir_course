defmodule Solution do
  @spec roman_to_int(s :: String.t) :: integer
  def roman_to_int(s) do
    s = if not is_list(s), do: String.codepoints(s), else: s
        value = %{
            "I" => 1, "V" => 5, "X" => 10, "L" => 50,
            "C" => 100, "D" => 500,"M" => 1000  }
        case s do
            []-> 0
            [h]-> value[h]
            [h1,h2|tail]->
            case {value[h1], value[h2]} do
                {v1, v2} when v1 < v2 -> v2 - v1 + roman_to_int(tail)
                {v1, _} -> v1 + roman_to_int([h2 | tail])
            end
            _-> "error"
        end

  end
end
