class StagedUpload {
  StagedUploadsCreate? stagedUploadsCreate;

  StagedUpload({this.stagedUploadsCreate});

  StagedUpload.fromJson(Map<String, dynamic> json) {
    stagedUploadsCreate = json['stagedUploadsCreate'] != null
        ? StagedUploadsCreate.fromJson(json['stagedUploadsCreate'])
        : null;
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    if (stagedUploadsCreate != null) {
      data['stagedUploadsCreate'] = stagedUploadsCreate!.toJson();
    }
    return data;
  }
}

class StagedUploadsCreate {
  List<StagedTargets>? stagedTargets;

  StagedUploadsCreate({this.stagedTargets});

  StagedUploadsCreate.fromJson(Map<String, dynamic> json) {
    if (json['stagedTargets'] != null) {
      stagedTargets = <StagedTargets>[];
      json['stagedTargets'].forEach((v) {
        stagedTargets!.add(StagedTargets.fromJson(v));
      });
    }
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    if (stagedTargets != null) {
      data['stagedTargets'] = stagedTargets!.map((v) => v.toJson()).toList();
    }
    return data;
  }
}

class StagedTargets {
  String? url;
  String? resourceUrl;
  List<Parameters>? parameters;

  StagedTargets({this.url, this.resourceUrl, this.parameters});

  StagedTargets.fromJson(Map<String, dynamic> json) {
    url = json['url'];
    resourceUrl = json['resourceUrl'];
    if (json['parameters'] != null) {
      parameters = <Parameters>[];
      json['parameters'].forEach((v) {
        parameters!.add(Parameters.fromJson(v));
      });
    }
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['url'] = url;
    data['resourceUrl'] = resourceUrl;
    if (parameters != null) {
      data['parameters'] = parameters!.map((v) => v.toJson()).toList();
    }
    return data;
  }
}

class Parameters {
  String? name;
  String? value;

  Parameters({this.name, this.value});

  Parameters.fromJson(Map<String, dynamic> json) {
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
