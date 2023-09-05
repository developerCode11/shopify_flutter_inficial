/// Query to get x products after cursor
const String getXProductsAfterCursorQuery = r'''
query($cursor : String, $x : Int, $reverse: Boolean, $sortKey: ProductSortKeys, $langCode: LanguageCode, $countryCode: CountryCode) @inContext(language: $langCode, country: $countryCode){
  products(first: $x, after: $cursor, sortKey: $sortKey, reverse: $reverse) {
    pageInfo {
      hasNextPage
    }
    edges {
      cursor
      node {
      metafields(identifiers: [ 
      {namespace: "reviews", key: "rating"}, 
      {namespace: "reviews", key: "rating_count"},
      {namespace: "custom", key: "product_reel"},
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
}''';
