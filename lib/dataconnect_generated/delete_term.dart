part of 'generated.dart';

class DeleteTermVariablesBuilder {
  
  final FirebaseDataConnect _dataConnect;
  DeleteTermVariablesBuilder(this._dataConnect, );
  Deserializer<DeleteTermData> dataDeserializer = (dynamic json)  => DeleteTermData.fromJson(jsonDecode(json));
  
  Future<OperationResult<DeleteTermData, void>> execute() {
    return ref().execute();
  }

  MutationRef<DeleteTermData, void> ref() {
    
    return _dataConnect.mutation("DeleteTerm", dataDeserializer, emptySerializer, null);
  }
}

@immutable
class DeleteTermTermDelete {
  final String id;
  DeleteTermTermDelete.fromJson(dynamic json):
  
  id = nativeFromJson<String>(json['id']);
  @override
  bool operator ==(Object other) {
    if(identical(this, other)) {
      return true;
    }
    if(other.runtimeType != runtimeType) {
      return false;
    }

    final DeleteTermTermDelete otherTyped = other as DeleteTermTermDelete;
    return id == otherTyped.id;
    
  }
  @override
  int get hashCode => id.hashCode;
  

  Map<String, dynamic> toJson() {
    Map<String, dynamic> json = {};
    json['id'] = nativeToJson<String>(id);
    return json;
  }

  DeleteTermTermDelete({
    required this.id,
  });
}

@immutable
class DeleteTermData {
  final DeleteTermTermDelete? term_delete;
  DeleteTermData.fromJson(dynamic json):
  
  term_delete = json['term_delete'] == null ? null : DeleteTermTermDelete.fromJson(json['term_delete']);
  @override
  bool operator ==(Object other) {
    if(identical(this, other)) {
      return true;
    }
    if(other.runtimeType != runtimeType) {
      return false;
    }

    final DeleteTermData otherTyped = other as DeleteTermData;
    return term_delete == otherTyped.term_delete;
    
  }
  @override
  int get hashCode => term_delete.hashCode;
  

  Map<String, dynamic> toJson() {
    Map<String, dynamic> json = {};
    if (term_delete != null) {
      json['term_delete'] = term_delete!.toJson();
    }
    return json;
  }

  DeleteTermData({
    this.term_delete,
  });
}

