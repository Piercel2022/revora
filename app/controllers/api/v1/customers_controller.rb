module Api
  module V1
    class CustomersController < ApplicationController
      before_action :authenticate_user!
      before_action :set_customer, only: %i[show update destroy]

      def index
        customers = policy_scope(Customer)

        render json: customers
      end

      def show
        authorize @customer

        render json: @customer
      end

      def create
        store = Store.find(customer_params[:store_id])
        customer = store.customers.new(
          customer_params.except(:store_id)
        )

        authorize customer

        if customer.save
          render json: customer, status: :created
        else
          render_validation_errors(customer)
        end
      end

      def update
        authorize @customer

        if @customer.update(
          customer_params.except(:store_id)
        )
          render json: @customer
        else
          render_validation_errors(@customer)
        end
      end

      def destroy
        authorize @customer

        @customer.destroy

        head :no_content
      end

      private

      def set_customer
        @customer = Customer.find(params[:id])
      end

      def customer_params
        params.require(:customer).permit(
          :store_id,
          :external_id,
          :first_name,
          :last_name,
          :email,
          :phone,
          :status
        )
      end
    end
  end
end
