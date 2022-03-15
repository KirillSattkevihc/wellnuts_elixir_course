defmodule EventPlaningWeb.PlanControllerTest do
  use EventPlaningWeb.ConnCase

  alias EventPlaning.Events

  @create_attrs %{date: ~U[2022-03-02 13:30:00Z], repetition: "week"}
  @update_attrs %{date: ~U[2022-03-01 13:30:00Z], repetition: "week"}
  @pass "1234"
  def fixture(:plan) do
    {:ok, plan} = Events.create_plan(@create_attrs)
    plan
  end

  describe "index" do
    test "lists all plan", %{conn: conn} do
      conn = post(conn, Routes.page_path(conn, :login), %{"password" => %{"pass" => @pass}})
      conn = get(conn, Routes.plan_path(conn, :index))
      assert html_response(conn, 200) =~ "Listing Plan"
    end
  end

  describe "my schedule" do
    test "lists schedule", %{conn: conn} do
      conn = post(conn, Routes.page_path(conn, :login), %{"password" => %{"pass" => @pass}})
      conn = get(conn, Routes.plan_path(conn, :my_shedule))
      assert html_response(conn, 200) =~ "My Schedule"
    end
  end

  describe "next event" do
    test "next event", %{conn: conn} do
      conn = post(conn, Routes.page_path(conn, :login), %{"password" => %{"pass" => @pass}})
      conn = get(conn, Routes.plan_path(conn, :next_event))
      assert html_response(conn, 200) =~ "Next Event"
    end
  end

  describe "new plan" do
    test "renders form", %{conn: conn} do
      conn = post(conn, Routes.page_path(conn, :login), %{"password" => %{"pass" => @pass}})
      conn = get(conn, Routes.plan_path(conn, :new))
      assert html_response(conn, 200) =~ "New Plan"
    end
  end

  describe "edit plan" do
    setup [:create_plan]

    test "renders form for editing chosen plan", %{conn: conn, plan: plan} do
      conn = post(conn, Routes.page_path(conn, :login), %{"password" => %{"pass" => @pass}})
      conn = get(conn, Routes.plan_path(conn, :edit, plan))
      assert html_response(conn, 200) =~ "Edit Plan"
    end
  end

  describe "update plan" do
    setup [:create_plan]

    test "redirects when data is valid", %{conn: conn, plan: plan} do
      conn = post(conn, Routes.page_path(conn, :login), %{"password" => %{"pass" => @pass}})
      conn = put(conn, Routes.plan_path(conn, :update, plan), plan: @update_attrs)
      assert redirected_to(conn) == Routes.plan_path(conn, :index)
    end
  end


  describe "delete plan" do
    setup [:create_plan]

    test "deletes chosen plan", %{conn: conn, plan: plan} do
      conn = post(conn, Routes.page_path(conn, :login), %{"password" => %{"pass" => @pass}})
      conn = delete(conn, Routes.plan_path(conn, :delete, plan))
      assert redirected_to(conn) == Routes.plan_path(conn, :index)
    end
  end

  defp create_plan(_) do
    plan = fixture(:plan)
    %{plan: plan}
  end
end
