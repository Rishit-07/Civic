part of 'generated.dart';

class UpdateWorkflowStepVariablesBuilder {
  final FirebaseDataConnect _dataConnect;
  UpdateWorkflowStepVariablesBuilder(this._dataConnect);
  Deserializer<UpdateWorkflowStepData> dataDeserializer = (dynamic json) =>
      UpdateWorkflowStepData.fromJson(jsonDecode(json));

  Future<OperationResult<UpdateWorkflowStepData, void>> execute() {
    return ref().execute();
  }

  MutationRef<UpdateWorkflowStepData, void> ref() {
    return _dataConnect.mutation(
      "UpdateWorkflowStep",
      dataDeserializer,
      emptySerializer,
      null,
    );
  }
}

@immutable
class UpdateWorkflowStepWorkflowStepUpdate {
  final String id;
  UpdateWorkflowStepWorkflowStepUpdate.fromJson(dynamic json)
    : id = nativeFromJson<String>(json['id']);
  @override
  bool operator ==(Object other) {
    if (identical(this, other)) {
      return true;
    }
    if (other.runtimeType != runtimeType) {
      return false;
    }

    final UpdateWorkflowStepWorkflowStepUpdate otherTyped =
        other as UpdateWorkflowStepWorkflowStepUpdate;
    return id == otherTyped.id;
  }

  @override
  int get hashCode => id.hashCode;

  Map<String, dynamic> toJson() {
    Map<String, dynamic> json = {};
    json['id'] = nativeToJson<String>(id);
    return json;
  }

  const UpdateWorkflowStepWorkflowStepUpdate({required this.id});
}

@immutable
class UpdateWorkflowStepData {
  final UpdateWorkflowStepWorkflowStepUpdate? workflowStep_update;
  UpdateWorkflowStepData.fromJson(dynamic json)
    : workflowStep_update = json['workflowStep_update'] == null
          ? null
          : UpdateWorkflowStepWorkflowStepUpdate.fromJson(
              json['workflowStep_update'],
            );
  @override
  bool operator ==(Object other) {
    if (identical(this, other)) {
      return true;
    }
    if (other.runtimeType != runtimeType) {
      return false;
    }

    final UpdateWorkflowStepData otherTyped = other as UpdateWorkflowStepData;
    return workflowStep_update == otherTyped.workflowStep_update;
  }

  @override
  int get hashCode => workflowStep_update.hashCode;

  Map<String, dynamic> toJson() {
    Map<String, dynamic> json = {};
    if (workflowStep_update != null) {
      json['workflowStep_update'] = workflowStep_update!.toJson();
    }
    return json;
  }

  const UpdateWorkflowStepData({this.workflowStep_update});
}
