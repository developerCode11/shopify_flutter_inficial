class Menu {
  String? id;
  List<String>? tags;
  String? title;
  String? url;
  String? resourceId;
  List<MenuItems>? items;

  Menu({this.id, this.tags, this.resourceId, this.title, this.url, this.items});

  Menu.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    tags = json['tags'].cast<String>();
    title = json['title'];
    url = json['url'];
    resourceId = json['resourceId'];
    if (json['items'] != null) {
      items = <MenuItems>[];
      json['items'].forEach((v) {
        items!.add(MenuItems.fromJson(v));
      });
    }
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['id'] = id;
    data['tags'] = tags;
    data['title'] = title;
    data['url'] = url;
    data['resourceId'] = resourceId;
    if (items != null) {
      data['items'] = items!.map((v) => v.toJson()).toList();
    }
    return data;
  }
}

class MenuItems {
  String? title;
  String? url;
  String? resourceId;
  List<String>? tags;
  String? id;
  List<MenuItems>? items;

  MenuItems(
      {this.title, this.url, this.resourceId, this.tags, this.id, this.items});

  MenuItems.fromJson(Map<String, dynamic> json) {
    title = json['title'];
    url = json['url'];
    resourceId = json['resourceId'];
    tags = json['tags'].cast<String>();
    id = json['id'];
    if (json['items'] != null) {
      items = <MenuItems>[];
      json['items'].forEach((v) {
        items!.add(MenuItems.fromJson(v));
      });
    }
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['title'] = title;
    data['url'] = url;
    data['resourceId'] = resourceId;
    data['tags'] = tags;
    data['id'] = id;
    if (items != null) {
      data['items'] = items!.map((v) => v.toJson()).toList();
    }
    return data;
  }
}
