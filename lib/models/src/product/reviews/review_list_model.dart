class ReviewListModel {
  int? currentPage;
  int? perPage;
  List<Reviews>? reviews;

  ReviewListModel({this.currentPage, this.perPage, this.reviews});

  ReviewListModel.fromJson(Map<String, dynamic> json) {
    currentPage = json['current_page'];
    perPage = json['per_page'];
    if (json['reviews'] != null) {
      reviews = <Reviews>[];
      json['reviews'].forEach((v) {
        reviews!.add(Reviews.fromJson(v));
      });
    }
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['current_page'] = currentPage;
    data['per_page'] = perPage;
    if (reviews != null) {
      data['reviews'] = reviews!.map((v) => v.toJson()).toList();
    }
    return data;
  }
}

class Reviews {
  int? id;
  String? title;
  String? body;
  int? rating;
  int? productExternalId;
  Reviewer? reviewer;
  String? source;
  String? curated;
  bool? published;
  bool? hidden;
  String? verified;
  bool? featured;
  String? createdAt;
  String? updatedAt;
  bool? hasPublishedPictures;
  bool? hasPublishedVideos;
  List<Pictures>? pictures;
  String? ipAddress;
  String? productTitle;
  String? productHandle;

  Reviews(
      {this.id,
      this.title,
      this.body,
      this.rating,
      this.productExternalId,
      this.reviewer,
      this.source,
      this.curated,
      this.published,
      this.hidden,
      this.verified,
      this.featured,
      this.createdAt,
      this.updatedAt,
      this.hasPublishedPictures,
      this.hasPublishedVideos,
      this.pictures,
      this.ipAddress,
      this.productTitle,
      this.productHandle});

  Reviews.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    title = json['title'];
    body = json['body'];
    rating = json['rating'];
    productExternalId = json['product_external_id'];
    reviewer =
        json['reviewer'] != null ? Reviewer.fromJson(json['reviewer']) : null;
    source = json['source'];
    curated = json['curated'];
    published = json['published'];
    hidden = json['hidden'];
    verified = json['verified'];
    featured = json['featured'];
    createdAt = json['created_at'];
    updatedAt = json['updated_at'];
    hasPublishedPictures = json['has_published_pictures'];
    hasPublishedVideos = json['has_published_videos'];
    if (json['pictures'] != null) {
      pictures = <Pictures>[];
      json['pictures'].forEach((v) {
        pictures!.add(Pictures.fromJson(v));
      });
    }
    ipAddress = json['ip_address'];
    productTitle = json['product_title'];
    productHandle = json['product_handle'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['id'] = id;
    data['title'] = title;
    data['body'] = body;
    data['rating'] = rating;
    data['product_external_id'] = productExternalId;
    if (reviewer != null) {
      data['reviewer'] = reviewer!.toJson();
    }
    data['source'] = source;
    data['curated'] = curated;
    data['published'] = published;
    data['hidden'] = hidden;
    data['verified'] = verified;
    data['featured'] = featured;
    data['created_at'] = createdAt;
    data['updated_at'] = updatedAt;
    data['has_published_pictures'] = hasPublishedPictures;
    data['has_published_videos'] = hasPublishedVideos;
    if (pictures != null) {
      data['pictures'] = pictures!.map((v) => v.toJson()).toList();
    }
    data['ip_address'] = ipAddress;
    data['product_title'] = productTitle;
    data['product_handle'] = productHandle;
    return data;
  }
}

class Reviewer {
  int? id;
  int? externalId;
  String? email;
  String? name;
  String? phone;
  bool? acceptsMarketing;
  String? unsubscribedAt;
  String? tags;

  Reviewer(
      {this.id,
      this.externalId,
      this.email,
      this.name,
      this.phone,
      this.acceptsMarketing,
      this.unsubscribedAt,
      this.tags});

  Reviewer.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    externalId = json['external_id'];
    email = json['email'];
    name = json['name'];
    phone = json['phone'];
    acceptsMarketing = json['accepts_marketing'];
    unsubscribedAt = json['unsubscribed_at'];
    tags = json['tags'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['id'] = id;
    data['external_id'] = externalId;
    data['email'] = email;
    data['name'] = name;
    data['phone'] = phone;
    data['accepts_marketing'] = acceptsMarketing;
    data['unsubscribed_at'] = unsubscribedAt;
    data['tags'] = tags;
    return data;
  }
}

class Pictures {
  Urls? urls;
  bool? hidden;

  Pictures({this.urls, this.hidden});

  Pictures.fromJson(Map<String, dynamic> json) {
    urls = json['urls'] != null ? Urls.fromJson(json['urls']) : null;
    hidden = json['hidden'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    if (urls != null) {
      data['urls'] = urls!.toJson();
    }
    data['hidden'] = hidden;
    return data;
  }
}

class Urls {
  String? original;
  String? small;
  String? compact;
  String? huge;

  Urls({this.original, this.small, this.compact, this.huge});

  Urls.fromJson(Map<String, dynamic> json) {
    original = json['original'];
    small = json['small'];
    compact = json['compact'];
    huge = json['huge'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['original'] = original;
    data['small'] = small;
    data['compact'] = compact;
    data['huge'] = huge;
    return data;
  }
}
