part of 'generated.dart';

class DeleteWorkflowVariablesBuilder {
  
  final FirebaseDataConnect _dataConnect;
  DeleteWorkflowVariablesBuilder(this._dataConnect, );
  Deserializer<DeleteWorkflowData> dataDeserializer = (dynamic json)  => DeleteWorkflowData.fromJson(jsonDecode(json));
  
  Future<OperationResult<DeleteWorkflowData, void>> execute() {
    return ref().execute();
  }

  MutationRef<DeleteWorkflowData, void> ref() {
    
    return _dataConnect.mutation("DeleteWorkflow", dataDeserializer, emptySerializer, null);
  }
}

@immutable
class DeleteWorkflowWorkflowDelete {
  final String id;
  DeleteWorkflowWorkflowDelete.fromJson(dynamic json):
  
  id = nativeFromJson<String>(json['id']);
  @override
  bool operator ==(Object other) {
    if(identical(this, other)) {
      return true;
    }
    if(other.runtimeType != runtimeType) {
      return false;
    }

    final DeleteWorkflowWorkflowDelete otherTyped = other as DeleteWorkflowWorkflowDelete;
    return id == otherTyped.id;
    
  }
  @override
  int get hashCode => id.hashCode;
  

  Map<String, dynamic> toJson() {
    Map<String, dynamic> json = {};
    json['id'] = nativeToJson<String>(id);
    return json;
  }

  DeleteWorkflowWorkflowDelete({
    required this.id,
  });
}

@immutable
class DeleteWorkflowData {
  final DeleteWorkflowWorkflowDelete? workflow_delete;
  DeleteWorkflowData.fromJson(dynamic json):
  
  workflow_delete = json['workflow_delete'] == null ? null : DeleteWorkflowWorkflowDelete.fromJson(json['workflow_delete']);
  @override
  bool operator ==(Object other) {
    if(identical(this, other)) {
      return true;
    }
    if(other.runtimeType != runtimeType) {
      return false;
    }

    final DeleteWorkflowData otherTyped = other as DeleteWorkflowData;
    return workflow_delete == otherTyped.workflow_delete;
    
  }
  @override
  int get hashCode => workflow_delete.hashCode;
  

  Map<String, dynamic> toJson() {
    Map<String, dynamic> json = {};
    if (workflow_delete != null) {
      json['workflow_delete'] = workflow_delete!.toJson();
    }
    return json;
  }

  DeleteWorkflowData({
    this.workflow_delete,
  });
}

