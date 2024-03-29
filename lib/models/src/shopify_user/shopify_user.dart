import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:shopify_flutter/models/src/product/metafield/metafield.dart';
import 'package:shopify_flutter/models/src/shopify_user/address/address.dart';

import 'addresses/addresses.dart';
import 'last_incomplete_checkout/last_incomplete_checkout.dart';

part 'shopify_user.freezed.dart';
part 'shopify_user.g.dart';

@freezed
class ShopifyUser with _$ShopifyUser {
  factory ShopifyUser({
    Addresses? address,
    String? createdAt,
    String? displayName,
    String? email,
    String? firstName,
    String? id,
    String? lastName,
    String? phone,
    Address? defaultAddress,
    List<String>? tags,
    List<Metafield>? metafields,
    LastIncompleteCheckout? lastIncompleteCheckout,
  }) = _ShopifyUser;

  static ShopifyUser fromGraphJson(Map<String, dynamic> json) {
    return ShopifyUser(
      address: Addresses.fromGraphJson(json['addresses'] ?? const {}),
      createdAt: json['createdAt'],
      displayName: json['displayName'],
      email: json['email'],
      firstName: json['firstName'],
      id: json['id'],
      lastName: json['lastName'] ??
          json['displayName']
              .replaceAll(RegExp(r'\b' + json['firstName'] + r'\b'), '')
              .replaceAll(RegExp(r'\s+'), ' ')
              .trim(),
      phone: json['phone'],
      tags: _getTagList((json)),
      defaultAddress: json['defaultAddress'] == null
          ? null
          : Address.fromJson(json['defaultAddress'] as Map<String, dynamic>),
      lastIncompleteCheckout: LastIncompleteCheckout.fromJson(
          json['lastIncompleteCheckout'] ?? const {}),
      metafields: _getMetafieldList(json['metafields'] ?? const []),
    );
  }

  static _getMetafieldList(List json) {
    List<Metafield> metafieldList = [];

    json.forEach((metafield) {
      if (metafield != null) {
        metafieldList.add(Metafield.fromGraphJson(metafield ?? const {}));
      }
    });
    return metafieldList;
  }

  factory ShopifyUser.fromJson(Map<String, dynamic> json) =>
      _$ShopifyUserFromJson(json);

  static _getTagList(Map<String, dynamic> json) {
    List<String> tagsList = [];
    json['tags']?.forEach((tag) => tagsList.add(tag));
    return tagsList;
  }
}
