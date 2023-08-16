import 'package:shopify_flutter/models/src/product/price_v_2/price_v_2.dart';

class Cart {
  String? id;
  String? createdAt;
  String? updatedAt;
  Lines? lines;
  BuyerIdentity? buyerIdentity;
  List<Attributes>? attributes;
  Cost? cost;

  Cart(
      {this.id,
      this.createdAt,
      this.updatedAt,
      this.lines,
      this.buyerIdentity,
      this.attributes,
      this.cost});

  Cart.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    createdAt = json['createdAt'];
    updatedAt = json['updatedAt'];
    lines = json['lines'] != null ? Lines.fromJson(json['lines']) : null;
    buyerIdentity = json['buyerIdentity'] != null
        ? BuyerIdentity.fromJson(json['buyerIdentity'])
        : null;
    if (json['attributes'] != null) {
      attributes = <Attributes>[];
      json['attributes'].forEach((v) {
        attributes!.add(Attributes.fromJson(v));
      });
    }
    cost = json['cost'] != null ? Cost.fromJson(json['cost']) : null;
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['id'] = id;
    data['createdAt'] = createdAt;
    data['updatedAt'] = updatedAt;
    if (lines != null) {
      data['lines'] = lines!.toJson();
    }
    if (buyerIdentity != null) {
      data['buyerIdentity'] = buyerIdentity!.toJson();
    }
    if (attributes != null) {
      data['attributes'] = attributes!.map((v) => v.toJson()).toList();
    }
    if (cost != null) {
      data['cost'] = cost!.toJson();
    }
    return data;
  }
}

class Lines {
  List<Edges>? edges;

  Lines({this.edges});

  Lines.fromJson(Map<String, dynamic> json) {
    if (json['edges'] != null) {
      edges = <Edges>[];
      json['edges'].forEach((v) {
        edges!.add(Edges.fromJson(v));
      });
    }
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    if (edges != null) {
      data['edges'] = edges!.map((v) => v.toJson()).toList();
    }
    return data;
  }
}

class Edges {
  Node? node;

  Edges({this.node});

  Edges.fromJson(Map<String, dynamic> json) {
    node = json['node'] != null ? Node.fromJson(json['node']) : null;
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    if (node != null) {
      data['node'] = node!.toJson();
    }
    return data;
  }
}

class Node {
  String? id;
  Merchandise? merchandise;

  Node({this.id, this.merchandise});

  Node.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    merchandise = json['merchandise'] != null
        ? Merchandise.fromJson(json['merchandise'])
        : null;
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['id'] = id;
    if (merchandise != null) {
      data['merchandise'] = merchandise!.toJson();
    }
    return data;
  }
}

class Merchandise {
  String? id;
  String? title;
  Image? image;
  PriceV2? priceV2;
  PriceV2? compareAtPriceV2;
  int? quantityAvailable;
  List<SelectedOptions>? selectedOptions;

  Merchandise(
      {this.id,
      this.title,
      this.image,
      this.priceV2,
      this.compareAtPriceV2,
      this.quantityAvailable,
      this.selectedOptions});

  Merchandise.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    title = json['title'];
    image = json['image'] != null ? Image.fromJson(json['image']) : null;
    priceV2 =
        json['priceV2'] != null ? PriceV2.fromJson(json['priceV2']) : null;
    compareAtPriceV2 = json['compareAtPriceV2'];
    quantityAvailable = json['quantityAvailable'];
    if (json['selectedOptions'] != null) {
      selectedOptions = <SelectedOptions>[];
      json['selectedOptions'].forEach((v) {
        selectedOptions!.add(SelectedOptions.fromJson(v));
      });
    }
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['id'] = id;
    data['title'] = title;
    if (image != null) {
      data['image'] = image!.toJson();
    }
    if (priceV2 != null) {
      data['priceV2'] = priceV2!.toJson();
    }
    data['compareAtPriceV2'] = compareAtPriceV2;
    data['quantityAvailable'] = quantityAvailable;
    if (selectedOptions != null) {
      data['selectedOptions'] =
          selectedOptions!.map((v) => v.toJson()).toList();
    }
    return data;
  }
}

class Image {
  String? altText;
  String? id;
  String? originalSrc;

  Image({this.altText, this.id, this.originalSrc});

  Image.fromJson(Map<String, dynamic> json) {
    altText = json['altText'];
    id = json['id'];
    originalSrc = json['originalSrc'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['altText'] = altText;
    data['id'] = id;
    data['originalSrc'] = originalSrc;
    return data;
  }
}

class SelectedOptions {
  String? name;
  String? value;

  SelectedOptions({this.name, this.value});

  SelectedOptions.fromJson(Map<String, dynamic> json) {
    name = json['name'];
    value = json['value'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['name'] = name;
    data['value'] = value;
    return data;
  }
}

class BuyerIdentity {
  String? countryCode;
  String? email;
  String? phone;
  List<DeliveryAddressPreferences>? deliveryAddressPreferences;

  BuyerIdentity(
      {this.countryCode,
      this.email,
      this.phone,
      this.deliveryAddressPreferences});

  BuyerIdentity.fromJson(Map<String, dynamic> json) {
    countryCode = json['countryCode'];
    email = json['email'];
    phone = json['phone'];
    if (json['deliveryAddressPreferences'] != null) {
      deliveryAddressPreferences = <DeliveryAddressPreferences>[];
      json['deliveryAddressPreferences'].forEach((v) {
        deliveryAddressPreferences!.add(DeliveryAddressPreferences.fromJson(v));
      });
    }
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['countryCode'] = countryCode;
    data['email'] = email;
    data['phone'] = phone;
    if (deliveryAddressPreferences != null) {
      data['deliveryAddressPreferences'] =
          deliveryAddressPreferences!.map((v) => v.toJson()).toList();
    }
    return data;
  }
}

class DeliveryAddressPreferences {
  String? sTypename;

  DeliveryAddressPreferences({this.sTypename});

  DeliveryAddressPreferences.fromJson(Map<String, dynamic> json) {
    sTypename = json['__typename'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['__typename'] = sTypename;
    return data;
  }
}

class Attributes {
  String? key;
  String? value;

  Attributes({this.key, this.value});

  Attributes.fromJson(Map<String, dynamic> json) {
    key = json['key'];
    value = json['value'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['key'] = key;
    data['value'] = value;
    return data;
  }
}

class Cost {
  PriceV2? totalAmount;
  PriceV2? subtotalAmount;
  Null? totalTaxAmount;
  Null? totalDutyAmount;

  Cost(
      {this.totalAmount,
      this.subtotalAmount,
      this.totalTaxAmount,
      this.totalDutyAmount});

  Cost.fromJson(Map<String, dynamic> json) {
    totalAmount = json['totalAmount'] != null
        ? PriceV2.fromJson(json['totalAmount'])
        : null;
    subtotalAmount = json['subtotalAmount'] != null
        ? PriceV2.fromJson(json['subtotalAmount'])
        : null;
    totalTaxAmount = json['totalTaxAmount'];
    totalDutyAmount = json['totalDutyAmount'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    if (totalAmount != null) {
      data['totalAmount'] = totalAmount!.toJson();
    }
    if (subtotalAmount != null) {
      data['subtotalAmount'] = subtotalAmount!.toJson();
    }
    data['totalTaxAmount'] = totalTaxAmount;
    data['totalDutyAmount'] = totalDutyAmount;
    return data;
  }
}
