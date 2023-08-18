///  mutation for deleting the access token
const String orderUpdate = r'''
mutation orderUpdate($input: OrderInput!) {
  orderUpdate(input: $input) {
    userErrors {
      field
      message
    }
  }
}
''';
