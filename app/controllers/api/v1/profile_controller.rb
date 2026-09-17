module Api
  module V1
    class ProfileController < ApplicationController
      before_action :authenticate_user!

      def show
        render json: {
          user: {
            id: current_user.id,
            email: current_user.email,
            first_name: current_user.first_name,
            last_name: current_user.last_name,
            role: current_user.role,
            organization_id: current_user.organization_id
          },
          organization: {
            id: current_organization.id,
            name: current_organization.name,
            slug: current_organization.slug,
            status: current_organization.status
          }
        }, status: :ok
      end
    end
  end
end
