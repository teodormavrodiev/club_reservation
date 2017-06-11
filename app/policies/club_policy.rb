class ClubPolicy < ApplicationPolicy
  class Scope < Scope
    def resolve
      scope.all
    end
  end

  def show_map?
    scope.where(:id => record.id).exists?
  end

end
