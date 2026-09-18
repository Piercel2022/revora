module Api
  module V1
    class OrderItemsController < ApplicationController
      before_action :authenticate_user!
      before_action :set_order
      before_action :set_order_item, only: %i[show update destroy]

      def index
        authorize @order, :show?

        order_items = policy_scope(OrderItem)
          .where(order_id: @order.id)

        render json: order_items
      end

      def show
        authorize @order_item

        render json: @order_item
      end

      def create
        order_item = @order.order_items.new(order_item_params)

        authorize order_item

        if order_item.save
          render json: order_item, status: :created
        else
          render json: {
            errors: order_item.errors.full_messages
          }, status: :unprocessable_entity
        end
      end

      def update
        authorize @order_item

        if @order_item.update(order_item_params)
          render json: @order_item
        else
          render json: {
            errors: @order_item.errors.full_messages
          }, status: :unprocessable_entity
        end
      end

      def destroy
        authorize @order_item

        @order_item.destroy

        head :no_content
      end

      private

      def set_order
        @order = Order.find(params[:order_id])
      end

      def set_order_item
        @order_item = @order.order_items.find(params[:id])
      end

      def order_item_params
        params.require(:order_item).permit(
          :product_id,
          :external_id,
          :title,
          :sku,
          :quantity,
          :unit_price,
          :discount,
          :tax,
          :total,
          :currency
        )
      end
    end
  end
end
