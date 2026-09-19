module Api
  module V1
    class IntegrationsController < ApplicationController
      before_action :authenticate_user!
      before_action :set_integration, only: %i[show update destroy]

      def index
        integrations = policy_scope(Integration)

        render json: integration_payload(integrations)
      end

      def show
        authorize @integration

        render json: integration_payload(@integration)
      end

      def create
        organization = Organization.find(integration_params[:organization_id])

        integration = organization.integrations.new(
          integration_params.except(:organization_id)
        )

        authorize integration

        if integration.save
          render json: integration_payload(integration), status: :created
        else
          render_validation_errors(integration)
        end
      end

      def update
        authorize @integration

        if @integration.update(
          integration_params.except(:organization_id)
        )
          render json: integration_payload(@integration)
        else
          render_validation_errors(@integration)
        end
      end

      def destroy
        authorize @integration

        @integration.destroy

        head :no_content
      end

      private

      def set_integration
        @integration = Integration.find(params[:id])
      end

      def integration_params
        params.require(:integration).permit(
          :organization_id,
          :store_id,
          :provider,
          :kind,
          :name,
          :status,
          :external_id,
          credentials: {}
        )
      end

      def integration_payload(integrations)
        integrations.as_json(except: :credentials)
      end
    end
  end
end
