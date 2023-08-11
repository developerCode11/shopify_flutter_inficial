class Media {
  String? alt;
  String? mediaContentType;
  String? originalSource;

  Media({this.alt, this.mediaContentType, this.originalSource});

  Media.fromJson(Map<String, dynamic> json) {
    alt = json['alt'];
    mediaContentType = json['mediaContentType'];
    originalSource = json['originalSource'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['alt'] = alt;
    data['mediaContentType'] = mediaContentType;
    data['originalSource'] = originalSource;
    return data;
  }
}
