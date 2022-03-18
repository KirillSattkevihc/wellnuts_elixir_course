alias EventPlaning.Events.Plan

defimpl Ability, for: Plan do
  def can?(plan, _action, current_user) do
    if current_user.role == "user" do
      plan.users_id == current_user.id
    else
      true
    end
  end
end
