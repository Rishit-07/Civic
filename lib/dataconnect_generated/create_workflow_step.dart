part of 'generated.dart';

class CreateWorkflowStepVariablesBuilder {
  final FirebaseDataConnect _dataConnect;
  CreateWorkflowStepVariablesBuilder(this._dataConnect);
  Deserializer<CreateWorkflowStepData> dataDeserializer = (dynamic json) =>
      CreateWorkflowStepData.fromJson(jsonDecode(json));

  Future<OperationResult<CreateWorkflowStepData, void>> execute() {
    return ref().execute();
  }

  MutationRef<CreateWorkflowStepData, void> ref() {
    return _dataConnect.mutation(
      "CreateWorkflowStep",
      dataDeserializer,
      emptySerializer,
      null,
    );
  }
}

@immutable
class CreateWorkflowStepWorkflowStepInsert {
  final String id;
  CreateWorkflowStepWorkflowStepInsert.fromJson(dynamic json)
    : id = nativeFromJson<String>(json['id']);
  @override
  bool operator ==(Object other) {
    if (identical(this, other)) {
      return true;
    }
    if (other.runtimeType != runtimeType) {
      return false;
    }

    final CreateWorkflowStepWorkflowStepInsert otherTyped =
        other as CreateWorkflowStepWorkflowStepInsert;
    return id == otherTyped.id;
  }

  @override
  int get hashCode => id.hashCode;

  Map<String, dynamic> toJson() {
    Map<String, dynamic> json = {};
    json['id'] = nativeToJson<String>(id);
    return json;
  }

  const CreateWorkflowStepWorkflowStepInsert({required this.id});
}

@immutable
class CreateWorkflowStepData {
  final CreateWorkflowStepWorkflowStepInsert workflowStep_insert;
  CreateWorkflowStepData.fromJson(dynamic json)
    : workflowStep_insert = CreateWorkflowStepWorkflowStepInsert.fromJson(
        json['workflowStep_insert'],
      );
  @override
  bool operator ==(Object other) {
    if (identical(this, other)) {
      return true;
    }
    if (other.runtimeType != runtimeType) {
      return false;
    }

    final CreateWorkflowStepData otherTyped = other as CreateWorkflowStepData;
    return workflowStep_insert == otherTyped.workflowStep_insert;
  }

  @override
  int get hashCode => workflowStep_insert.hashCode;

  Map<String, dynamic> toJson() {
    Map<String, dynamic> json = {};
    json['workflowStep_insert'] = workflowStep_insert.toJson();
    return json;
  }

  const CreateWorkflowStepData({required this.workflowStep_insert});
}
