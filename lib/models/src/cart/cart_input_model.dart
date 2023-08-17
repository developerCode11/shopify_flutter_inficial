class CartInput {
  Input? input;

  CartInput({this.input});

  CartInput.fromJson(Map<String, dynamic> json) {
    input = json['input'] != null ? Input.fromJson(json['input']) : null;
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    if (input != null) {
      data['input'] = input!.toJson();
    }
    return data;
  }
}

class Input {
  List<Attributes>? attributes;
  BuyerIdentity? buyerIdentity;
  List<String>? discountCodes;
  List<Lines> lines = [];
  List<Metafields>? metafields;
  String? note;

  Input(
      {this.attributes,
      required this.buyerIdentity,
      this.discountCodes,
      required this.lines,
      this.metafields,
      this.note});

  Input.fromJson(Map<String, dynamic> json) {
    if (json['attributes'] != null) {
      attributes = <Attributes>[];
      json['attributes'].forEach((v) {
        attributes!.add(Attributes.fromJson(v));
      });
    }
    buyerIdentity = json['buyerIdentity'] != null
        ? BuyerIdentity.fromJson(json['buyerIdentity'])
        : null;
    discountCodes = json['discountCodes'].cast<String>();
    if (json['lines'] != null) {
      lines = <Lines>[];
      json['lines'].forEach((v) {
        lines!.add(Lines.fromJson(v));
      });
    }
    if (json['metafields'] != null) {
      metafields = <Metafields>[];
      json['metafields'].forEach((v) {
        metafields!.add(Metafields.fromJson(v));
      });
    }
    note = json['note'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    if (attributes != null) {
      data['attributes'] = attributes!.map((v) => v.toJson()).toList();
    }
    if (buyerIdentity != null) {
      data['buyerIdentity'] = buyerIdentity!.toJson();
    }
    if (discountCodes != null) {
      data['discountCodes'] = discountCodes;
    }
    data['lines'] = lines.map((v) => v.toJson()).toList();
    if (metafields != null) {
      data['metafields'] = metafields!.map((v) => v.toJson()).toList();
    }
    if (note != null) {
      data['note'] = note;
    }
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

class BuyerIdentity {
  String? countryCode;
  String? customerAccessToken;
  List<DeliveryAddressPreferences>? deliveryAddressPreferences;
  String? email;
  String? phone;
  List<String>? walletPreferences;

  BuyerIdentity(
      {this.countryCode,
      this.customerAccessToken,
      this.deliveryAddressPreferences,
      this.email,
      this.phone,
      this.walletPreferences});

  BuyerIdentity.fromJson(Map<String, dynamic> json) {
    if (countryCode != null) {
      countryCode = json['countryCode'];
    }
    if (customerAccessToken != null) {
      customerAccessToken = json['customerAccessToken'];
    }
    if (json['deliveryAddressPreferences'] != null) {
      deliveryAddressPreferences = <DeliveryAddressPreferences>[];
      json['deliveryAddressPreferences'].forEach((v) {
        deliveryAddressPreferences!.add(DeliveryAddressPreferences.fromJson(v));
      });
    }
    email = json['email'];
    phone = json['phone'];
    if (walletPreferences != null) {
      walletPreferences = json['walletPreferences'].cast<String>();
    }
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    if (countryCode != null) {
      data['countryCode'] = countryCode;
    }
    if (customerAccessToken != null) {
      data['customerAccessToken'] = customerAccessToken;
    }
    if (deliveryAddressPreferences != null) {
      data['deliveryAddressPreferences'] =
          deliveryAddressPreferences!.first.toJson();
    }
    data['email'] = email;
    data['phone'] = phone;
    if (walletPreferences != null) {
      data['walletPreferences'] = walletPreferences;
    }
    return data;
  }
}

class DeliveryAddressPreferences {
  String? customerAddressId;
  DeliveryAddress? deliveryAddress;

  DeliveryAddressPreferences({this.customerAddressId, this.deliveryAddress});

  DeliveryAddressPreferences.fromJson(Map<String, dynamic> json) {
    customerAddressId = json['customerAddressId'];
    deliveryAddress = json['deliveryAddress'] != null
        ? DeliveryAddress.fromJson(json['deliveryAddress'])
        : null;
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    if (customerAddressId != null) {
      data['customerAddressId'] = customerAddressId;
    }
    if (deliveryAddress != null) {
      data['deliveryAddress'] = deliveryAddress!.toJson();
    }
    return data;
  }
}

class DeliveryAddress {
  String? address1;
  String? address2;
  String? city;
  String? company;
  String? country;
  String? firstName;
  String? lastName;
  String? phone;
  String? province;
  String? zip;

  DeliveryAddress(
      {this.address1,
      this.address2,
      this.city,
      this.company,
      this.country,
      this.firstName,
      this.lastName,
      this.phone,
      this.province,
      this.zip});

  DeliveryAddress.fromJson(Map<String, dynamic> json) {
    address1 = json['address1'];
    address2 = json['address2'];
    city = json['city'];
    company = json['company'];
    country = json['country'];
    firstName = json['firstName'];
    lastName = json['lastName'];
    phone = json['phone'];
    province = json['province'];
    zip = json['zip'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['address1'] = address1;
    data['address2'] = address2;
    data['city'] = city;
    data['company'] = company;
    data['country'] = country;
    data['firstName'] = firstName;
    data['lastName'] = lastName;
    data['phone'] = phone;
    data['province'] = province;
    data['zip'] = zip;
    return data;
  }
}

class Lines {
  List<Attributes>? attributes;
  String? merchandiseId;
  int? quantity;
  String? sellingPlanId;
  String? id;

  Lines({
    this.attributes,
    this.merchandiseId,
    this.quantity,
    this.sellingPlanId,
    this.id,
  });

  Lines.fromJson(Map<String, dynamic> json) {
    if (json['attributes'] != null) {
      attributes = <Attributes>[];
      json['attributes'].forEach((v) {
        attributes!.add(Attributes.fromJson(v));
      });
    }
    merchandiseId = json['merchandiseId'];
    quantity = json['quantity'];
    if (json['id'] != null) {
      id = json['id'];
    }
    if (json['sellingPlanId'] != null) {
      sellingPlanId = json['sellingPlanId'];
    }
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    if (attributes != null) {
      data['attributes'] = attributes!.map((v) => v.toJson()).toList();
    }
    data['merchandiseId'] = merchandiseId;
    data['quantity'] = quantity;
    if (id != null) {
      data['id'] = id;
    }
    if (sellingPlanId != null) {
      data['sellingPlanId'] = sellingPlanId;
    }
    return data;
  }
}

class Metafields {
  String? key;
  String? type;
  String? value;

  Metafields({this.key, this.type, this.value});

  Metafields.fromJson(Map<String, dynamic> json) {
    key = json['key'];
    type = json['type'];
    value = json['value'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['key'] = key;
    data['type'] = type;
    data['value'] = value;
    return data;
  }
}
