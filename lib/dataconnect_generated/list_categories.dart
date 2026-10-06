part of 'generated.dart';

class ListCategoriesVariablesBuilder {
  final FirebaseDataConnect _dataConnect;
  ListCategoriesVariablesBuilder(this._dataConnect);
  Deserializer<ListCategoriesData> dataDeserializer = (dynamic json) =>
      ListCategoriesData.fromJson(jsonDecode(json));

  Future<QueryResult<ListCategoriesData, void>> execute({
    QueryFetchPolicy fetchPolicy = QueryFetchPolicy.preferCache,
  }) {
    return ref().execute(fetchPolicy: fetchPolicy);
  }

  QueryRef<ListCategoriesData, void> ref() {
    return _dataConnect.query(
      "ListCategories",
      dataDeserializer,
      emptySerializer,
      null,
    );
  }
}

@immutable
class ListCategoriesCategories {
  final String name;
  final String slug;
  ListCategoriesCategories.fromJson(dynamic json)
    : name = nativeFromJson<String>(json['name']),
      slug = nativeFromJson<String>(json['slug']);
  @override
  bool operator ==(Object other) {
    if (identical(this, other)) {
      return true;
    }
    if (other.runtimeType != runtimeType) {
      return false;
    }

    final ListCategoriesCategories otherTyped =
        other as ListCategoriesCategories;
    return name == otherTyped.name && slug == otherTyped.slug;
  }

  @override
  int get hashCode => Object.hashAll([name.hashCode, slug.hashCode]);

  Map<String, dynamic> toJson() {
    Map<String, dynamic> json = {};
    json['name'] = nativeToJson<String>(name);
    json['slug'] = nativeToJson<String>(slug);
    return json;
  }

  const ListCategoriesCategories({required this.name, required this.slug});
}

@immutable
class ListCategoriesData {
  final List<ListCategoriesCategories> categories;
  ListCategoriesData.fromJson(dynamic json)
    : categories = (json['categories'] as List<dynamic>)
          .map((e) => ListCategoriesCategories.fromJson(e))
          .toList();
  @override
  bool operator ==(Object other) {
    if (identical(this, other)) {
      return true;
    }
    if (other.runtimeType != runtimeType) {
      return false;
    }

    final ListCategoriesData otherTyped = other as ListCategoriesData;
    return categories == otherTyped.categories;
  }

  @override
  int get hashCode => categories.hashCode;

  Map<String, dynamic> toJson() {
    Map<String, dynamic> json = {};
    json['categories'] = categories.map((e) => e.toJson()).toList();
    return json;
  }

  const ListCategoriesData({required this.categories});
}
