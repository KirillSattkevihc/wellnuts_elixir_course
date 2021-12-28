# Definition for a binary tree node.
#
defmodule TreeNode do
  @type t :: %__MODULE__{
          val: integer,
          left: TreeNode.t() | nil,
          right: TreeNode.t() | nil
       }
  defstruct val: 0, left: nil, right: nil
end

defmodule Solution do
 @spec has_path_sum(root :: TreeNode.t | nil, target_sum :: integer) :: boolean
 def has_path_sum(root, target_sum) do
     cond do
       is_nil(root)-> false
       (is_nil(root.left) && is_nil(root.right))-> target_sum==root.val
       true-> has_path_sum(root.left, target_sum - root.val) || has_path_sum(root.right, target_sum - root.val)
     end
 end
end
