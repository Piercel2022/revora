class OrderItemPolicy < ApplicationPolicy
  def index?
    same_organization?
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
    same_organization? && management_role?
  end

  class Scope < ApplicationPolicy::Scope
    def resolve
      scope
        .joins(order: :store)
        .where(stores: { organization_id: user.organization_id })
    end
  end

  private

  def same_organization?
    record.order.store.organization_id == user.organization_id
  end

  def management_role?
    user.owner? || user.admin?
  end
end
