defmodule EventPlaningWeb.ScheduleChannelTest do
  use EventPlaningWeb.ChannelCase

  setup do
    {:ok, _, socket} =
      EventPlaningWeb.UserSocket
      |> socket("user_id", %{some: :assign})
      |> subscribe_and_join(EventPlaningWeb.ScheduleChannel, "schedule:lobby")

    %{socket: socket}
  end

  test "ping replies with status ok", %{socket: socket} do
    ref = push(socket, "ping", %{"hello" => "there"})
    assert_reply ref, :ok, %{"hello" => "there"}
  end

  test "delete broadcasts to schedule:lobby", %{socket: socket} do
    push(socket, "delete", %{"data" => "id"})
    assert_broadcast "delete", %{id: id}
  end

  test "broadcasts are pushed to the client", %{socket: socket} do
    broadcast_from!(socket, "broadcast", %{"some" => "data"})
    assert_push "broadcast", %{"some" => "data"}
  end
end
