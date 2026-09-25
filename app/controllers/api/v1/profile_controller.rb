module Api
  module V1
    class ProfileController < ApplicationController
      before_action :authenticate_user!

      def show
        render_profile
      end

      def update
        if current_user.update(profile_params)
          render_profile
        else
          render json: {
            error: "Validation failed",
            details: current_user.errors.full_messages
          }, status: :unprocessable_entity
        end
      end

      def update_avatar
        avatar = params[:avatar]

        if avatar.blank?
          return render json: {
            error: "Avatar is required"
          }, status: :unprocessable_entity
        end

        unless %w[image/jpeg image/png image/webp].include?(avatar.content_type)
          return render json: {
            error: "Avatar must be a JPEG, PNG, or WebP image"
          }, status: :unprocessable_entity
        end

        if avatar.size > 5.megabytes
          return render json: {
            error: "Avatar must be smaller than 5 MB"
          }, status: :unprocessable_entity
        end

        current_user.avatar.attach(avatar)

        render_profile
      end

      def destroy_avatar
        current_user.avatar.purge

        render_profile
      end

      private

      def profile_params
        params.require(:user).permit(
          :first_name,
          :last_name,
          :email
        )
      end

      def render_profile
        render json: {
          user: {
            id: current_user.id,
            email: current_user.email,
            first_name: current_user.first_name,
            last_name: current_user.last_name,
            role: current_user.role,
            organization_id: current_user.organization_id,
            avatar_url: avatar_url
          },
          organization: {
            id: current_organization.id,
            name: current_organization.name,
            slug: current_organization.slug,
            status: current_organization.status
          }
        }, status: :ok
      end

      def avatar_url
        return nil unless current_user.avatar.attached?

        rails_blob_url(
          current_user.avatar,
          host: request.base_url
        )
      end
    end
  end
end
