part of 'generated.dart';

class DeleteWorkflowStepVariablesBuilder {
  final FirebaseDataConnect _dataConnect;
  DeleteWorkflowStepVariablesBuilder(this._dataConnect);
  Deserializer<DeleteWorkflowStepData> dataDeserializer = (dynamic json) =>
      DeleteWorkflowStepData.fromJson(jsonDecode(json));

  Future<OperationResult<DeleteWorkflowStepData, void>> execute() {
    return ref().execute();
  }

  MutationRef<DeleteWorkflowStepData, void> ref() {
    return _dataConnect.mutation(
      "DeleteWorkflowStep",
      dataDeserializer,
      emptySerializer,
      null,
    );
  }
}

@immutable
class DeleteWorkflowStepWorkflowStepDelete {
  final String id;
  DeleteWorkflowStepWorkflowStepDelete.fromJson(dynamic json)
    : id = nativeFromJson<String>(json['id']);
  @override
  bool operator ==(Object other) {
    if (identical(this, other)) {
      return true;
    }
    if (other.runtimeType != runtimeType) {
      return false;
    }

    final DeleteWorkflowStepWorkflowStepDelete otherTyped =
        other as DeleteWorkflowStepWorkflowStepDelete;
    return id == otherTyped.id;
  }

  @override
  int get hashCode => id.hashCode;

  Map<String, dynamic> toJson() {
    Map<String, dynamic> json = {};
    json['id'] = nativeToJson<String>(id);
    return json;
  }

  const DeleteWorkflowStepWorkflowStepDelete({required this.id});
}

@immutable
class DeleteWorkflowStepData {
  final DeleteWorkflowStepWorkflowStepDelete? workflowStep_delete;
  DeleteWorkflowStepData.fromJson(dynamic json)
    : workflowStep_delete = json['workflowStep_delete'] == null
          ? null
          : DeleteWorkflowStepWorkflowStepDelete.fromJson(
              json['workflowStep_delete'],
            );
  @override
  bool operator ==(Object other) {
    if (identical(this, other)) {
      return true;
    }
    if (other.runtimeType != runtimeType) {
      return false;
    }

    final DeleteWorkflowStepData otherTyped = other as DeleteWorkflowStepData;
    return workflowStep_delete == otherTyped.workflowStep_delete;
  }

  @override
  int get hashCode => workflowStep_delete.hashCode;

  Map<String, dynamic> toJson() {
    Map<String, dynamic> json = {};
    if (workflowStep_delete != null) {
      json['workflowStep_delete'] = workflowStep_delete!.toJson();
    }
    return json;
  }

  const DeleteWorkflowStepData({this.workflowStep_delete});
}
