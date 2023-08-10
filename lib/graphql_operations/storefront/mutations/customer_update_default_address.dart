/// Mutation to update customer's default address
const String customerUpdateDefaultAddress = r'''
mutation customerUpdateDefaultAddress($addressId: ID!, $customerId: ID!) {
  customerUpdateDefaultAddress(addressId: $addressId, customerId: $customerId) {
    customerUserErrors {
      field
      message
    }
  }
}
''';
