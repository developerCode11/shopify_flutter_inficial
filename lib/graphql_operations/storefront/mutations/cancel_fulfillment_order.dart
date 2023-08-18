///  mutation for deleting the access token
const String fulfillmentOrderCancel = r'''
mutation fulfillmentOrderCancel($id: ID!) {
  fulfillmentOrderCancel(id: $id) {
    userErrors {
      field
      message
    }
  }
}

''';
