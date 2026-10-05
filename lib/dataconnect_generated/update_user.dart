part of 'generated.dart';

class UpdateUserVariablesBuilder {
  
  final FirebaseDataConnect _dataConnect;
  UpdateUserVariablesBuilder(this._dataConnect, );
  Deserializer<UpdateUserData> dataDeserializer = (dynamic json)  => UpdateUserData.fromJson(jsonDecode(json));
  
  Future<OperationResult<UpdateUserData, void>> execute() {
    return ref().execute();
  }

  MutationRef<UpdateUserData, void> ref() {
    
    return _dataConnect.mutation("UpdateUser", dataDeserializer, emptySerializer, null);
  }
}

@immutable
class UpdateUserUserUpdate {
  final String id;
  UpdateUserUserUpdate.fromJson(dynamic json):
  
  id = nativeFromJson<String>(json['id']);
  @override
  bool operator ==(Object other) {
    if(identical(this, other)) {
      return true;
    }
    if(other.runtimeType != runtimeType) {
      return false;
    }

    final UpdateUserUserUpdate otherTyped = other as UpdateUserUserUpdate;
    return id == otherTyped.id;
    
  }
  @override
  int get hashCode => id.hashCode;
  

  Map<String, dynamic> toJson() {
    Map<String, dynamic> json = {};
    json['id'] = nativeToJson<String>(id);
    return json;
  }

  UpdateUserUserUpdate({
    required this.id,
  });
}

@immutable
class UpdateUserData {
  final UpdateUserUserUpdate? user_update;
  UpdateUserData.fromJson(dynamic json):
  
  user_update = json['user_update'] == null ? null : UpdateUserUserUpdate.fromJson(json['user_update']);
  @override
  bool operator ==(Object other) {
    if(identical(this, other)) {
      return true;
    }
    if(other.runtimeType != runtimeType) {
      return false;
    }

    final UpdateUserData otherTyped = other as UpdateUserData;
    return user_update == otherTyped.user_update;
    
  }
  @override
  int get hashCode => user_update.hashCode;
  

  Map<String, dynamic> toJson() {
    Map<String, dynamic> json = {};
    if (user_update != null) {
      json['user_update'] = user_update!.toJson();
    }
    return json;
  }

  UpdateUserData({
    this.user_update,
  });
}

