defmodule EventPlaning.EventsTest do
  use EventPlaning.DataCase

  alias EventPlaning.Events

  describe "plan" do
    alias EventPlaning.Events.Plan

    @valid_attrs %{date: "2010-04-17T14:00:00Z", repetition: "some repetition"}
    @update_attrs %{date: "2011-05-18T15:01:01Z", repetition: "some updated repetition"}
    @invalid_attrs %{date: nil, repetition: nil}

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
      assert plan.date == DateTime.from_naive!(~N[2010-04-17T14:00:00Z], "Etc/UTC")
      assert plan.repetition == "some repetition"
    end

    test "create_plan/1 with invalid data returns error changeset" do
      assert {:error, %Ecto.Changeset{}} = Events.create_plan(@invalid_attrs)
    end

    test "update_plan/2 with valid data updates the plan" do
      plan = plan_fixture()
      assert {:ok, %Plan{} = plan} = Events.update_plan(plan, @update_attrs)
      assert plan.date == DateTime.from_naive!(~N[2011-05-18T15:01:01Z], "Etc/UTC")
      assert plan.repetition == "some updated repetition"
    end

    test "update_plan/2 with invalid data returns error changeset" do
      plan = plan_fixture()
      assert {:error, %Ecto.Changeset{}} = Events.update_plan(plan, @invalid_attrs)
      assert plan == Events.get_plan!(plan.id)
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
