defmodule EventPlaningWeb.ScheduleChannel do
  use EventPlaningWeb, :channel
  import Ecto.Query
  alias EventPlaning.{Repo, Events}
  alias EventPlaning.Events.Plan
  import Phoenix.HTML
  import Phoenix.HTML.Link

  intercept(["create", "edit"])

  @impl true
  def join("schedule:lobby", payload, socket) do
    if authorized?(payload) do
      send(self(), :after_join)
      {:ok, socket}
    else
      {:error, %{reason: "unauthorized"}}
    end
  end

  # Channels can be used in a request/response fashion
  # by sending replies to requests from the client

  @impl true
  def handle_in("ping", payload, socket) do
    {:reply, {:ok, payload}, socket}
  end

  # It is also common to receive messages from the client and
  # broadcast to everyone in the current topic (schedule:lobby).

  # Delete Events
  @impl true
  def handle_in("delete", %{"data" => id}, socket) do
    broadcast(socket, "delete", %{id: id})
    {:noreply, socket}
  end

  @impl true
  def handle_out("delete", msg, socket) do
    push(socket, "delete", msg)
    {:noreply, socket}
  end

  # Create Events
  @impl true
  def handle_in("create", %{"data" => data}, socket) do
    new_data = data_replacer(data) |> Events.create_plan()
    broadcast(socket, "create", %{id: new_data.id})
    {:noreply, socket}
  end

  @impl true
  def handle_out("create", msg, socket) do
    push(
      socket,
      "create",
      Map.merge(
        msg,
        %{html_event: html_gen(Events.get_plan(msg.id))}
      )
    )

    {:noreply, socket}
  end

  # Edit Events
  @impl true
  def handle_in("edit", %{"data" => data}, socket) do
    new_data = data_replacer(data)

    plan =
      data["id"]
      |> Events.get_plan()
      |> Events.update_plan!(new_data)

    broadcast(socket, "edit", %{id: plan.id})
    {:noreply, socket}
  end

  @impl true
  def handle_out("edit", msg, socket) do
    push(
      socket,
      "edit",
      Map.merge(
        msg,
        %{html_event: html_gen(Events.get_plan(msg.id))}
      )
    )

    {:noreply, socket}
  end

  defp data_replacer(data) do
    %{
      "date" => %{
        "day" => data["date_day"],
        "hour" => data["date_hour"],
        "minute" => data["date_minute"],
        "month" => data["date_month"],
        "year" => data["date_year"]
      },
      "repetition" => data["repetition"]
    }
  end

  def html_gen(msg) do
    ~E"""
    <td><%= msg.date %></td>
    <td><%= msg.repetition %></td>
    <td>
      <span><%= link "Show", to: "plan/" <> Integer.to_string(msg.id) %></span>
      <span><%= link "Edit", to: "plan/" <> Integer.to_string(msg.id)<> "/edit" %></span>
      <span><%= link "Delete", to: "plan/",  method: :delete, id: "delete" %></span>
    </td>
    """
    |> safe_to_string()
  end

  # Add authorization logic here as required.
  defp authorized?(_payload) do
    true
  end
end
