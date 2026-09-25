# Demo data for the Revora development dashboard.
#
# The seed is intentionally scoped to the "revora-demo" organization.
# It is idempotent and can safely be executed multiple times.

organization = Organization.find_or_create_by!(slug: "revora-demo") do |org|
  org.name = "Revora Demo"
  org.status = "active"
end

user = organization.users.find_or_create_by!(
  email: "pierre@revora-demo.test"
) do |demo_user|
  demo_user.first_name = "Pierre"
  demo_user.last_name = "Celestin"
  demo_user.password = "password123"
  demo_user.password_confirmation = "password123"
  demo_user.role = "owner"
  demo_user.active = true
end

puts "Seeding Revora demo data for #{organization.name}..."

stores = {
  shopify: Store.find_or_create_by!(
    organization: organization,
    external_id: "demo-shopify-fr"
  ) do |store|
    store.name = "Revora Shopify FR"
    store.platform = "shopify"
    store.domain = "revora-demo.myshopify.com"
    store.currency = "EUR"
    store.timezone = "Europe/Paris"
    store.status = "active"
    store.last_synced_at = Time.current
  end,
  woocommerce: Store.find_or_create_by!(
    organization: organization,
    external_id: "demo-woocommerce-eu"
  ) do |store|
    store.name = "Revora WooCommerce EU"
    store.platform = "woocommerce"
    store.domain = "shop.revora-demo.eu"
    store.currency = "EUR"
    store.timezone = "Europe/Paris"
    store.status = "paused"
    store.last_synced_at = 2.hours.ago
  end
}

customers = {
  shopify: [
    {
      external_id: "demo-customer-001",
      first_name: "Marie",
      last_name: "Martin",
      email: "marie.martin@demo.revora.test",
      phone: "+33 6 10 20 30 40",
      company_name: "Maison Martin",
      status: "active"
    },
    {
      external_id: "demo-customer-002",
      first_name: "Thomas",
      last_name: "Bernard",
      email: "thomas.bernard@demo.revora.test",
      phone: "+33 6 11 22 33 44",
      company_name: "Bernard Studio",
      status: "active"
    },
    {
      external_id: "demo-customer-003",
      first_name: "Claire",
      last_name: "Robert",
      email: "claire.robert@demo.revora.test",
      phone: "+33 6 12 23 34 45",
      company_name: nil,
      status: "inactive"
    }
  ],
  woocommerce: [
    {
      external_id: "demo-customer-004",
      first_name: "Lucas",
      last_name: "Petit",
      email: "lucas.petit@demo.revora.test",
      phone: "+33 6 13 24 35 46",
      company_name: "Petit Commerce",
      status: "active"
    },
    {
      external_id: "demo-customer-005",
      first_name: "Sophie",
      last_name: "Durand",
      email: "sophie.durand@demo.revora.test",
      phone: "+33 6 14 25 36 47",
      company_name: "Atelier Durand",
      status: "active"
    },
    {
      external_id: "demo-customer-006",
      first_name: "Antoine",
      last_name: "Morel",
      email: "antoine.morel@demo.revora.test",
      phone: "+33 6 15 26 37 48",
      company_name: nil,
      status: "active"
    }
  ]
}

customer_records = {}

customers.each do |store_key, customer_attributes|
  store = stores.fetch(store_key)

  customer_records[store_key] = customer_attributes.map do |attributes|
    Customer.find_or_create_by!(
      store: store,
      external_id: attributes.fetch(:external_id)
    ) do |customer|
      customer.first_name = attributes[:first_name]
      customer.last_name = attributes[:last_name]
      customer.email = attributes[:email]
      customer.phone = attributes[:phone]
      customer.company_name = attributes[:company_name]
      customer.status = attributes[:status]
    end
  end
end
segments = [
  {
    name: "Clients VIP",
    description: "Clients à forte valeur commerciale nécessitant un suivi prioritaire.",
    status: "active"
  },
  {
    name: "Clients actifs",
    description: "Clients actuellement actifs sur les différentes boutiques Revora.",
    status: "active"
  },
  {
    name: "Opportunités commerciales",
    description: "Clients associés à des opportunités commerciales ouvertes ou en développement.",
    status: "active"
  },
  {
    name: "Segments historiques",
    description: "Segments conservés pour référence historique.",
    status: "archived"
  }
]

segments.each do |attributes|
  Segment.find_or_create_by!(
    organization: organization,
    name: attributes.fetch(:name)
  ) do |segment|
    segment.description = attributes[:description]
    segment.status = attributes.fetch(:status)
  end
end

