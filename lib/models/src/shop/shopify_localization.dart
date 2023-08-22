class ShopifyLocalization {
  Localization? localization;

  ShopifyLocalization({this.localization});

  ShopifyLocalization.fromJson(Map<String, dynamic> json) {
    localization = json['localization'] != null
        ? new Localization.fromJson(json['localization'])
        : null;
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    if (this.localization != null) {
      data['localization'] = this.localization!.toJson();
    }
    return data;
  }
}

class Localization {
  List<AvailableLanguages>? availableLanguages;
  List<AvailableCountries>? availableCountries;

  Localization({this.availableLanguages, this.availableCountries});

  Localization.fromJson(Map<String, dynamic> json) {
    if (json['availableLanguages'] != null) {
      availableLanguages = <AvailableLanguages>[];
      json['availableLanguages'].forEach((v) {
        availableLanguages!.add(new AvailableLanguages.fromJson(v));
      });
    }
    if (json['availableCountries'] != null) {
      availableCountries = <AvailableCountries>[];
      json['availableCountries'].forEach((v) {
        availableCountries!.add(new AvailableCountries.fromJson(v));
      });
    }
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    if (this.availableLanguages != null) {
      data['availableLanguages'] =
          this.availableLanguages!.map((v) => v.toJson()).toList();
    }
    if (this.availableCountries != null) {
      data['availableCountries'] =
          this.availableCountries!.map((v) => v.toJson()).toList();
    }
    return data;
  }
}

class AvailableLanguages {
  String? isoCode;
  String? endonymName;

  AvailableLanguages({this.isoCode, this.endonymName});

  AvailableLanguages.fromJson(Map<String, dynamic> json) {
    isoCode = json['isoCode'];
    endonymName = json['endonymName'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['isoCode'] = this.isoCode;
    data['endonymName'] = this.endonymName;
    return data;
  }
}

class AvailableCountries {
  String? isoCode;
  String? name;
  Currency? currency;
  List<AvailableLanguages>? availableLanguages;

  AvailableCountries(
      {this.isoCode, this.name, this.currency, this.availableLanguages});

  AvailableCountries.fromJson(Map<String, dynamic> json) {
    isoCode = json['isoCode'];
    name = json['name'];
    currency = json['currency'] != null
        ? new Currency.fromJson(json['currency'])
        : null;
    if (json['availableLanguages'] != null) {
      availableLanguages = <AvailableLanguages>[];
      json['availableLanguages'].forEach((v) {
        availableLanguages!.add(new AvailableLanguages.fromJson(v));
      });
    }
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['isoCode'] = this.isoCode;
    data['name'] = this.name;
    if (this.currency != null) {
      data['currency'] = this.currency!.toJson();
    }
    if (this.availableLanguages != null) {
      data['availableLanguages'] =
          this.availableLanguages!.map((v) => v.toJson()).toList();
    }
    return data;
  }
}

class Currency {
  String? isoCode;
  String? name;
  String? symbol;

  Currency({this.isoCode, this.name, this.symbol});

  Currency.fromJson(Map<String, dynamic> json) {
    isoCode = json['isoCode'];
    name = json['name'];
    symbol = json['symbol'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['isoCode'] = this.isoCode;
    data['name'] = this.name;
    data['symbol'] = this.symbol;
    return data;
  }
}
