import 'package:graphql_flutter/graphql_flutter.dart';
import 'package:shopify_flutter/enums/src/payment_token_type.dart';
import 'package:shopify_flutter/enums/src/sort_key_order.dart';
import 'package:shopify_flutter/graphql_operations/storefront/mutations/cancel_fulfillment_order.dart';
import 'package:shopify_flutter/graphql_operations/storefront/mutations/checkout_complete_free.dart';
import 'package:shopify_flutter/graphql_operations/storefront/mutations/checkout_complete_with_credit_card_V2.dart';
import 'package:shopify_flutter/graphql_operations/storefront/mutations/checkout_line_item_add.dart';
import 'package:shopify_flutter/graphql_operations/storefront/mutations/checkout_line_item_remove.dart';
import 'package:shopify_flutter/graphql_operations/storefront/mutations/checkout_line_item_update.dart';
import 'package:shopify_flutter/graphql_operations/storefront/mutations/checkout_line_items_replace.dart';
import 'package:shopify_flutter/graphql_operations/storefront/mutations/checkout_shipping_address_update.dart';
import 'package:shopify_flutter/graphql_operations/storefront/mutations/checkout_shipping_line_update.dart';
import 'package:shopify_flutter/graphql_operations/storefront/mutations/complete_checkout_token_v3.dart';
import 'package:shopify_flutter/graphql_operations/storefront/mutations/create_checkout.dart';
import 'package:shopify_flutter/graphql_operations/storefront/mutations/update_order_shipping_address.dart';
import 'package:shopify_flutter/graphql_operations/storefront/queries/get_checkout_info_requires_shipping.dart';
import 'package:shopify_flutter/graphql_operations/storefront/queries/get_checkout_info_with_payment_id.dart';
import 'package:shopify_flutter/graphql_operations/storefront/queries/get_checkout_info_with_payment_id_without_shipping_rates.dart';
import 'package:shopify_flutter/graphql_operations/storefront/queries/get_checkout_without_shipping_rates.dart';
import 'package:shopify_flutter/mixins/src/shopfiy_error.dart';
import 'package:shopify_flutter/models/src/checkout/line_item/line_item.dart';
import 'package:shopify_flutter/models/src/order/order.dart';
import 'package:shopify_flutter/models/src/order/orders/orders.dart';
import 'package:shopify_flutter/models/src/order/shipping_address/shipping_address.dart';
import 'package:shopify_flutter/models/src/product/price_v_2/price_v_2.dart';
import 'package:shopify_flutter/models/src/shopify_user/address/address.dart';

import '../../graphql_operations/storefront/mutations/checkout_associate_customer.dart';
import '../../graphql_operations/storefront/mutations/checkout_attributes_update.dart';
import '../../graphql_operations/storefront/mutations/checkout_customer_disassociate.dart';
import '../../graphql_operations/storefront/mutations/checkout_discount_code_apply.dart';
import '../../graphql_operations/storefront/mutations/checkout_discount_code_remove.dart';
import '../../graphql_operations/storefront/mutations/checkout_giftcard_remove.dart';
import '../../graphql_operations/storefront/mutations/checkout_giftcards_append.dart';
import '../../graphql_operations/storefront/queries/get_all_orders.dart';
import '../../graphql_operations/storefront/queries/get_checkout_information.dart';
import '../../models/src/checkout/checkout.dart';
import '../../shopify_config.dart';

/// ShopifyCheckout provides various method in order to work with checkouts.
class ShopifyCheckout with ShopifyError {
  ShopifyCheckout._();
  static final ShopifyCheckout instance = ShopifyCheckout._();

  GraphQLClient? get _graphQLClient => ShopifyConfig.graphQLClient;
  GraphQLClient? get _graphQLAdmin => ShopifyConfig.graphQLClientAdmin;

  /// Returns a [Checkout] object.
  ///
  /// Returns the Checkout object of the checkout with the [checkoutId].
  Future<Checkout> getCheckoutInfoQuery(
    String checkoutId, {
    bool getShippingInfo = true,
    bool withPaymentId = false,
  }) async {
    final WatchQueryOptions _optionsRequireShipping = WatchQueryOptions(
        document: gql(getCheckoutInfoAboutShipping),
        variables: {
          'id': checkoutId,
        });
    QueryResult result = await _graphQLClient!.query(_optionsRequireShipping);

    final WatchQueryOptions _options = WatchQueryOptions(
        document: gql(_requiresShipping(result) == true && getShippingInfo
            ? withPaymentId
                ? getCheckoutInfoWithPaymentId
                : getCheckoutInfo
            : withPaymentId
                ? getCheckoutInfoWithPaymentIdWithoutShipping
                : getCheckoutInfoWithoutShipping),
        variables: {
          'id': checkoutId,
        });
    final QueryResult _queryResult = (await _graphQLClient!.query(_options));
    checkForError(_queryResult);

    return Checkout.fromJson(_queryResult.data!['node']);
  }