products = {
  shopify: [
    {
      external_id: "demo-product-001",
      title: "Premium Starter Kit",
      description: "Starter kit for new ecommerce customers.",
      sku: "REV-STARTER",
      product_type: "Kit",
      status: "active",
      price: 89.90
    },
    {
      external_id: "demo-product-002",
      title: "Growth Bundle",
      description: "Bundle designed for growing stores.",
      sku: "REV-GROWTH",
      product_type: "Bundle",
      status: "active",
      price: 149.00
    },
    {
      external_id: "demo-product-003",
      title: "Enterprise Pack",
      description: "Advanced package for larger ecommerce operations.",
      sku: "REV-ENTERPRISE",
      product_type: "Pack",
      status: "active",
      price: 399.00
    },
    {
      external_id: "demo-product-004",
      title: "Legacy Starter",
      description: "Legacy product retained for historical orders.",
      sku: "REV-LEGACY",
      product_type: "Legacy",
      status: "archived",
      price: 59.00
    }
  ],
  woocommerce: [
    {
      external_id: "demo-product-005",
      title: "Commerce Essentials",
      description: "Essential ecommerce package.",
      sku: "WC-ESSENTIALS",
      product_type: "Package",
      status: "active",
      price: 119.00
    },
    {
      external_id: "demo-product-006",
      title: "Professional Suite",
      description: "Professional ecommerce suite.",
      sku: "WC-PRO",
      product_type: "Suite",
      status: "active",
      price: 249.00
    },
    {
      external_id: "demo-product-007",
      title: "Analytics Add-on",
      description: "Analytics extension for ecommerce teams.",
      sku: "WC-ANALYTICS",
      product_type: "Add-on",
      status: "draft",
      price: 79.00
    },
    {
      external_id: "demo-product-008",
      title: "EU Expansion Pack",
      description: "Tools for European ecommerce expansion.",
      sku: "WC-EU",
      product_type: "Pack",
      status: "active",
      price: 299.00
    }
  ]
}

products.each do |store_key, product_attributes|
  store = stores.fetch(store_key)

  product_attributes.each do |attributes|
    Product.find_or_create_by!(
      store: store,
      external_id: attributes.fetch(:external_id)
    ) do |product|
      product.title = attributes.fetch(:title)
      product.description = attributes[:description]
      product.sku = attributes[:sku]
      product.product_type = attributes[:product_type]
      product.status = attributes.fetch(:status)
      product.price = attributes[:price]
      product.currency = store.currency
    end
  end
end

order_definitions = [
  {
    store: :shopify,
    customer_index: 0,
    external_id: "demo-order-001",
    order_number: "REV-1001",
    status: "pending",
    subtotal: 170.00,
    tax: 15.90,
    shipping: 4.00,
    discount: 0.00,
    total: 189.90,
    ordered_at: 1.day.ago
  },
  {
    store: :shopify,
    customer_index: 1,
    external_id: "demo-order-002",
    order_number: "REV-1002",
    status: "paid",
    subtotal: 310.00,
    tax: 31.00,
    shipping: 8.00,
    discount: 0.00,
    total: 349.00,
    ordered_at: 2.days.ago
  },
  {
    store: :shopify,
    customer_index: 2,
    external_id: "demo-order-003",
    order_number: "REV-1003",
    status: "fulfilled",
    subtotal: 115.00,
    tax: 10.50,
    shipping: 4.00,
    discount: 0.00,
    total: 129.50,
    ordered_at: 3.days.ago
  },
  {
    store: :shopify,
    customer_index: 0,
    external_id: "demo-order-004",
    order_number: "REV-1004",
    status: "cancelled",
    subtotal: 450.00,
    tax: 45.00,
    shipping: 4.00,
    discount: 0.00,
    total: 499.00,
    ordered_at: 4.days.ago
  },
  {
    store: :shopify,
    customer_index: 1,
    external_id: "demo-order-005",
    order_number: "REV-1005",
    status: "refunded",
    subtotal: 80.00,
    tax: 7.00,
    shipping: 2.00,
    discount: 0.00,
    total: 89.00,
    ordered_at: 5.days.ago
  },
  {
    store: :woocommerce,
    customer_index: 0,
    external_id: "demo-order-006",
    order_number: "REV-2001",
    status: "pending",
    subtotal: 250.00,
    tax: 24.00,
    shipping: 5.00,
    discount: 0.00,
    total: 279.00,
    ordered_at: 6.days.ago
  },
  {
    store: :woocommerce,
    customer_index: 1,
    external_id: "demo-order-007",
    order_number: "REV-2002",
    status: "fulfilled",
    subtotal: 590.00,
    tax: 54.00,
    shipping: 5.00,
    discount: 0.00,
    total: 649.00,
    ordered_at: 7.days.ago
  },
  {
    store: :woocommerce,
    customer_index: 2,
    external_id: "demo-order-008",
    order_number: "REV-2003",
    status: "paid",
    subtotal: 140.00,
    tax: 15.00,
    shipping: 4.00,
    discount: 0.00,
    total: 159.00,
    ordered_at: 8.days.ago
  },
  {
    store: :woocommerce,
    customer_index: 0,
    external_id: "demo-order-009",
    order_number: "REV-2004",
    status: "fulfilled",
    subtotal: 360.00,
    tax: 34.00,
    shipping: 5.00,
    discount: 0.00,
    total: 399.00,
    ordered_at: 9.days.ago
  },
  {
    store: :woocommerce,
    customer_index: 1,
    external_id: "demo-order-010",
    order_number: "REV-2005",
    status: "refunded",
    subtotal: 195.00,
    tax: 20.00,
    shipping: 4.00,
    discount: 0.00,
    total: 219.00,
    ordered_at: 10.days.ago
  }
]

