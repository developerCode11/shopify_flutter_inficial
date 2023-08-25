class Filters {
  String? id;
  String? label;
  String? type;
  List<Values>? values;

  Filters({
    this.id,
    this.label,
    this.type,
    this.values,
  });

  Filters.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    label = json['label'];
    type = json['type'];
    if (json['values'] != null) {
      values = <Values>[];
      json['values'].forEach((v) {
        values!.add(Values.fromJson(v));
      });
    }
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['id'] = id;
    data['label'] = label;
    data['type'] = type;
    if (values != null) {
      data['values'] = values!.map((v) => v.toJson()).toList();
    }
    return data;
  }
}

class Values {
  String? id;
  String? label;
  int? count;
  String? input;

  Values({this.id, this.label, this.count, this.input});

  Values.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    label = json['label'];
    count = json['count'];
    input = json['input'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['id'] = id;
    data['label'] = label;
    data['count'] = count;
    data['input'] = input;
    return data;
  }
}
