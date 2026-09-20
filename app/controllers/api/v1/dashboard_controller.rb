module Api
  module V1
    class DashboardController < ApplicationController
      before_action :authenticate_user!

      def show
        stores = current_organization.stores
        store_ids = stores.select(:id)

        orders = Order.where(store_id: store_ids)
        customers = Customer.where(store_id: store_ids)
        products = Product.where(store_id: store_ids)
        opportunities = current_organization.opportunities
        integrations = current_organization.integrations

        render json: {
          kpis: {
            revenue: orders.sum(:total).to_f,
            orders: orders.count,
            customers: customers.count,
            products: products.count,
            stores: stores.count,
            open_opportunities: opportunities.where(status: "open").count,
            pipeline_value: opportunities.where(status: "open").sum(:value).to_f
          },
          stores: {
            total: stores.count,
            active: stores.where(status: "active").count,
            paused: stores.where(status: "paused").count,
            disconnected: stores.where(status: "disconnected").count
          },
          orders: {
            total: orders.count,
            pending: orders.where(status: "pending").count,
            paid: orders.where(status: "paid").count,
            fulfilled: orders.where(status: "fulfilled").count,
            cancelled: orders.where(status: "cancelled").count,
            refunded: orders.where(status: "refunded").count
          },
          opportunities: {
            total: opportunities.count,
            open: opportunities.where(status: "open").count,
            won: opportunities.where(status: "won").count,
            lost: opportunities.where(status: "lost").count,
            pipeline_value: opportunities.where(status: "open").sum(:value).to_f,
            won_value: opportunities.where(status: "won").sum(:value).to_f
          },
          integrations: {
            total: integrations.count,
            active: integrations.where(status: "active").count,
            inactive: integrations.where(status: "inactive").count,
            error: integrations.where(status: "error").count
          }
        }
      end
    end
  end
end
