part of 'generated.dart';

class UpdateWorkflowVariablesBuilder {
  
  final FirebaseDataConnect _dataConnect;
  UpdateWorkflowVariablesBuilder(this._dataConnect, );
  Deserializer<UpdateWorkflowData> dataDeserializer = (dynamic json)  => UpdateWorkflowData.fromJson(jsonDecode(json));
  
  Future<OperationResult<UpdateWorkflowData, void>> execute() {
    return ref().execute();
  }

  MutationRef<UpdateWorkflowData, void> ref() {
    
    return _dataConnect.mutation("UpdateWorkflow", dataDeserializer, emptySerializer, null);
  }
}

@immutable
class UpdateWorkflowWorkflowUpdate {
  final String id;
  UpdateWorkflowWorkflowUpdate.fromJson(dynamic json):
  
  id = nativeFromJson<String>(json['id']);
  @override
  bool operator ==(Object other) {
    if(identical(this, other)) {
      return true;
    }
    if(other.runtimeType != runtimeType) {
      return false;
    }

    final UpdateWorkflowWorkflowUpdate otherTyped = other as UpdateWorkflowWorkflowUpdate;
    return id == otherTyped.id;
    
  }
  @override
  int get hashCode => id.hashCode;
  

  Map<String, dynamic> toJson() {
    Map<String, dynamic> json = {};
    json['id'] = nativeToJson<String>(id);
    return json;
  }

  UpdateWorkflowWorkflowUpdate({
    required this.id,
  });
}

@immutable
class UpdateWorkflowData {
  final UpdateWorkflowWorkflowUpdate? workflow_update;
  UpdateWorkflowData.fromJson(dynamic json):
  
  workflow_update = json['workflow_update'] == null ? null : UpdateWorkflowWorkflowUpdate.fromJson(json['workflow_update']);
  @override
  bool operator ==(Object other) {
    if(identical(this, other)) {
      return true;
    }
    if(other.runtimeType != runtimeType) {
      return false;
    }

    final UpdateWorkflowData otherTyped = other as UpdateWorkflowData;
    return workflow_update == otherTyped.workflow_update;
    
  }
  @override
  int get hashCode => workflow_update.hashCode;
  

  Map<String, dynamic> toJson() {
    Map<String, dynamic> json = {};
    if (workflow_update != null) {
      json['workflow_update'] = workflow_update!.toJson();
    }
    return json;
  }

  UpdateWorkflowData({
    this.workflow_update,
  });
}

