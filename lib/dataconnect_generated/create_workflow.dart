part of 'generated.dart';

class CreateWorkflowVariablesBuilder {
  final FirebaseDataConnect _dataConnect;
  CreateWorkflowVariablesBuilder(this._dataConnect);
  Deserializer<CreateWorkflowData> dataDeserializer = (dynamic json) =>
      CreateWorkflowData.fromJson(jsonDecode(json));

  Future<OperationResult<CreateWorkflowData, void>> execute() {
    return ref().execute();
  }

  MutationRef<CreateWorkflowData, void> ref() {
    return _dataConnect.mutation(
      "CreateWorkflow",
      dataDeserializer,
      emptySerializer,
      null,
    );
  }
}

@immutable
class CreateWorkflowWorkflowInsert {
  final String id;
  CreateWorkflowWorkflowInsert.fromJson(dynamic json)
    : id = nativeFromJson<String>(json['id']);
  @override
  bool operator ==(Object other) {
    if (identical(this, other)) {
      return true;
    }
    if (other.runtimeType != runtimeType) {
      return false;
    }

    final CreateWorkflowWorkflowInsert otherTyped =
        other as CreateWorkflowWorkflowInsert;
    return id == otherTyped.id;
  }

  @override
  int get hashCode => id.hashCode;

  Map<String, dynamic> toJson() {
    Map<String, dynamic> json = {};
    json['id'] = nativeToJson<String>(id);
    return json;
  }

  const CreateWorkflowWorkflowInsert({required this.id});
}

@immutable
class CreateWorkflowData {
  final CreateWorkflowWorkflowInsert workflow_insert;
  CreateWorkflowData.fromJson(dynamic json)
    : workflow_insert = CreateWorkflowWorkflowInsert.fromJson(
        json['workflow_insert'],
      );
  @override
  bool operator ==(Object other) {
    if (identical(this, other)) {
      return true;
    }
    if (other.runtimeType != runtimeType) {
      return false;
    }

    final CreateWorkflowData otherTyped = other as CreateWorkflowData;
    return workflow_insert == otherTyped.workflow_insert;
  }

  @override
  int get hashCode => workflow_insert.hashCode;

  Map<String, dynamic> toJson() {
    Map<String, dynamic> json = {};
    json['workflow_insert'] = workflow_insert.toJson();
    return json;
  }

  const CreateWorkflowData({required this.workflow_insert});
}