  bool? _requiresShipping(QueryResult result) {
    return ((result.data ?? const {})['node'] ?? const {})['requiresShipping'];
  }

  /// Updates the attributes of a [Checkout]
  Future<void> updateAttributes(
    String checkoutId, {
    bool? allowPartialAddresses,
    Map<String, String>? customAttributes,
    String? note,
  }) async {
    final MutationOptions _options = MutationOptions(
      document: gql(checkoutAttributesUpdateMutation),
      variables: {
        'checkoutId': checkoutId,
        'input': {
          if (allowPartialAddresses != null)
            'allowPartialAddresses': allowPartialAddresses,
          if (customAttributes != null)
            'customAttributes': [
              for (var entry in customAttributes.entries)
                {
                  'key': entry.key,
                  'value': entry.value,
                }
            ],
          if (note != null) 'note': note,
        },
      },
    );
    final QueryResult result = await _graphQLClient!.mutate(_options);
    checkForError(
      result,
      key: 'checkoutAttributesUpdateV2',
      errorKey: 'checkoutUserErrors',
    );
  }

  /// Returns all [Order] in a List of Orders.
  ///
  /// Returns a List of Orders from the Customer with the [customerAccessToken].
  Future<List<Order>?> getAllOrders(
    String customerAccessToken, {
    SortKeyOrder sortKey = SortKeyOrder.PROCESSED_AT,
    bool reverse = true,
    String? langCode,
    String? countryCode,
  }) async {
    // final QueryOptions _options =
    //     WatchQueryOptions(document: gql(getAllOrdersQuery2), variables: {
    //   'accessToken': customerAccessToken,
    //   'sortKey': sortKey.parseToString(),
    //   'reverse': reverse
    // });
    // final QueryResult result =
    //     await ShopifyConfig.graphQLClient!.query(_options);

    Map<String, dynamic> variables = <String, dynamic>{
      'accessToken': customerAccessToken,
      'sortKey': sortKey.parseToString(),
      'reverse': reverse
    };
    if (langCode != null) {
      variables['langCode'] = langCode;
    }
    if (countryCode != null) {
      variables['countryCode'] = countryCode;
    }
    final MutationOptions _options =
        MutationOptions(document: gql(getAllOrdersQuery), variables: variables);
    QueryResult result = await _graphQLClient!.mutate(_options);
    checkForError(result);
    final orderResult =
        (result.data!['customer']['orders'] ?? {}) as Map<String, dynamic>;
    Orders orders = Orders.fromGraphJson(orderResult);
    // Orders orders = Orders.fromJson(
    //     (((result.data ?? const {})['customer'] ?? const {})['orders'] ??
    //         const {}));
    return orders.orderList;
  }

  Future<void> cancelOrder(
    String orderId,
  ) async {
    final MutationOptions _options = MutationOptions(
      document: gql(fulfillmentOrderCancel),
      variables: {
        'id': orderId,
      },
    );
    final QueryResult result = await _graphQLAdmin!.mutate(_options);
    checkForError(
      result,
      key: 'fulfillmentOrderCancel',
      errorKey: 'userErrors',
    );
  }

  Future<void> updateOrderShippingAddress(
      {required String orderId,
      required ShippingAddress address,
      String? note}) async {
    final MutationOptions _options = MutationOptions(
      document: gql(orderUpdate),
      variables: {
        "input": {
          "id": orderId,
          if (note != null) "note": "",
          "shippingAddress": {
            "address1": address.address1,
            "address2": address.address2,
            "city": address.city,
            "company": address.company,
            "country": address.country,
            "countryCode": address.countryCodeV2,
            "firstName": address.firstName,
            "id": address.id,
            "lastName": address.lastName,
            "phone": address.phone,
            "province": address.province,
            "provinceCode": address.provinceCode,
            "zip": address.zip,
          },
        }
      },
    );
    final QueryResult result = await _graphQLAdmin!.mutate(_options);
    checkForError(
      result,
      key: 'fulfillmentOrderCancel',
      errorKey: 'userErrors',
    );
  }

