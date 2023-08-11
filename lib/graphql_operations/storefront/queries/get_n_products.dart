/// Query to get n products
const String getNProductsQuery = r'''
query($n : Int, $sortKey : ProductSortKeys, $reverse: Boolean, $langCode: LanguageCode, $countryCode: CountryCode) @inContext(language: $langCode, country: $countryCode){
  products(first: $n, sortKey: $sortKey, reverse: $reverse) {
    pageInfo {
      hasNextPage
    }
    edges {
      cursor
      node {
      metafields(identifiers: [ 
      {namespace: "reviews", key: "rating"}, 
      {namespace: "reviews", key: "rating_count"}, 
      ]) 
               {
                  id
                  namespace
                  key
                  value
                  type
                  description
              }      
      options(first: 50) {
            id
            name
            values
            } 
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
          pageInfo {
            hasNextPage
          }
        }
        availableForSale
        collections(first: 250) {
          edges {
            node {
              description
              descriptionHtml
              id
              handle
              updatedAt
              title
            }
          }
        }
        createdAt
        description
        descriptionHtml
        handle
        id
        onlineStoreUrl
        productType
        publishedAt
        tags
        title
        updatedAt
        vendor
        images(first: 250) {
          edges {
            node {
              altText
              id
              originalSrc
            }
          }
        }
      }
    }
  }
}

''';
