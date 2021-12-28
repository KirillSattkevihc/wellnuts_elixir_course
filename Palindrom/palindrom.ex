defmodule Solution do
  @spec is_palindrome(x :: integer) :: boolean
  def is_palindrome(x) do
    t= String.reverse(to_string(x))
    t== to_string(x)


 end
end
