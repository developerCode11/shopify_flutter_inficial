import 'dart:convert';

import 'package:graphql_flutter/graphql_flutter.dart';
import 'package:http/http.dart' as http;
import 'package:shopify_flutter/graphql_operations/storefront/mutations/customer_address_create.dart';
import 'package:shopify_flutter/graphql_operations/storefront/mutations/customer_address_delete.dart';
import 'package:shopify_flutter/graphql_operations/storefront/mutations/customer_address_update.dart';
import 'package:shopify_flutter/graphql_operations/storefront/mutations/customer_update.dart';
import 'package:shopify_flutter/graphql_operations/storefront/mutations/customer_update_default_address.dart';
import 'package:shopify_flutter/mixins/src/shopfiy_error.dart';
import 'package:shopify_flutter/models/src/product/metafield/metafield.dart';
import 'package:shopify_flutter/models/src/shopify_user/address/address.dart';

import '../../shopify_config.dart';

/// ShopifyCustomer class provides various methods for working with a user/customer.
class ShopifyCustomer with ShopifyError {
  ShopifyCustomer._();

  static final ShopifyCustomer instance = ShopifyCustomer._();

  GraphQLClient? get _graphQLClient => ShopifyConfig.graphQLClient;

  /// Updated the Address of a Customer, please input only the fields that you wish to update.
  Future<void> customerAddressUpdate({
    String? address1,
    String? address2,
    String? company,
    String? city,
    String? country,
    String? firstName,
    String? lastName,
    String? phone,
    String? province,
    String? zip,
    required String customerAccessToken,
    required String id,
  }) async {
    final MutationOptions _options = MutationOptions(
        document: gql(customerAddressUpdateMutation),
        variables: {
          'address1': address1,
          'address2': address2,
          'company': company,
          'city': city,
          'country': country,
          'firstName': firstName,
          'lastName': lastName,
          'phone': phone,
          'province': province,
          'zip': zip,
          'customerAccessToken': customerAccessToken,
          'id': id
        });
    final QueryResult result = await _graphQLClient!.mutate(_options);
    checkForError(
      result,
      key: 'customerAddressUpdate',
      errorKey: 'customerUserErrors',
    );
  }

  /// Updates the customer to which [customerAccessToken] belongs to.
  Future<void> customerUpdate({
    String? email,
    String? firstName,
    String? lastName,
    String? password,
    String? phoneNumber,
    String? customerAccessToken,
    bool? acceptsMarketing,
  }) async {
    Map<String, dynamic> variableMap = {};

    Map<String, dynamic> dataMap = {};
    dataMap['email'] = email;
    dataMap['firstName'] = firstName;
    dataMap['lastName'] = lastName;
    dataMap['acceptsMarketing'] = acceptsMarketing;
    dataMap['customerAccessToken'] = customerAccessToken;
    if (phoneNumber != null && phoneNumber.isNotEmpty) {
      dataMap['phone'] = phoneNumber;
    }
    if (password != null && password.isNotEmpty) {
      dataMap['password'] = password;
    }

    dataMap.forEach((k, v) => v != {} ? variableMap[k] = v : {});

    final MutationOptions _options = MutationOptions(
        document: gql(createValidMutationString(variableMap)),
        variables: variableMap);
    QueryResult result = await _graphQLClient!.mutate(_options);
    checkForError(
      result,
      key: 'customerUpdate',
      errorKey: 'customerUserErrors',
    );
  }

  /// Creates a address for the customer to which [customerAccessToken] belongs to.
  Future<Address> customerAddressCreate({
    String? address1,
    String? address2,
    String? company,
    String? city,
    String? country,
    String? firstName,
    String? lastName,
    String? phone,
    String? province,
    String? zip,
    String? customerAccessToken,
  }) async {
    final MutationOptions _options = MutationOptions(
        document: gql(customerAddressCreateMutation),
        variables: {
          'address1': address1,
          'address2': address2,
          'company': company,
          'city': city,
          'country': country,
          'firstName': firstName,
          'lastName': lastName,
          'phone': phone,
          'province': province,
          'zip': zip,
          'customerAccessToken': customerAccessToken,
        });
    final QueryResult result = await _graphQLClient!.mutate(_options);
    checkForError(
      result,
      key: 'customerAddressCreate',
      errorKey: 'customerUserErrors',
    );
    return Address.fromJson(
        (result.data!['customerAddressCreate']['customerAddress'] ?? {}));
  }

