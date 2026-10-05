part of 'generated.dart';

class UpdateTermVariablesBuilder {
  
  final FirebaseDataConnect _dataConnect;
  UpdateTermVariablesBuilder(this._dataConnect, );
  Deserializer<UpdateTermData> dataDeserializer = (dynamic json)  => UpdateTermData.fromJson(jsonDecode(json));
  
  Future<OperationResult<UpdateTermData, void>> execute() {
    return ref().execute();
  }

  MutationRef<UpdateTermData, void> ref() {
    
    return _dataConnect.mutation("UpdateTerm", dataDeserializer, emptySerializer, null);
  }
}

@immutable
class UpdateTermTermUpdate {
  final String id;
  UpdateTermTermUpdate.fromJson(dynamic json):
  
  id = nativeFromJson<String>(json['id']);
  @override
  bool operator ==(Object other) {
    if(identical(this, other)) {
      return true;
    }
    if(other.runtimeType != runtimeType) {
      return false;
    }

    final UpdateTermTermUpdate otherTyped = other as UpdateTermTermUpdate;
    return id == otherTyped.id;
    
  }
  @override
  int get hashCode => id.hashCode;
  

  Map<String, dynamic> toJson() {
    Map<String, dynamic> json = {};
    json['id'] = nativeToJson<String>(id);
    return json;
  }

  UpdateTermTermUpdate({
    required this.id,
  });
}

@immutable
class UpdateTermData {
  final UpdateTermTermUpdate? term_update;
  UpdateTermData.fromJson(dynamic json):
  
  term_update = json['term_update'] == null ? null : UpdateTermTermUpdate.fromJson(json['term_update']);
  @override
  bool operator ==(Object other) {
    if(identical(this, other)) {
      return true;
    }
    if(other.runtimeType != runtimeType) {
      return false;
    }

    final UpdateTermData otherTyped = other as UpdateTermData;
    return term_update == otherTyped.term_update;
    
  }
  @override
  int get hashCode => term_update.hashCode;
  

  Map<String, dynamic> toJson() {
    Map<String, dynamic> json = {};
    if (term_update != null) {
      json['term_update'] = term_update!.toJson();
    }
    return json;
  }

  UpdateTermData({
    this.term_update,
  });
}

