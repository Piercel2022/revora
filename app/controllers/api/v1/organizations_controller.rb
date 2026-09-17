module Api
  module V1
    class OrganizationsController < ApplicationController
      before_action :authenticate_user!
      before_action :set_organization, only: :show

      def show
        authorize @organization

        render json: {
          id: @organization.id,
          name: @organization.name,
          slug: @organization.slug,
          status: @organization.status
        }, status: :ok
      end

      private

      def set_organization
        @organization = Organization.find(params[:id])
      end
    end
  end
end
