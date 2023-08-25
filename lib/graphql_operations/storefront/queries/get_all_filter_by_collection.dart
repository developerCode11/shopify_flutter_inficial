/// Query to get all collections
const String getAllFilterByCollection = r'''
query($collectionHandle: String, $langCode: LanguageCode, $countryCode: CountryCode) @inContext(language: $langCode, country: $countryCode) {
  collection(handle: $collectionHandle) {
    handle
    products(first: 250) {
      filters {
        id
        label
        type
        values {
          id
          label
          count
          input
        }
      }
    }
  }
}
''';
