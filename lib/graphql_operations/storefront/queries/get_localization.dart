/// Query to get collections by ids
const String getLocalization = r'''
query Localization  {
  localization {
    availableLanguages {
      isoCode
      endonymName
    }
    availableCountries {
      isoCode
      name
      currency {
        isoCode
        name
        symbol
      }
      availableLanguages {
        isoCode
        endonymName
      }
    }
  }
}
''';
