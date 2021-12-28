defmodule Solution do
  @spec is_valid(s :: String.t) :: boolean
  def is_valid(s) do
    s = if not is_list(s), do: String.codepoints(s), else: s
    mp=%{")"=>"(", "]"=>"[", "}"=>"{"}
    case s do
      []-> true
      s when rem(length(s),2)!=0 ->false
      [_|tail]->
      i= Enum.find_index(s, fn x -> x in Map.keys(mp) end)
      if (is_integer(i) && i>0 && Enum.at(s,i-1)==Map.get(mp,Enum.at(s,i))) do
        s=List.delete_at(s,i)
        s=List.delete_at(s,i-1)
        Solution.is_valid(s)
      else false
        end
      _-> false
    end
  end
end
