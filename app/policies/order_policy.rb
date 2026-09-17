class OrderPolicy < ApplicationPolicy
  def index?
    true
  end

  def show?
    same_organization?
  end

  def create?
    same_organization? && management_role?
  end

  def update?
    same_organization? && management_role?
  end

  def destroy?
    same_organization? && user.owner?
  end

  class Scope < ApplicationPolicy::Scope
    def resolve
      scope.joins(:store).where(
        stores: { organization_id: user.organization_id }
      )
    end
  end

  private

  def same_organization?
    record.store.organization_id == user.organization_id
  end

  def management_role?
    user.owner? || user.admin?
  end
end
