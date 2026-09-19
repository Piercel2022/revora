module Api
  module V1
    class SegmentsController < ApplicationController
      before_action :authenticate_user!
      before_action :set_segment, only: %i[show update destroy]

      def index
        segments = policy_scope(Segment)

        render json: segments
      end

      def show
        authorize @segment

        render json: @segment
      end

      def create
        organization = Organization.find(segment_params[:organization_id])
        segment = organization.segments.new(
          segment_params.except(:organization_id)
        )

        authorize segment

        if segment.save
          render json: segment, status: :created
        else
          render_validation_errors(segment)
        end
      end

      def update
        authorize @segment

        if @segment.update(
          segment_params.except(:organization_id)
        )
          render json: @segment
        else
          render_validation_errors(@segment)
        end
      end

      def destroy
        authorize @segment

        @segment.destroy

        head :no_content
      end

      private

      def set_segment
        @segment = Segment.find(params[:id])
      end

      def segment_params
        params.require(:segment).permit(
          :organization_id,
          :name,
          :description,
          :status
        )
      end
    end
  end
end
