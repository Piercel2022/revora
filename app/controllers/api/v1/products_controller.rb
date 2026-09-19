module Api
  module V1
    class ProductsController < ApplicationController
      before_action :authenticate_user!
      before_action :set_product, only: %i[show update destroy]

      def index
        products = policy_scope(Product)

        render json: products
      end

      def show
        authorize @product

        render json: @product
      end

      def create
        store = Store.find(product_params[:store_id])
        product = store.products.new(product_params.except(:store_id))

        authorize product

        if product.save
          render json: product, status: :created
        else
          render_validation_errors(product)
        end
      end

      def update
        authorize @product

        if @product.update(product_params.except(:store_id))
          render json: @product
        else
          render_validation_errors(@product)
        end
      end

      def destroy
        authorize @product

        @product.destroy

        head :no_content
      end

      private

      def set_product
        @product = Product.find(params[:id])
      end

      def product_params
        params.require(:product).permit(
          :store_id,
          :external_id,
          :title,
          :description,
          :sku,
          :product_type,
          :status,
          :price,
          :currency
        )
      end
    end
  end
end
