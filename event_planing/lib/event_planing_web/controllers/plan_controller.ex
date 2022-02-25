defmodule EventPlaningWeb.PlanController do
  use EventPlaningWeb, :controller
  plug :check_user
  import Ecto.Query
  alias EventPlaning.{Repo, Events}
  alias EventPlaning.Events.Plan

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

  def create(conn, %{"plan" => plan_params}) do
    case Events.create_plan(plan_params) do
      {:ok, plan} ->
        conn
        |> put_flash(:info, "Plan created successfully.")
        |> redirect(to: Routes.plan_path(conn, :show, plan))

      {:error, %Ecto.Changeset{} = changeset} ->
        render(conn, "new.html", changeset: changeset)
    end
  end

  def show(conn, %{"id" => id}) do
    plan = Events.get_plan!(id)

    render(conn, "show.html", plan: plan)
  end

  def edit(conn, %{"id" => id}) do
    plan = Events.get_plan!(id)
    changeset = Events.change_plan(plan)
    render(conn, "edit.html", plan: plan, changeset: changeset)
  end

  def update(conn, %{"id" => id, "plan" => plan_params}) do
    plan = Events.get_plan!(id)

    case Events.update_plan(plan, plan_params) do
      {:ok, plan} ->
        conn
        |> put_flash(:info, "Plan updated successfully.")
        |> redirect(to: Routes.plan_path(conn, :show, plan))

      {:error, %Ecto.Changeset{} = changeset} ->
        render(conn, "edit.html", plan: plan, changeset: changeset)
    end
  end

  def delete(conn, %{"id" => id}) do
    plan = Events.get_plan!(id)
    {:ok, _plan} = Events.delete_plan(plan)

    conn
    |> put_flash(:info, "Plan deleted successfully.")
    |> redirect(to: Routes.plan_path(conn, :index))
  end


  def my_shedule(conn, %{"repetition"=>%{"rep" => rep}}= params) do
    plan= check_interval(rep)
    render(conn,"my_shedule.html", plan: plan)
  end

  def my_shedule(conn, _params) do
    plan= check_interval("week")

    render(conn,"my_shedule.html", plan: plan)
  end

  def next_event(conn, _params) do
    if check_db != [] do
      event=
      check_db
      |> Enum.map(fn x-> %{ date: x.date, repetition: x.repetition, time_to: DateTime.diff(x.date, DateTime.utc_now)} end)
      |> Enum.min_by(&(&1.time_to))
      render(conn, "next_event.html", event: event)
    else
      event = %{ date: "there are no date", repetition: "there are no events", time_to: 0}
      render(conn, "next_event.html", event: event)
    end
  end

  defp check_db() do
    x= from(m in Plan)
    |> Repo.all()
    |> Enum.reject(fn x -> x.repetition == "none" and x.date < DateTime.now!("Etc/UTC") end)
    |> Enum.map(fn x ->%{date: use_repetition(x.date, x.repetition) , repetition: x.repetition } end)
    |> conflicted_events()
  end

  def conflicted_events(events) do
    Enum.map(events, fn y-> %{date: y.date, repetition: y.repetition, count_events: Enum.count(events, fn x-> x.date==y.date end)} end)
  end

  defp check_interval("week") do
    now= Date.utc_today()
    check_db()|> Enum.filter(fn x->  Date.diff(Date.end_of_week(now), x.date)>=0 end)
  end

  defp check_interval("month") do
    now= Date.utc_today()
    check_db() |> Enum.filter(fn x->  Date.diff(Date.end_of_month(now), x.date)>=0 end)

  end

  defp check_interval("year") do
    last_year_day= Date.new!(Date.utc_today.year+1, 01 , 01)
    check_db() |> Enum.filter(fn x->  Date.diff(last_year_day, x.date)>0 end)
  end


  @day_sec 60* 60* 24

  def use_repetition(date, "day") do
    now = DateTime.utc_now
    if DateTime.diff(date, now) > 0 do
      date
    else
      date = DateTime.add(date, @day_sec)
      use_repetition(date, "day")
    end
  end

  def use_repetition(date, "week") do
    now = DateTime.utc_now
    if DateTime.diff(date, now) > 0 do
      date
    else
      date = DateTime.add(date, @day_sec * 7)
      use_repetition(date, "week")
    end
  end

  def use_repetition(date, "month") do
    now = DateTime.utc_now
    if DateTime.diff(date, now) > 0 do
      date
    else
      date = DateTime.add(date, @day_sec* Date.days_in_month(date))
      use_repetition(date, "month")
    end
  end

  def use_repetition(date, "year") do
    now = DateTime.utc_now
    if DateTime.diff(date, now) > 0 do
      date
    else
      date = DateTime.add(date, @day_sec * 365)
      use_repetition(date, "year")
    end
  end

  def use_repetition(date, "none") do
    date
  end

end
