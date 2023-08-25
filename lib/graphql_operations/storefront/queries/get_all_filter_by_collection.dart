/// Query to get all collections
const String getAllFilterByCollection = r'''
query($id: ID!, $langCode: LanguageCode, $countryCode: CountryCode) @inContext(language: $langCode, country: $countryCode) {
  collection(id: $id) {
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
