/// Query to get all orders
const String getAllOrdersQuery = r'''
query getOrders($sortKey : OrderSortKeys, $accessToken : String!, $reverse: Boolean, $langCode: LanguageCode, $countryCode: CountryCode) @inContext(language: $langCode, country: $countryCode) {
customer(customerAccessToken: $accessToken) {
    orders(first: 250, sortKey: $sortKey, reverse: $reverse) {
      edges {
        node {
          id
          email
          currencyCode
          cancelReason
          canceledAt
          customerUrl
          financialStatus
          fulfillmentStatus
          lineItems(first: 250) {
            edges {
              node {
                currentQuantity
                discountAllocations {
                  allocatedAmount {
                    amount
                    currencyCode
                  }
                }
                discountedTotalPrice {
                  amount
                  currencyCode
                }
                originalTotalPrice {
                  amount
                  currencyCode
                }
                quantity
                title
                variant {
                  priceV2 {
                    amount
                    currencyCode
                  }
                  product {
                    id
                    title
                  }
                  title
                  image {
                    altText
                    id
                    originalSrc
                  }
                  compareAtPriceV2 {
                    amount
                    currencyCode
                  }
                  selectedOptions {
                    name
                    value
                  }
                  weight
                  weightUnit
                  availableForSale
                  sku
                  requiresShipping
                  id
                }
              }
            }
          }
          successfulFulfillments(first: 50) {
            trackingCompany
            trackingInfo {
              number
              url
            }
          }
          name
          orderNumber
          phone
          processedAt
          shippingAddress {
            address1
            address2
            city
            company
            country
            countryCodeV2
            firstName
            id
            lastName
            latitude
            longitude
            name
            phone
            province
            provinceCode
            zip
          }
          billingAddress {
            address1
            address2
            city
            company
            country
            countryCodeV2
            firstName
            id
            lastName
            latitude
            longitude
            name
            phone
            province
            provinceCode
            zip
          }
          statusUrl
          subtotalPriceV2 {
            amount
            currencyCode
          }
          totalPriceV2 {
            amount
            currencyCode
          }
          totalRefundedV2 {
            amount
            currencyCode
          }
          totalShippingPriceV2 {
            amount
            currencyCode
          }
          totalTaxV2 {
            amount
            currencyCode
          }
        }
        cursor
      }
    }
    id
  }
}
''';
