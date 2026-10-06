part of 'generated.dart';

class DeleteCategoryVariablesBuilder {
  final FirebaseDataConnect _dataConnect;
  DeleteCategoryVariablesBuilder(this._dataConnect);
  Deserializer<DeleteCategoryData> dataDeserializer = (dynamic json) =>
      DeleteCategoryData.fromJson(jsonDecode(json));

  Future<OperationResult<DeleteCategoryData, void>> execute() {
    return ref().execute();
  }

  MutationRef<DeleteCategoryData, void> ref() {
    return _dataConnect.mutation(
      "DeleteCategory",
      dataDeserializer,
      emptySerializer,
      null,
    );
  }
}

@immutable
class DeleteCategoryCategoryDelete {
  final String id;
  DeleteCategoryCategoryDelete.fromJson(dynamic json)
    : id = nativeFromJson<String>(json['id']);
  @override
  bool operator ==(Object other) {
    if (identical(this, other)) {
      return true;
    }
    if (other.runtimeType != runtimeType) {
      return false;
    }

    final DeleteCategoryCategoryDelete otherTyped =
        other as DeleteCategoryCategoryDelete;
    return id == otherTyped.id;
  }

  @override
  int get hashCode => id.hashCode;

  Map<String, dynamic> toJson() {
    Map<String, dynamic> json = {};
    json['id'] = nativeToJson<String>(id);
    return json;
  }

  const DeleteCategoryCategoryDelete({required this.id});
}

@immutable
class DeleteCategoryData {
  final DeleteCategoryCategoryDelete? category_delete;
  DeleteCategoryData.fromJson(dynamic json)
    : category_delete = json['category_delete'] == null
          ? null
          : DeleteCategoryCategoryDelete.fromJson(json['category_delete']);
  @override
  bool operator ==(Object other) {
    if (identical(this, other)) {
      return true;
    }
    if (other.runtimeType != runtimeType) {
      return false;
    }

    final DeleteCategoryData otherTyped = other as DeleteCategoryData;
    return category_delete == otherTyped.category_delete;
  }

  @override
  int get hashCode => category_delete.hashCode;

  Map<String, dynamic> toJson() {
    Map<String, dynamic> json = {};
    if (category_delete != null) {
      json['category_delete'] = category_delete!.toJson();
    }
    return json;
  }

  const DeleteCategoryData({this.category_delete});
}
