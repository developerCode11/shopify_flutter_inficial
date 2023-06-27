/// Query to get product recommendations
const String getProductRecommendationsQuery = r'''
query getProductRecommentationsQuery($id: ID!, $langCode: LanguageCode, $countryCode: CountryCode) @inContext(language: $langCode, country: $countryCode) {
  productRecommendations(productId: $id) {
    availableForSale
    createdAt
    description
    descriptionHtml
    handle
    id
    images(first: 250) {
      edges {
        node {
          altText
          id
          originalSrc
        }
      }
    }
    onlineStoreUrl
    options(first: 50) {
      id
      name
      values
    }
    productType
    publishedAt
    tags
    title
    updatedAt
    vendor
    variants(first: 250) {
      edges {
        node {
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
          weight
          weightUnit
          availableForSale
          sku
          requiresShipping
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
''';
