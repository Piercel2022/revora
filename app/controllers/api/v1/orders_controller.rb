module Api
  module V1
    class OrdersController < ApplicationController
      before_action :authenticate_user!
      before_action :set_order, only: %i[show update destroy]

      def index
        orders = policy_scope(Order)

        render json: orders
      end

      def show
        authorize @order

        render json: @order
      end

      def create
        store = Store.find(order_params[:store_id])
        order = store.orders.new(order_params.except(:store_id))

        authorize order

        if order.save
          render json: order, status: :created
        else
          render_validation_errors(order)
        end
      end

      def update
        authorize @order

        if @order.update(order_params.except(:store_id))
          render json: @order
        else
          render_validation_errors(@order)
        end
      end

      def destroy
        authorize @order

        @order.destroy

        head :no_content
      end

      private

      def set_order
        @order = Order.find(params[:id])
      end

      def order_params
        params.require(:order).permit(
          :store_id,
          :customer_id,
          :external_id,
          :order_number,
          :status,
          :currency,
          :subtotal,
          :tax,
          :shipping,
          :discount,
          :total,
          :ordered_at
        )
      end
    end
  end
end
