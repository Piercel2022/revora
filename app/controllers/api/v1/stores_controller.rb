module Api
  module V1
    class StoresController < ApplicationController
      before_action :authenticate_user!
      before_action :set_store, only: %i[show update destroy]

      def index
        stores = policy_scope(Store)

        render json: stores
      end

      def show
        authorize @store

        render json: @store
      end

      def create
        store = current_user.organization.stores.new(store_params)

        authorize store

        if store.save
          render json: store, status: :created
        else
          render json: {
            errors: store.errors.full_messages
          }, status: :unprocessable_entity
        end
      end

      def update
        authorize @store

        if @store.update(store_params)
          render json: @store
        else
          render json: {
            errors: @store.errors.full_messages
          }, status: :unprocessable_entity
        end
      end

      def destroy
        authorize @store

        @store.destroy

        head :no_content
      end

      private

      def set_store
        @store = Store.find(params[:id])
      end

      def store_params
        params.require(:store).permit(
          :name,
          :platform,
          :external_id,
          :currency,
          :timezone,
          :status
        )
      end
    end
  end
end
