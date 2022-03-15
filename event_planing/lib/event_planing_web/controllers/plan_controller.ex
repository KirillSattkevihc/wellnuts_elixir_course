defmodule EventPlaningWeb.PlanController do
  use EventPlaningWeb, :controller
  plug :check_user
  import Ecto.Query
  alias EventPlaning.{Repo, Events}
  alias EventPlaning.Events.Plan


  @day_sec 60 * 60 * 24

  def index(conn, _params) do
    plan = Events.list_plan()
    render(conn, "index.html", plan: plan)
  end

  def check_user(conn, _params) do
    if conn.assigns[:password] do
      conn
    else
      conn
      |> put_flash(:error, "you don't logged")
      |> redirect(to: Routes.page_path(conn, :entry))
      |> halt()
    end
  end

  def new(conn, _params) do
    changeset = Events.change_plan(%Plan{})
    render(conn, "new.html", changeset: changeset)
  end

  def create(conn, _params) do
    conn
    |> put_flash(:info, "Plan created successfully.")
    |> redirect(to: Routes.plan_path(conn, :index))
  end

  def show(conn, %{"id" => id}) do
    IO.puts "-----------"
    IO.inspect Events.get_plan(id)
    plan = Events.get_plan(id)
    render(conn, "show.html", plan: plan)
  end

  def edit(conn, %{"id" => id}) do
    plan = Events.get_plan(id)
    changeset = Events.change_plan(plan)
    render(conn, "edit.html", plan: plan, changeset: changeset)
  end

  def update(conn, _params) do
    conn
    |> put_flash(:info, "Plan updated successfully.")
    |> redirect(to: Routes.plan_path(conn, :index))
  end

  def delete(conn, %{"id" => id}) do
    plan = Events.get_plan(id)
    {:ok, _plan} = Events.delete_plan(plan)

    conn
    |> put_flash(:info, "Plan deleted successfully.")
    |> redirect(to: Routes.plan_path(conn, :index))
  end

  def my_shedule(conn, %{"repetition" => %{"rep" => rep}} = params) do
    plan = check_interval(rep)
    render(conn, "my_shedule.html", plan: plan)
  end

  def my_shedule(conn, _params) do
    plan = check_interval("week")
    render(conn, "my_shedule.html", plan: plan)
  end

  def next_event(conn, _params) do
    if Enum.any?(check_db()) do
      event =
        check_db
        |> Enum.map(fn x ->
          %{
            date: x.date,
            repetition: x.repetition,
            time_to: DateTime.diff(x.date, DateTime.utc_now())
          }
        end)
        |> Enum.min_by(& &1.time_to)

      render(conn, "next_event.html", event: event, next_event: true)
    else
      render(conn, "next_event.html", next_event: false)
    end
  end

  defp check_db() do
    x =
      from(m in Plan)
      |> Repo.all()
      |> Enum.reject(fn x -> x.repetition == "none" and x.date < DateTime.now!("Etc/UTC") end)
      |> Enum.map(fn x ->
        %{id: x.id, date: use_repetition(x.id, x.date, x.repetition), repetition: x.repetition}
      end)
      |> conflicted_events()
  end

  def conflicted_events(events) do
    Enum.map(events, fn y ->
      %{
        id: y.id,
        date: y.date,
        repetition: y.repetition,
        count_events: Enum.count(events, fn x -> x.date == y.date end)
      }
    end)
  end

  defp check_interval("week") do
    now = Date.utc_today()
    check_db() |> Enum.filter(fn x -> Date.diff(Date.end_of_week(now), x.date) >= 0 end)
  end

  defp check_interval("month") do
    now = Date.utc_today()
    check_db() |> Enum.filter(fn x -> Date.diff(Date.end_of_month(now), x.date) >= 0 end)
  end

  defp check_interval("year") do
    last_year_day = Date.new!(Date.utc_today().year + 1, 01, 01)
    check_db() |> Enum.filter(fn x -> Date.diff(last_year_day, x.date) > 0 end)
  end

  defp use_repetition(date, "day") do
    case date_diff?(date, DateTime.utc_now()) do
      true-> date
      false-> DateTime.add(date, @day_sec )|> use_repetition( "day")
    end
  end

  defp use_repetition(date, "week") do
    case date_diff?(date, DateTime.utc_now()) do
      true-> date
      false-> DateTime.add(date, @day_sec * 7)|> use_repetition( "week")
    end
  end

  defp use_repetition(date, "month") do
    case date_diff?(date, DateTime.utc_now()) do
      true-> date
      false-> DateTime.add(date, @day_sec * Date.days_in_month(date))|> use_repetition( "month")
    end
  end

  defp use_repetition(date, "year") do
    case date_diff?(date, DateTime.utc_now()) do
      true-> date
      false->  DateTime.add(date, @day_sec * 365)|> use_repetition( "year")
    end
  end

  defp use_repetition(date, "none") do
    date
  end

  defp date_diff?(date, now) do
    DateTime.diff(date, now)>0
  end
end
