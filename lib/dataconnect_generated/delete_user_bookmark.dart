part of 'generated.dart';

class DeleteUserBookmarkVariablesBuilder {
  final FirebaseDataConnect _dataConnect;
  DeleteUserBookmarkVariablesBuilder(this._dataConnect);
  Deserializer<DeleteUserBookmarkData> dataDeserializer = (dynamic json) =>
      DeleteUserBookmarkData.fromJson(jsonDecode(json));

  Future<OperationResult<DeleteUserBookmarkData, void>> execute() {
    return ref().execute();
  }

  MutationRef<DeleteUserBookmarkData, void> ref() {
    return _dataConnect.mutation(
      "DeleteUserBookmark",
      dataDeserializer,
      emptySerializer,
      null,
    );
  }
}

@immutable
class DeleteUserBookmarkUserBookmarkDelete {
  final String id;
  DeleteUserBookmarkUserBookmarkDelete.fromJson(dynamic json)
    : id = nativeFromJson<String>(json['id']);
  @override
  bool operator ==(Object other) {
    if (identical(this, other)) {
      return true;
    }
    if (other.runtimeType != runtimeType) {
      return false;
    }

    final DeleteUserBookmarkUserBookmarkDelete otherTyped =
        other as DeleteUserBookmarkUserBookmarkDelete;
    return id == otherTyped.id;
  }

  @override
  int get hashCode => id.hashCode;

  Map<String, dynamic> toJson() {
    Map<String, dynamic> json = {};
    json['id'] = nativeToJson<String>(id);
    return json;
  }

  const DeleteUserBookmarkUserBookmarkDelete({required this.id});
}

@immutable
class DeleteUserBookmarkData {
  final DeleteUserBookmarkUserBookmarkDelete? userBookmark_delete;
  DeleteUserBookmarkData.fromJson(dynamic json)
    : userBookmark_delete = json['userBookmark_delete'] == null
          ? null
          : DeleteUserBookmarkUserBookmarkDelete.fromJson(
              json['userBookmark_delete'],
            );
  @override
  bool operator ==(Object other) {
    if (identical(this, other)) {
      return true;
    }
    if (other.runtimeType != runtimeType) {
      return false;
    }

    final DeleteUserBookmarkData otherTyped = other as DeleteUserBookmarkData;
    return userBookmark_delete == otherTyped.userBookmark_delete;
  }

  @override
  int get hashCode => userBookmark_delete.hashCode;

  Map<String, dynamic> toJson() {
    Map<String, dynamic> json = {};
    if (userBookmark_delete != null) {
      json['userBookmark_delete'] = userBookmark_delete!.toJson();
    }
    return json;
  }

  const DeleteUserBookmarkData({this.userBookmark_delete});
}
