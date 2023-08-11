const String stagedUploadsCreate = r'''
mutation stagedUploadsCreate($input: [StagedUploadInput!]!) {
  stagedUploadsCreate(input: $input) {
    stagedTargets {
      url
      resourceUrl
      parameters {
        name  
        value
      }
    }
    userErrors {
      field
      message
    }
  }
}
''';
