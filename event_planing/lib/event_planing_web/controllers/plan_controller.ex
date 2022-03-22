defmodule EventPlaningWeb.PlanController do
  use EventPlaningWeb, :controller
  plug :check_user
  import Ecto.Query
  import Ecto
  alias Ecto.Multi
  alias EventPlaning.Events
  alias EventPlaning.{Repo, Events.Plan}

  @day_sec 60 * 60 * 24

  def check_user(conn, _params) do
    if conn.assigns[:user_info] do
      conn
    else
      conn
      |> put_flash(:error, "you don't logged")
      |> redirect(to: Routes.page_path(conn, :entry))
      |> halt()
    end
  end

  def index(conn, _params, file \\ nil) do
    user = conn.assigns[:user_info]

    plan =
      if user.role == "admin" do
        Events.list_plan()
      else
        Events.list_plan(user)
      end

    render(conn, "index.html", plan: plan)
  end

  def new(conn, _params) do
    changeset = Events.change_plan(%Plan{})
    render(conn, "new.html", changeset: changeset)
  end

  def create(conn, %{"ics" => ics}) do
    init_db(conn.assigns[:user_info], ics.path)

    conn
    |> put_flash(:info, "Plans upload successfully.")
    |> redirect(to: Routes.user_plan_path(conn, :index, :user_info))
  end

  def create(conn, _params) do
    conn
    |> put_flash(:info, "Plan created successfully.")
    |> redirect(to: Routes.user_plan_path(conn, :index, :user_info))
  end

  def show(conn, %{"id" => id}) do
    case Events.get_plan(id) do
      %Plan{} = plan ->
        if Ability.can?(plan, :update, conn.assigns[:user_info]) do
          render(conn, "show.html", plan: plan)
        else
          conn
          |> put_flash(:info, "Your abilities aren't strong.")
          |> redirect(to: Routes.user_plan_path(conn, :index, :user_info))
        end

      nil ->
        conn
        |> put_flash(:info, "Bad plan id.")
        |> redirect(to: Routes.page_path(conn, :index))
    end
  end

  def edit(conn, %{"id" => id}) do
    case Events.get_plan(id) do
      %Plan{} = plan ->
        if Ability.can?(plan, :update, conn.assigns[:user_info]) do
          changeset = Events.change_plan(plan)
          render(conn, "edit.html", plan: plan, changeset: changeset)
        else
          conn
          |> put_flash(:info, "Your abilities aren't strong.")
          |> redirect(to: Routes.user_plan_path(conn, :index, :user_info))
        end

      nil ->
        conn
        |> put_flash(:info, "Bad  plan id.")
        |> redirect(to: Routes.page_path(conn, :index))
    end
  end

  def update(conn, _params) do
    conn
    |> put_flash(:info, "Plan updated successfully.")
    |> redirect(to: Routes.user_plan_path(conn, :index, :user_info))
  end

  def delete(conn, %{"id" => id}) do
    plan = Events.get_plan(id)

    if Ability.can?(plan, :delete, conn.assigns[:user_info]) do
      {:ok, _plan} = Events.delete_plan(plan)

      conn
      |> put_flash(:info, "Plan deleted successfully.")
      |> redirect(to: Routes.user_plan_path(conn, :index, :u_id))
    else
      conn
      |> put_flash(:info, "Plan delete crash.")
      |> redirect(to: Routes.user_plan_path(conn, :index, :user_info))
    end
  end

  defp init_db(user_info, path) do
    File.read!(path)
    |> ICalendar.from_ics()
    |> Stream.map(fn x ->
      %{name: x.summary, date: x.dtstart, repetition: "year", users_id: user_info.id}
    end)
    |> Enum.reduce(Multi.new(), fn x, acc ->
      changeset = Plan.changeset(%Plan{}, x)
      Multi.insert(acc, x, changeset)
    end)
    |> Repo.transaction()
  end

  def my_shedule(conn, %{"repetition" => %{"rep" => rep}} = params) do
    user_info = conn.assigns[:user_info]
    plan = check_interval(rep, user_info)
    render(conn, "my_shedule.html", plan: plan)
  end

  def my_shedule(conn, _params) do
    user_info = conn.assigns[:user_info]
    plan = check_interval("week", user_info)
    render(conn, "my_shedule.html", plan: plan)
  end

  def next_event(conn, _params) do
    user_info = conn.assigns[:user_info]

    if Enum.any?(check_db(user_info)) do
      next_ev =
        check_db(user_info)
        |> Enum.map(fn x ->
          %{
            name: x.name,
            date: x.date,
            repetition: x.repetition,
            time_to: DateTime.diff(x.date, DateTime.utc_now())
          }
        end)
        |> Enum.min_by(& &1.time_to)

      render(conn, "next_event.html", plans: next_ev, next_event: true)
    else
      render(conn, "next_event.html", next_event: false)
    end
  end

  defp check_db(user_info) do
    from(m in Plan, where: m.users_id == ^user_info.id)
    |> Repo.all()
    |> Enum.reject(fn x -> x.repetition == "none" and x.date < DateTime.now!("Etc/UTC") end)
    |> Enum.map(fn x ->
      %{
        name: x.name,
        id: x.id,
        date: use_repetition(x.date, x.repetition),
        repetition: x.repetition
      }
    end)
    |> conflicted_events()
  end

  defp conflicted_events(plans) do
    Enum.map(plans, fn y ->
      %{
        name: y.name,
        id: y.id,
        date: y.date,
        repetition: y.repetition,
        count_events: Enum.count(plans, fn x -> x.date == y.date end)
      }
    end)
  end

  defp check_interval("week", user_info) do
    now = Date.utc_today()
    check_db(user_info) |> Enum.filter(fn x -> Date.diff(Date.end_of_week(now), x.date) >= 0 end)
  end

  defp check_interval("month", user_info) do
    now = Date.utc_today()
    check_db(user_info) |> Enum.filter(fn x -> Date.diff(Date.end_of_month(now), x.date) >= 0 end)
  end

  defp check_interval("year", user_info) do
    last_year_day = Date.new!(Date.utc_today().year + 1, 01, 01)
    check_db(user_info) |> Enum.filter(fn x -> Date.diff(last_year_day, x.date) > 0 end)
  end

  defp use_repetition(date, "day") do
    case date_diff?(date, DateTime.utc_now()) do
      true -> date
      false -> DateTime.add(date, @day_sec) |> use_repetition("day")
    end
  end

  defp use_repetition(date, "week") do
    case date_diff?(date, DateTime.utc_now()) do
      true -> date
      false -> DateTime.add(date, @day_sec * 7) |> use_repetition("week")
    end
  end

  defp use_repetition(date, "month") do
    case date_diff?(date, DateTime.utc_now()) do
      true -> date
      false -> DateTime.add(date, @day_sec * Date.days_in_month(date)) |> use_repetition("month")
    end
  end

  defp use_repetition(date, "year") do
    case date_diff?(date, DateTime.utc_now()) do
      true -> date
      false -> DateTime.add(date, @day_sec * 365) |> use_repetition("year")
    end
  end

  defp use_repetition(date, "none") do
    date
  end

  defp date_diff?(date, now) do
    DateTime.diff(date, now) > 0
  end
end
