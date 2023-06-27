/// Query to get collections by ids
const String getCollectionsByIdsQuery = r'''
query getCollectionsByIds($ids: [ID!]!, $langCode: LanguageCode, $countryCode: CountryCode) @inContext(language: $langCode, country: $countryCode){
  nodes(ids: $ids) {
    ... on Collection {
      id
      handle
      descriptionHtml
      image {
        src
        originalSrc
        id
        altText
      }
      title
      updatedAt
    }
  }
}''';