  /// Replaces the [LineItems] in the [Checkout] associated to the [checkoutId].
  ///
  /// [checkoutLineItems] is a List of Variant Ids
  Future<void> checkoutLineItemsReplace(
    String checkoutId,
    List<String> variantIdList,
  ) async {
    var checkoutLineItems = transformVariantIdListIntoListOfMaps(variantIdList);
    final MutationOptions _options = MutationOptions(
      document: gql(replaceCheckoutItemsMutation),
      variables: {
        'checkoutId': checkoutId,
        'checkoutLineItems': checkoutLineItems,
      },
    );
    final QueryResult result = await _graphQLClient!.mutate(_options);
    checkForError(
      result,
      key: 'checkoutLineItemsReplace',
      errorKey: 'userErrors',
    );
  }

  /// Updates the shipping address on given [checkoutId]
  Future<Checkout> shippingAddressUpdate(
    String checkoutId,
    Address address,
  ) async {
    Map<String, dynamic> variables = address.toJson();
    variables['checkoutId'] = checkoutId;
    final MutationOptions _options = MutationOptions(
      document: gql(checkoutShippingAddressUpdateMutation),
      variables: variables,
    );
    final QueryResult result = await _graphQLClient!.mutate(_options);
    checkForError(
      result,
      key: 'checkoutShippingAddressUpdateV2',
      errorKey: 'checkoutUserErrors',
    );

    return Checkout.fromJson(
        ((result.data!['checkoutShippingAddressUpdateV2'] ??
                const {})['checkout'] ??
            const {}));
  }

  /// Updates the shipping address on given [checkoutId]
  Future<String?> completeCheckoutWithTokenizedPaymentV2({
    required String checkoutId,
    required PriceV2 price,
    required Address billingAddress,
    required String impotencyKey,
    required String tokenizedPayment,
    required String type,
    bool test = false,
  }) async {
    final MutationOptions _options = MutationOptions(
      document: gql(compCheckoutWithTokenizedPaymentV2),
      variables: {
        'checkoutId': checkoutId,
        "payment": {
          "paymentAmount": {
            "amount": price.amount,
            "currencyCode": price.currencyCode
          },
          "idempotencyKey": impotencyKey,
          "billingAddress": {
            "firstName": billingAddress.firstName,
            "lastName": billingAddress.lastName,
            "address1": billingAddress.address1,
            "province": billingAddress.province,
            "country": billingAddress.country,
            "city": billingAddress.city,
            "zip": billingAddress.zip
          },
          "paymentData": tokenizedPayment,
          "type": type
        }
      },
    );
    final QueryResult result = await _graphQLClient!.mutate(_options);
    checkForError(
      result,
      key: 'checkoutCompleteWithTokenizedPaymentV2',
      errorKey: 'checkoutUserErrors',
    );
    return (result.data!['checkoutCompleteWithTokenizedPaymentV2'] ??
        const {})['payment']['id'];
  }

  /// Helper method for transforming a list of variant ids into a List Of Map<String, dynamic> which looks like this:
  ///
  /// [{"quantity":AMOUNT,"variantId":"YOUR_VARIANT_ID"}]
  List<Map<String, dynamic>> transformVariantIdListIntoListOfMaps(
      List<String> variantIdList) {
    List<Map<String, dynamic>> lineItemList = [];
    for (var e in variantIdList) {
      if (lineItemList.indexWhere((test) => e == test['variantId']) == -1) {
        lineItemList.add({
          "quantity": variantIdList.where((id) => e == id).toList().length,
          "variantId": e
        });
      }
    }
    return lineItemList;
  }

  /// Associates the [Customer] that [customerAccessToken] belongs to, to the [Checkout] that [checkoutId] belongs to.
  Future<void> checkoutCustomerAssociate(
    String checkoutId,
    String customerAccessToken,
  ) async {
    final MutationOptions _options = MutationOptions(
        document: gql(associateCustomer),
        variables: {
          'checkoutId': checkoutId,
          'customerAccessToken': customerAccessToken
        });
    final QueryResult result = await _graphQLClient!.mutate(_options);
    checkForError(
      result,
      key: 'checkoutCustomerAssociateV2',
      errorKey: 'checkoutUserErrors',
    );
  }

  /// Disassociates the [Customer] from the [Checkout] that [checkoutId] belongs to.
  Future<void> checkoutCustomerDisassociate(
    String checkoutId,
  ) async {
    final MutationOptions _options = MutationOptions(
        document: gql(checkoutCustomerDisassociateMutation),
        variables: {'id': checkoutId});
    final QueryResult result = await _graphQLClient!.mutate(_options);
    checkForError(
      result,
      key: 'checkoutCustomerDisassociateV2',
      errorKey: 'checkoutUserErrors',
    );
  }

