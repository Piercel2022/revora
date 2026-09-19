module Api
  module V1
    class AuthController < ApplicationController
      before_action :authenticate_user!, only: :me

      def register
        organization = nil
        user = nil

        ActiveRecord::Base.transaction do
          organization = Organization.create!(organization_params)

          user = organization.users.create!(
            user_params.merge(role: "owner")
          )
        end

        render json: {
          token: JwtService.encode(user),
          user: user_json(user),
          organization: organization_json(organization)
        }, status: :created
        rescue ActiveRecord::RecordInvalid => e
         render_validation_errors(e.record)
      end

      def login
        organization = Organization.find_by(
          slug: params[:organization_slug]
        )

        user = organization&.users&.find_by(
          email: params[:email]
        )

        unless user&.authenticate(params[:password])
          render json: {
            error: "Invalid email, password, or organization"
          }, status: :unauthorized
          return
        end

        render json: {
          token: JwtService.encode(user),
          user: user_json(user),
          organization: organization_json(organization)
        }, status: :ok
      end

      def me
        render json: {
          user: user_json(current_user),
          organization: organization_json(current_organization)
        }, status: :ok
      end

      private

      def organization_params
        params.require(:organization).permit(
          :name,
          :slug
        )
      end

      def user_params
        params.require(:user).permit(
          :first_name,
          :last_name,
          :email,
          :password,
          :password_confirmation
        )
      end

      def user_json(user)
        {
          id: user.id,
          email: user.email,
          first_name: user.first_name,
          last_name: user.last_name,
          role: user.role,
          organization_id: user.organization_id
        }
      end

      def organization_json(organization)
        {
          id: organization.id,
          name: organization.name,
          slug: organization.slug,
          status: organization.status
        }
      end
    end
  end
end