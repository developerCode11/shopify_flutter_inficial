import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:shopify_flutter/models/src/product/price_v_2/price_v_2.dart';
import 'package:shopify_flutter/models/src/product/selected_option/selected_option.dart';
import 'package:shopify_flutter/models/src/product/shopify_image/shopify_image.dart';

part 'product_variant_checkout.freezed.dart';
part 'product_variant_checkout.g.dart';

@freezed
class ProductVariantCheckout with _$ProductVariantCheckout {
  const ProductVariantCheckout._();

  factory ProductVariantCheckout({
    required PriceV2 priceV2,
    required String title,
    required bool availableForSale,
    required String sku,
    required bool requiresShipping,
    required String id,
    ShopifyImage? image,
    PriceV2? compareAtPrice,
    double? weight,
    String? weightUnit,
    Product? product,
    List<SelectedOption>? selectedOptions,
  }) = _ProductVariantCheckout;

  factory ProductVariantCheckout.fromJson(Map<String, dynamic> json) =>
      _$ProductVariantCheckoutFromJson(json);
}

class Product {
  String? id;
  String? title;

  Product({this.id, this.title});

  Product.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    title = json['title'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['id'] = id;
    data['title'] = title;
    return data;
  }
}
