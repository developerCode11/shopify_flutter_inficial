/// Query to get all collections
const String getAllCollectionsOptimizedQuery = r'''
query($cursor: String, $sortKey: CollectionSortKeys, $reverse: Boolean, $langCode: LanguageCode, $countryCode: CountryCode) @inContext(language: $langCode, country: $countryCode) {
  collections(first: 250, after: $cursor, sortKey: $sortKey, reverse: $reverse) {
  pageInfo{
    hasNextPage
  }
    edges {
      cursor
      node {
        title
        description
        descriptionHtml
        handle
        id
        updatedAt
        image {
          altText
          id
          originalSrc
        }
      }
    }
  }
}
''';
