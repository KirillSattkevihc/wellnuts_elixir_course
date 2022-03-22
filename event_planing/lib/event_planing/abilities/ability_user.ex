defimpl Ability, for: EventPlaning.Accounts.User do
  def can?(user, action, current_user) do
    if current_user.role == "user" do
      user.id == current_user.id
    else
      true
    end
  end
end
