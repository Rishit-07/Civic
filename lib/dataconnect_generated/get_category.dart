part of 'generated.dart';

class GetCategoryVariablesBuilder {
  final FirebaseDataConnect _dataConnect;
  GetCategoryVariablesBuilder(this._dataConnect);
  Deserializer<GetCategoryData> dataDeserializer = (dynamic json) =>
      GetCategoryData.fromJson(jsonDecode(json));

  Future<QueryResult<GetCategoryData, void>> execute({
    QueryFetchPolicy fetchPolicy = QueryFetchPolicy.preferCache,
  }) {
    return ref().execute(fetchPolicy: fetchPolicy);
  }

  QueryRef<GetCategoryData, void> ref() {
    return _dataConnect.query(
      "GetCategory",
      dataDeserializer,
      emptySerializer,
      null,
    );
  }
}

@immutable
class GetCategoryCategory {
  final String name;
  final String slug;
  GetCategoryCategory.fromJson(dynamic json)
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

    final GetCategoryCategory otherTyped = other as GetCategoryCategory;
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

  const GetCategoryCategory({required this.name, required this.slug});
}

@immutable
class GetCategoryData {
  final GetCategoryCategory? category;
  GetCategoryData.fromJson(dynamic json)
    : category = json['category'] == null
          ? null
          : GetCategoryCategory.fromJson(json['category']);
  @override
  bool operator ==(Object other) {
    if (identical(this, other)) {
      return true;
    }
    if (other.runtimeType != runtimeType) {
      return false;
    }

    final GetCategoryData otherTyped = other as GetCategoryData;
    return category == otherTyped.category;
  }

  @override
  int get hashCode => category.hashCode;

  Map<String, dynamic> toJson() {
    Map<String, dynamic> json = {};
    if (category != null) {
      json['category'] = category!.toJson();
    }
    return json;
  }

  const GetCategoryData({this.category});
}
