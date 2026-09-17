class OrganizationPolicy < ApplicationPolicy
  def index?
    false
  end

  def show?
    same_organization?
  end

  def update?
    same_organization? && management_role?
  end

  def destroy?
    same_organization? && user.owner?
  end

  class Scope < ApplicationPolicy::Scope
    def resolve
      scope.where(id: user.organization_id)
    end
  end

  private

  def same_organization?
    record.id == user.organization_id
  end

  def management_role?
    user.owner? || user.admin?
  end
end
