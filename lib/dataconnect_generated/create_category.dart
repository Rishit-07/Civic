part of 'generated.dart';

class CreateCategoryVariablesBuilder {
  final FirebaseDataConnect _dataConnect;
  CreateCategoryVariablesBuilder(this._dataConnect);
  Deserializer<CreateCategoryData> dataDeserializer = (dynamic json) =>
      CreateCategoryData.fromJson(jsonDecode(json));

  Future<OperationResult<CreateCategoryData, void>> execute() {
    return ref().execute();
  }

  MutationRef<CreateCategoryData, void> ref() {
    return _dataConnect.mutation(
      "CreateCategory",
      dataDeserializer,
      emptySerializer,
      null,
    );
  }
}

@immutable
class CreateCategoryCategoryInsert {
  final String id;
  CreateCategoryCategoryInsert.fromJson(dynamic json)
    : id = nativeFromJson<String>(json['id']);
  @override
  bool operator ==(Object other) {
    if (identical(this, other)) {
      return true;
    }
    if (other.runtimeType != runtimeType) {
      return false;
    }

    final CreateCategoryCategoryInsert otherTyped =
        other as CreateCategoryCategoryInsert;
    return id == otherTyped.id;
  }

  @override
  int get hashCode => id.hashCode;

  Map<String, dynamic> toJson() {
    Map<String, dynamic> json = {};
    json['id'] = nativeToJson<String>(id);
    return json;
  }

  const CreateCategoryCategoryInsert({required this.id});
}

@immutable
class CreateCategoryData {
  final CreateCategoryCategoryInsert category_insert;
  CreateCategoryData.fromJson(dynamic json)
    : category_insert = CreateCategoryCategoryInsert.fromJson(
        json['category_insert'],
      );
  @override
  bool operator ==(Object other) {
    if (identical(this, other)) {
      return true;
    }
    if (other.runtimeType != runtimeType) {
      return false;
    }

    final CreateCategoryData otherTyped = other as CreateCategoryData;
    return category_insert == otherTyped.category_insert;
  }

  @override
  int get hashCode => category_insert.hashCode;

  Map<String, dynamic> toJson() {
    Map<String, dynamic> json = {};
    json['category_insert'] = category_insert.toJson();
    return json;
  }

  const CreateCategoryData({required this.category_insert});
}
