const String getMenuByHandleQuery = r'''
query getMenuByHandle($handle: String!, $langCode: LanguageCode, $countryCode: CountryCode) @inContext(language: $langCode, country: $countryCode) {
 	menu(handle : $handle) {
 	     items{
      id
      tags
      title
      url
      resourceId
      items{
        title
        url
        resourceId
        tags
        id
        items{
        title
        url
        resourceId
        tags
        id
      }
      }
    }
  }
}
''';
