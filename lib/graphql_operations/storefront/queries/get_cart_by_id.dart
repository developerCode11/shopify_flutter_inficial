/// Mutation to create a checkout
String getCartById = r'''
query getCartById($cartId: ID!,$langCode: LanguageCode, $countryCode: CountryCode) @inContext(language: $langCode, country: $countryCode) {
  cart(id: $cartId) {
      id
      createdAt
      updatedAt
      lines(first: 10) {
        edges {
          node {
            id
            quantity
            merchandise {
              ... on ProductVariant {
                id
                title
                image {
                  altText
                  id
                  originalSrc
                }
                priceV2 {
                  amount
                  currencyCode
                }
                compareAtPriceV2 {
                  amount
                  currencyCode
                }
                quantityAvailable
                selectedOptions {
                  name
                  value
                }
              }
            }
          }
        }
      }
      buyerIdentity {
        countryCode
        email
        phone
        deliveryAddressPreferences {
           __typename
        }
      }
      attributes {
        key
        value
      }
      cost {
        totalAmount {
          amount
          currencyCode
        }
        subtotalAmount {
          amount
          currencyCode
        }
        totalTaxAmount {
          amount
          currencyCode
        }
        totalDutyAmount {
          amount
          currencyCode
        }
      }
  }
}
''';