order_definitions.each do |definition|
  store = stores.fetch(definition.fetch(:store))
  customer = customer_records.fetch(definition.fetch(:store)).fetch(
    definition.fetch(:customer_index)
  )

  Order.find_or_create_by!(
    store: store,
    external_id: definition.fetch(:external_id)
  ) do |order|
    order.customer = customer
    order.order_number = definition.fetch(:order_number)
    order.status = definition.fetch(:status)
    order.currency = store.currency
    order.subtotal = definition.fetch(:subtotal)
    order.tax = definition.fetch(:tax)
    order.shipping = definition.fetch(:shipping)
    order.discount = definition.fetch(:discount)
    order.total = definition.fetch(:total)
    order.ordered_at = definition.fetch(:ordered_at)
  end
end

opportunities = [
  {
    name: "Enterprise migration",
    status: "open",
    value: 18_000,
    store: :shopify,
    customer_index: 0,
    expected_close_at: 15.days.from_now
  },
  {
    name: "WooCommerce expansion",
    status: "open",
    value: 7_500,
    store: :woocommerce,
    customer_index: 1,
    expected_close_at: 30.days.from_now
  },
  {
    name: "Professional upgrade",
    status: "open",
    value: 3_000,
    store: :shopify,
    customer_index: 1,
    expected_close_at: 7.days.from_now
  },
  {
    name: "Annual contract renewal",
    status: "won",
    value: 12_000,
    store: :shopify,
    customer_index: 2,
    expected_close_at: 10.days.ago
  },
  {
    name: "International expansion",
    status: "lost",
    value: 6_500,
    store: :woocommerce,
    customer_index: 2,
    expected_close_at: 20.days.ago
  }
]

opportunities.each do |attributes|
  store = stores.fetch(attributes.fetch(:store))
  customer = customer_records.fetch(attributes.fetch(:store)).fetch(
    attributes.fetch(:customer_index)
  )

  Opportunity.find_or_create_by!(
    organization: organization,
    name: attributes.fetch(:name)
  ) do |opportunity|
    opportunity.store = store
    opportunity.customer = customer
    opportunity.status = attributes.fetch(:status)
    opportunity.value = attributes.fetch(:value)
    opportunity.expected_close_at = attributes.fetch(:expected_close_at)
  end
end

integrations = [
  {
    name: "Shopify Store Sync",
    provider: "shopify",
    kind: "store",
    status: "active",
    store: :shopify,
    external_id: "demo-integration-shopify"
  },
  {
    name: "Stripe Payments",
    provider: "shopify",
    kind: "payment",
    status: "active",
    store: :shopify,
    external_id: "demo-integration-stripe"
  },
  {
    name: "WooCommerce Store Sync",
    provider: "woocommerce",
    kind: "store",
    status: "inactive",
    store: :woocommerce,
    external_id: "demo-integration-woocommerce"
  },
  {
    name: "Analytics Connector",
    provider: "woocommerce",
    kind: "analytics",
    status: "error",
    store: :woocommerce,
    external_id: "demo-integration-analytics"
  }
]

integrations.each do |attributes|
  store = stores.fetch(attributes.fetch(:store))

  Integration.find_or_create_by!(
    organization: organization,
    name: attributes.fetch(:name)
  ) do |integration|
    integration.store = store
    integration.provider = attributes.fetch(:provider)
    integration.kind = attributes.fetch(:kind)
    integration.status = attributes.fetch(:status)
    integration.external_id = attributes.fetch(:external_id)
    integration.credentials = {}
  end
end

puts
puts "Revora demo seed completed."

puts "Organization: #{organization.name}"

puts "Stores: #{organization.stores.count}"

puts "Customers: #{Customer.joins(:store).where(stores: { organization_id: organization.id }).count}"

puts "Products: #{Product.joins(:store).where(stores: { organization_id: organization.id }).count}"

puts "Orders: #{Order.joins(:store).where(stores: { organization_id: organization.id }).count}"

puts "Revenue: #{Order.joins(:store).where(stores: { organization_id: organization.id }).sum(:total)} EUR"

puts "Segments: #{organization.segments.count}"

puts "Opportunities: #{organization.opportunities.count}"

puts "Open pipeline: #{organization.opportunities.where(status: "open").sum(:value)} EUR"

puts "Integrations: #{organization.integrations.count}"