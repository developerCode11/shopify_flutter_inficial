/// Mutation to update customer's default address
const String customerUpdateDefaultAddress = r'''
mutation MyMutation($addressId: ID!, $customerId: ID!) {
  customerUpdateDefaultAddress(addressId: $addressId, customerId: $customerId) {
    customerUserErrors {
      field
      message
    }
  }
}
''';
