defimpl Ability, for: EventPlaning.Events.Plan do
  def can?(plan, _action, current_user) do
    if current_user.role == "user" do
      plan.users_id == current_user.id
    else
      true
    end
  end
end
