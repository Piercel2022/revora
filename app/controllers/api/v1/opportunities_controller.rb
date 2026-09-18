module Api
  module V1
    class OpportunitiesController < ApplicationController
      before_action :authenticate_user!
      before_action :set_opportunity, only: %i[show update destroy]

      def index
        opportunities = policy_scope(Opportunity)

        render json: opportunities
      end

      def show
        authorize @opportunity

        render json: @opportunity
      end

      def create
        organization = Organization.find(opportunity_params[:organization_id])

        opportunity = organization.opportunities.new(
          opportunity_params.except(:organization_id)
        )

        authorize opportunity

        if opportunity.save
          render json: opportunity, status: :created
        else
          render json: {
            errors: opportunity.errors.full_messages
          }, status: :unprocessable_entity
        end
      end

      def update
        authorize @opportunity

        if @opportunity.update(
          opportunity_params.except(:organization_id)
        )
          render json: @opportunity
        else
          render json: {
            errors: @opportunity.errors.full_messages
          }, status: :unprocessable_entity
        end
      end

      def destroy
        authorize @opportunity

        @opportunity.destroy

        head :no_content
      end

      private

      def set_opportunity
        @opportunity = Opportunity.find(params[:id])
      end

      def opportunity_params
        params.require(:opportunity).permit(
          :organization_id,
          :store_id,
          :customer_id,
          :name,
          :status,
          :value,
          :expected_close_at
        )
      end
    end
  end
end