  /// Applies [discountCode] to the [Checkout] that [checkoutId] belongs to.
  Future<Checkout> checkoutDiscountCodeApply(
    String checkoutId,
    String discountCode,
  ) async {
    final MutationOptions _options = MutationOptions(
        document: gql(checkoutDiscountCodeApplyMutation),
        variables: {'checkoutId': checkoutId, 'discountCode': discountCode});
    final QueryResult result = await _graphQLClient!.mutate(_options);
    checkForError(
      result,
      key: 'checkoutDiscountCodeApplyV2',
      errorKey: 'checkoutUserErrors',
    );
    return Checkout.fromJson(((result.data!['checkoutDiscountCodeApplyV2'] ??
            const {})['checkout'] ??
        const {}));
  }

  /// Removes the applied discount from the [Checkout] that [checkoutId] belongs to.
  Future<Checkout> checkoutDiscountCodeRemove(
    String checkoutId,
  ) async {
    final MutationOptions _options = MutationOptions(
        document: gql(checkoutDiscountCodeRemoveMutation),
        variables: {'checkoutId': checkoutId});
    QueryResult result = await _graphQLClient!.mutate(_options);
    checkForError(
      result,
      key: 'checkoutDiscountCodeRemove',
      errorKey: 'checkoutUserErrors',
    );
    return Checkout.fromJson(
        ((result.data!['checkoutDiscountCodeRemove'] ?? const {})['checkout'] ??
            const {}));
  }

  /// Appends the [giftCardCodes] to the [Checkout] that [checkoutId] belongs to.
  Future<void> checkoutGiftCardAppend(
    String checkoutId,
    List<String> giftCardCodes,
  ) async {
    final MutationOptions _options = MutationOptions(
        document: gql(checkoutGiftCardsAppendMutation),
        variables: {'checkoutId': checkoutId, 'giftCardCodes': giftCardCodes});
    final QueryResult result = await _graphQLClient!.mutate(_options);
    checkForError(
      result,
      key: 'checkoutGiftCardsAppend',
      errorKey: 'checkoutUserErrors',
    );
  }

  Future<Checkout> createCheckout({
    List<LineItem>? lineItems,
    Address? mailingAddress,
    String? email,
  }) async {
    final MutationOptions _options =
        MutationOptions(document: gql(createCheckoutMutation), variables: {
      'input': {
        if (lineItems != null)
          'lineItems': [
            for (var lineItem in lineItems)
              {
                'variantId': lineItem.variantId,
                'quantity': lineItem.quantity,
                'customAttributes': lineItem.customAttributes
                    .map((e) => {
                          'key': e.key,
                          'value': e.value,
                        })
                    .toList(),
              }
          ],
        if (email != null) 'email': email,
        if (mailingAddress != null)
          'shippingAddress': {
            'address1': mailingAddress.address1,
            'address2': mailingAddress.address2,
            'city': mailingAddress.city,
            'company': mailingAddress.company,
            'country': mailingAddress.country,
            'firstName': mailingAddress.firstName,
            'lastName': mailingAddress.lastName,
            'phone': mailingAddress.phone,
            'province': mailingAddress.province,
            'zip': mailingAddress.zip
          }
      }
    });
    final QueryResult result = await _graphQLClient!.mutate(_options);
    checkForError(
      result,
      key: 'checkoutCreate',
      errorKey: 'checkoutUserErrors',
    );
    return Checkout.fromJson(
        ((result.data!['checkoutCreate'] ?? const {})['checkout'] ?? const {}));
  }

  Future<Checkout> addLineItemsToCheckout({
    required String checkoutId,
    required List<LineItem> lineItems,
  }) async {
    final MutationOptions _options = MutationOptions(
        document: gql(addLineItemsToCheckoutMutation),
        variables: {
          'checkoutId': checkoutId,
          'lineItems': [
            for (var lineItem in lineItems)
              {
                'variantId': lineItem.id,
                'quantity': lineItem.quantity,
                'customAttributes': lineItem.customAttributes
                    .map((e) => {
                          'key': e.key,
                          'value': e.value,
                        })
                    .toList(),
              }
          ],
        });
    final QueryResult result = await _graphQLClient!.mutate(_options);
    checkForError(
      result,
      key: 'addLineItemsToCheckout',
      errorKey: 'checkoutUserErrors',
    );

    return Checkout.fromJson(
        ((result.data!['checkoutLineItemsAdd'] ?? const {})['checkout'] ??
            const {}));
  }

