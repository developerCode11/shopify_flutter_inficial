class Video {
  String? thumbnail;
  String? videoUrl;

  Video({this.thumbnail, this.videoUrl});

  Video.fromJson(Map<String, dynamic> json) {
    thumbnail = json['thumbnail'];
    videoUrl = json['videoUrl'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['thumbnail'] = thumbnail;
    data['videoUrl'] = videoUrl;
    return data;
  }
}
