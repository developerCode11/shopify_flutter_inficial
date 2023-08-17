/// Mutation to create a checkout
String cartCreate = r'''
mutation cartCreate($input: CartInput!,$langCode: LanguageCode, $countryCode: CountryCode) @inContext(language: $langCode, country: $countryCode){
  cartCreate(input: $input) {
    userErrors {
      code
      field
      message
    }
      cart {
      id
      createdAt
      updatedAt
      lines(first: 10) {
        edges {
          node {
            id
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
}
''';
