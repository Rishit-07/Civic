part of 'generated.dart';

class CreateUserBookmarkVariablesBuilder {
  
  final FirebaseDataConnect _dataConnect;
  CreateUserBookmarkVariablesBuilder(this._dataConnect, );
  Deserializer<CreateUserBookmarkData> dataDeserializer = (dynamic json)  => CreateUserBookmarkData.fromJson(jsonDecode(json));
  
  Future<OperationResult<CreateUserBookmarkData, void>> execute() {
    return ref().execute();
  }

  MutationRef<CreateUserBookmarkData, void> ref() {
    
    return _dataConnect.mutation("CreateUserBookmark", dataDeserializer, emptySerializer, null);
  }
}

@immutable
class CreateUserBookmarkUserBookmarkInsert {
  final String id;
  CreateUserBookmarkUserBookmarkInsert.fromJson(dynamic json):
  
  id = nativeFromJson<String>(json['id']);
  @override
  bool operator ==(Object other) {
    if(identical(this, other)) {
      return true;
    }
    if(other.runtimeType != runtimeType) {
      return false;
    }

    final CreateUserBookmarkUserBookmarkInsert otherTyped = other as CreateUserBookmarkUserBookmarkInsert;
    return id == otherTyped.id;
    
  }
  @override
  int get hashCode => id.hashCode;
  

  Map<String, dynamic> toJson() {
    Map<String, dynamic> json = {};
    json['id'] = nativeToJson<String>(id);
    return json;
  }

  CreateUserBookmarkUserBookmarkInsert({
    required this.id,
  });
}

@immutable
class CreateUserBookmarkData {
  final CreateUserBookmarkUserBookmarkInsert userBookmark_insert;
  CreateUserBookmarkData.fromJson(dynamic json):
  
  userBookmark_insert = CreateUserBookmarkUserBookmarkInsert.fromJson(json['userBookmark_insert']);
  @override
  bool operator ==(Object other) {
    if(identical(this, other)) {
      return true;
    }
    if(other.runtimeType != runtimeType) {
      return false;
    }

    final CreateUserBookmarkData otherTyped = other as CreateUserBookmarkData;
    return userBookmark_insert == otherTyped.userBookmark_insert;
    
  }
  @override
  int get hashCode => userBookmark_insert.hashCode;
  

  Map<String, dynamic> toJson() {
    Map<String, dynamic> json = {};
    json['userBookmark_insert'] = userBookmark_insert.toJson();
    return json;
  }

  CreateUserBookmarkData({
    required this.userBookmark_insert,
  });
}