  Future<Checkout> updateLineItemsInCheckout({
    required String checkoutId,
    required List<LineItem> lineItems,
  }) async {
    final MutationOptions _options = MutationOptions(
        document: gql(updateLineItemsInCheckoutMutation),
        variables: {
          'checkoutId': checkoutId,
          'lineItems': [
            for (var lineItem in lineItems)
              {
                'variantId': lineItem.id,
                'quantity': lineItem.quantity,
                'customAttributes': lineItem.customAttributes
                    .map((e) => {
                          'key': e.key,
                          'value': e.value,
                        })
                    .toList(),
              }
          ],
        });
    final QueryResult result = await _graphQLClient!.mutate(_options);
    checkForError(
      result,
      key: 'updateLineItemsInCheckout',
      errorKey: 'checkoutUserErrors',
    );

    return Checkout.fromJson(
        ((result.data!['checkoutLineItemsUpdate'] ?? const {})['checkout'] ??
            const {}));
  }

  Future<Checkout> removeLineItemsFromCheckout({
    required String checkoutId,
    required List<LineItem> lineItems,
  }) async {
    final MutationOptions _options = MutationOptions(
        document: gql(removeLineItemsFromCheckoutMutation),
        variables: {
          'checkoutId': checkoutId,
          'lineItemIds': [for (var lineItem in lineItems) lineItem.id],
        });

    final QueryResult result = await _graphQLClient!.mutate(_options);
    checkForError(
      result,
      key: 'removeLineItemsFromCheckout',
      errorKey: 'checkoutUserErrors',
    );

    return Checkout.fromJson(
        ((result.data!['checkoutLineItemsRemove'] ?? const {})['checkout'] ??
            const {}));
  }

  /// Removes the Gift card that [appliedGiftCardId] belongs to, from the [Checkout] that [checkoutId] belongs to.
  Future<void> checkoutGiftCardRemove(
    String appliedGiftCardId,
    String checkoutId,
  ) async {
    final MutationOptions _options = MutationOptions(
        document: gql(checkoutGiftCardRemoveMutation),
        variables: {
          'appliedGiftCardId': appliedGiftCardId,
          'checkoutId': checkoutId
        });
    final QueryResult result = await _graphQLClient!.mutate(_options);
    checkForError(
      result,
      key: 'checkoutGiftCardRemoveV2',
      errorKey: 'checkoutUserErrors',
    );
  }

  /// Removes the Gift card that [appliedGiftCardId] belongs to, from the [Checkout] that [checkoutId] belongs to.
  Future<Checkout> checkoutShippingLineUpdate(
    String checkoutId,
    String shippingRateHandle,
  ) async {
    final MutationOptions _options = MutationOptions(
        document: gql(checkoutShippingLineUpdateMutation),
        variables: {
          'shippingRateHandle': shippingRateHandle,
          'checkoutId': checkoutId
        });
    final QueryResult result = await _graphQLClient!.mutate(_options);
    checkForError(
      result,
      key: 'checkoutShippingLineUpdate',
      errorKey: 'checkoutUserErrors',
    );

    return Checkout.fromJson(
        ((result.data!['checkoutShippingLineUpdate'] ?? const {})['checkout'] ??
            const {}));
  }

  /// Complete [Checkout] without providing payment information.
  /// You can use this mutation for free items or items whose purchase price is covered by a gift card
  Future<void> checkoutCompleteFree(
    String checkoutId,
  ) async {
    final MutationOptions _options = MutationOptions(
        document: gql(checkoutCompleteFreeMutation),
        variables: {'checkoutId': checkoutId});
    final QueryResult result = await _graphQLClient!.mutate(_options);
    checkForError(
      result,
      key: 'checkoutCompleteFree',
      errorKey: 'checkoutUserErrors',
    );
  }

  Future<String?> checkoutCompleteWithTokenizedPaymentV3(
    String checkoutId, {
    required Checkout checkout,
    required String token,
    required PaymentTokenType paymentTokenType,
    required String idempotencyKey,
    required String amount,
    required String currencyCode,
  }) async {
    final MutationOptions _options =
        MutationOptions(document: gql(completeCheckoutWithTokenV3), variables: {
      'checkoutId': checkoutId,
      'payment': {
        'paymentAmount': {'amount': amount, 'currencyCode': currencyCode},
        'idempotencyKey': idempotencyKey,
        'billingAddress': const {},
        'paymentData': token,
        'type': paymentTokenType.toString()
      }
    });
    final QueryResult result = await _graphQLClient!.mutate(_options);
    checkForError(
      result,
      key: 'checkoutCompleteWithTokenizedPaymentV3',
      errorKey: 'checkoutUserErrors',
    );

    return result.data?['checkoutCompleteWithTokenizedPaymentV3']['payment']
        ['id'];
  }
}
