part of 'generated.dart';

class UpdateCategoryVariablesBuilder {
  final FirebaseDataConnect _dataConnect;
  UpdateCategoryVariablesBuilder(this._dataConnect);
  Deserializer<UpdateCategoryData> dataDeserializer = (dynamic json) =>
      UpdateCategoryData.fromJson(jsonDecode(json));

  Future<OperationResult<UpdateCategoryData, void>> execute() {
    return ref().execute();
  }

  MutationRef<UpdateCategoryData, void> ref() {
    return _dataConnect.mutation(
      "UpdateCategory",
      dataDeserializer,
      emptySerializer,
      null,
    );
  }
}

@immutable
class UpdateCategoryCategoryUpdate {
  final String id;
  UpdateCategoryCategoryUpdate.fromJson(dynamic json)
    : id = nativeFromJson<String>(json['id']);
  @override
  bool operator ==(Object other) {
    if (identical(this, other)) {
      return true;
    }
    if (other.runtimeType != runtimeType) {
      return false;
    }

    final UpdateCategoryCategoryUpdate otherTyped =
        other as UpdateCategoryCategoryUpdate;
    return id == otherTyped.id;
  }

  @override
  int get hashCode => id.hashCode;

  Map<String, dynamic> toJson() {
    Map<String, dynamic> json = {};
    json['id'] = nativeToJson<String>(id);
    return json;
  }

  const UpdateCategoryCategoryUpdate({required this.id});
}

@immutable
class UpdateCategoryData {
  final UpdateCategoryCategoryUpdate? category_update;
  UpdateCategoryData.fromJson(dynamic json)
    : category_update = json['category_update'] == null
          ? null
          : UpdateCategoryCategoryUpdate.fromJson(json['category_update']);
  @override
  bool operator ==(Object other) {
    if (identical(this, other)) {
      return true;
    }
    if (other.runtimeType != runtimeType) {
      return false;
    }

    final UpdateCategoryData otherTyped = other as UpdateCategoryData;
    return category_update == otherTyped.category_update;
  }

  @override
  int get hashCode => category_update.hashCode;

  Map<String, dynamic> toJson() {
    Map<String, dynamic> json = {};
    if (category_update != null) {
      json['category_update'] = category_update!.toJson();
    }
    return json;
  }

  const UpdateCategoryData({this.category_update});
}
