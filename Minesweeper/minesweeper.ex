defmodule Solution do
  @spec update_board(board :: [[char]], click:: integer) :: [[char]]
  def update_board(board, click) do
    row= List.first(click)
    col= List.last(click)
    proc(board, row, col, Enum.at(Enum.at(board,row),col))
  end


  def proc(board, row, col, elem) when elem=="M"  do
    replaser(board,row,col,"X")
  end

  def proc(board, row, col, elem) when elem =="E"  do
    len_row= length(board)
    len_col= length(List.first(board))
    count=near_bombs(board, row, col, len_row, len_col)
    if count>0 do
      replaser(board,row,col,count)
    else
      board
      |>replaser(row,col,"B")
      |>near_elem(row,col,len_row,len_col)
    end
  end

  def proc(board, row, col, elem)  do
    board
  end




  def replaser(board,row,col,n_elem) do
    board= List.replace_at(board,row,List.replace_at(Enum.at(board,row),col,n_elem))
  end

  defp near_bombs(board, row, col, len_row, len_col) do
    nearby_el = [ {row - 1, col - 1}, {row - 1, col}, {row - 1, col + 1}, {row, col - 1}, {row, col + 1},{row + 1, col - 1}, {row + 1, col}, {row + 1, col + 1} ]
    |> Stream.filter(fn {nx, ny} when nx >= 0 and nx <  len_row and ny >= 0 and ny < len_col -> true
     _ -> false
     end)
    |> Stream.map(fn {row, col} -> board |> Enum.at(row) |> Enum.at(col) end)
    |> Enum.count(fn cell -> cell == "M" end)
  end

  def near_elem(board, row, col, len_row, len_col) do
    nearby_el =  [ {row - 1, col - 1}, {row - 1, col}, {row - 1, col + 1}, {row, col - 1}, {row, col + 1},{row + 1, col - 1}, {row + 1, col}, {row + 1, col + 1} ]
    |> Stream.filter(fn {row, col} when row >= 0 and row <  len_row and col >= 0 and col < len_col -> true
     _ -> false
     end)

    |> Enum.reduce(board, fn{row,col}, acc->update_board(acc,[row,col]) end)
  end
end

#Solution.update_board([["E","E","E","E","E"],["E","E","M","E","E"],["E","E","E","E","E"],["E","E","E","E","E"]],[3,0])
