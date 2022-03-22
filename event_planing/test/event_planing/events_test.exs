defmodule EventPlaning.EventsTest do
  use EventPlaning.DataCase

  alias EventPlaning.Events

  describe "plan" do
    alias EventPlaning.Events.Plan

    @valid_attrs %{date: ~U[2022-03-02 13:30:00Z], repetition: "week"}
    @update_attrs %{date: ~U[2022-03-03 13:30:00Z], repetition: "month"}

    def plan_fixture(attrs \\ %{}) do
      {:ok, plan} =
        attrs
        |> Enum.into(@valid_attrs)
        |> Events.create_plan()

      plan
    end

    test "list_plan/0 returns all plan" do
      plan = plan_fixture()
      assert Events.list_plan() == [plan]
    end

    test "get_plan!/1 returns the plan with given id" do
      plan = plan_fixture()
      assert Events.get_plan!(plan.id) == plan
    end

    test "create_plan/1 with valid data creates a plan" do
      assert {:ok, %Plan{} = plan} = Events.create_plan(@valid_attrs)
      assert plan.date == ~U[2022-03-02 13:30:00.000000Z]
      assert plan.repetition == "week"
    end

    test "update_plan/2 with valid data updates the plan" do
      plan = plan_fixture()
      assert {:ok, %Plan{} = plan} = Events.update_plan(plan, @update_attrs)
      assert plan.date == ~U[2022-03-03 13:30:00.000000Z]
      assert plan.repetition == "month"
    end

    test "delete_plan/1 deletes the plan" do
      plan = plan_fixture()
      assert {:ok, %Plan{}} = Events.delete_plan(plan)
      assert_raise Ecto.NoResultsError, fn -> Events.get_plan!(plan.id) end
    end

    test "change_plan/1 returns a plan changeset" do
      plan = plan_fixture()
      assert %Ecto.Changeset{} = Events.change_plan(plan)
    end
  end
end