  /// Deletes the address associated with the [addressId] from the customer to which [customerAccessToken] belongs to.
  ///
  /// A Customer may have more than 1 address, so the addresses have Id's.
  Future<void> customerAddressDelete({
    String? customerAccessToken,
    String? addressId,
  }) async {
    final MutationOptions _options = MutationOptions(
        document: gql(customerAddressDeleteMutation),
        variables: {
          'customerAccessToken': customerAccessToken,
          'id': addressId
        });
    final QueryResult result = await _graphQLClient!.mutate(_options);
    checkForError(
      result,
      key: 'customerAddressDelete',
      errorKey: 'customerUserErrors',
    );
  }

  /// Make the address default associated with the [addressId] to the customer to which [customerId] belongs to.
  /// A Customer may have more than 1 address, so the addresses have Id's.
  Future<void> customerMakeAddressDefault({
    required String customerAccessToken,
    required String addressId,
  }) async {
    final MutationOptions _options = MutationOptions(
        document: gql(customerDefaultAddressUpdate),
        variables: {
          'customerAccessToken': customerAccessToken,
          'addressId': addressId
        });
    final QueryResult result = await _graphQLClient!.mutate(_options);
    checkForError(
      result,
      key: 'customerDefaultAddressUpdate',
      errorKey: 'customerUserErrors',
    );
  }

  Future<Metafield?> createMetaFieldForCustomer(
      {required String customerId,
      required String namespace,
      required String key,
      String? value,
      required String type}) async {
    try {
      http.Response response = await http.post(
        Uri.parse(
            "${ShopifyConfig.storeUrl}/admin/api/${ShopifyConfig.apiVersion}/customers/$customerId/metafields.json"),
        body: jsonEncode({
          "metafield": {
            "namespace": namespace,
            "key": key,
            "value": value,
            "type": type
          }
        }),
        headers: {
          'X-Shopify-Access-Token': ShopifyConfig.adminAccessToken,
          'Content-Type': 'application/json',
        },
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return Metafield.fromGraphJson(data['metafield']);
      }
    } catch (e) {
      return null;
    }
    return null;
  }

  Future<Metafield?> updateMetaFieldsFromMetaFieldForCustomer(
    String customerId,
    String metaFieldId,
    String namespace,
    String key,
    String value,
    String type,
  ) async {
    try {
      http.Response response = await http.put(
        Uri.parse(
            "${ShopifyConfig.storeUrl}/admin/api/${ShopifyConfig.apiVersion}/customers/$customerId/metafields/$metaFieldId.json"),
        body: {
          "metafield": {
            "namespace": namespace,
            "key": key,
            "value": value,
            "type": type
          }
        },
        headers: {
          'X-Shopify-Access-Token': ShopifyConfig.adminAccessToken,
        },
      );
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return Metafield.fromGraphJson(data['metafield']);
      }
    } catch (e) {
      return null;
    }
    return null;
  }

  Future<List<Metafield>> getMetaFieldsFromCustomer(String customerID) async {
    List<Metafield> metafields = [];
    try {
      http.Response response = await http.get(
        Uri.parse(
            "${ShopifyConfig.storeUrl}/admin/api/${ShopifyConfig.apiVersion}/customers/$customerID/metafields.json"),
        headers: {
          'X-Shopify-Access-Token': ShopifyConfig.adminAccessToken,
        },
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        metafields = (data['metafields'] as List)
            .map((e) => Metafield.fromGraphJson(e))
            .toList();
        return metafields;
      }
    } catch (e) {
      return [];
    }
    return metafields;
  }
}
