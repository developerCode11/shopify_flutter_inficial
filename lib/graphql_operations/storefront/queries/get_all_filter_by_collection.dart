/// Query to get all collections
const String getAllFilterByCollection = r'''
query($langCode: LanguageCode, $countryCode: CountryCode) @inContext(language: $langCode, country: $countryCode) {
  collection(handle: "woman") {
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
