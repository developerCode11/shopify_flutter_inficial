class InputList {
  List<Input>? input;

  InputList({this.input});

  InputList.fromJson(Map<String, dynamic> json) {
    if (json['input'] != null) {
      input = <Input>[];
      json['input'].forEach((v) {
        input!.add(Input.fromJson(v));
      });
    }
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    if (input != null) {
      data['input'] = input!.map((v) => v.toJson()).toList();
    }
    return data;
  }
}

class Input {
  String? fileSize;
  String? filename;
  String? httpMethod;
  String? mimeType;
  String? resource;
  String? filepath;

  Input(
      {this.fileSize,
      this.filename,
      this.httpMethod,
      this.mimeType,
      this.resource,
      this.filepath});

  Input.fromJson(Map<String, dynamic> json) {
    fileSize = json['fileSize'];
    filename = json['filename'];
    httpMethod = json['httpMethod'];
    mimeType = json['mimeType'];
    resource = json['resource'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['fileSize'] = fileSize;
    data['filename'] = filename;
    data['httpMethod'] = httpMethod;
    data['mimeType'] = mimeType;
    data['resource'] = resource;
    return data;
  }
}
