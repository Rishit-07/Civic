part of 'generated.dart';

class GetWorkflowVariablesBuilder {
  
  final FirebaseDataConnect _dataConnect;
  GetWorkflowVariablesBuilder(this._dataConnect, );
  Deserializer<GetWorkflowData> dataDeserializer = (dynamic json)  => GetWorkflowData.fromJson(jsonDecode(json));
  
  Future<QueryResult<GetWorkflowData, void>> execute({QueryFetchPolicy fetchPolicy = QueryFetchPolicy.preferCache}) {
    return ref().execute(fetchPolicy: fetchPolicy);
  }

  QueryRef<GetWorkflowData, void> ref() {
    
    return _dataConnect.query("GetWorkflow", dataDeserializer, emptySerializer, null);
  }
}

@immutable
class GetWorkflowWorkflow {
  final String title;
  final String description;
  GetWorkflowWorkflow.fromJson(dynamic json):
  
  title = nativeFromJson<String>(json['title']),
  description = nativeFromJson<String>(json['description']);
  @override
  bool operator ==(Object other) {
    if(identical(this, other)) {
      return true;
    }
    if(other.runtimeType != runtimeType) {
      return false;
    }

    final GetWorkflowWorkflow otherTyped = other as GetWorkflowWorkflow;
    return title == otherTyped.title && 
    description == otherTyped.description;
    
  }
  @override
  int get hashCode => Object.hashAll([title.hashCode, description.hashCode]);
  

  Map<String, dynamic> toJson() {
    Map<String, dynamic> json = {};
    json['title'] = nativeToJson<String>(title);
    json['description'] = nativeToJson<String>(description);
    return json;
  }

  GetWorkflowWorkflow({
    required this.title,
    required this.description,
  });
}

@immutable
class GetWorkflowData {
  final GetWorkflowWorkflow? workflow;
  GetWorkflowData.fromJson(dynamic json):
  
  workflow = json['workflow'] == null ? null : GetWorkflowWorkflow.fromJson(json['workflow']);
  @override
  bool operator ==(Object other) {
    if(identical(this, other)) {
      return true;
    }
    if(other.runtimeType != runtimeType) {
      return false;
    }

    final GetWorkflowData otherTyped = other as GetWorkflowData;
    return workflow == otherTyped.workflow;
    
  }
  @override
  int get hashCode => workflow.hashCode;
  

  Map<String, dynamic> toJson() {
    Map<String, dynamic> json = {};
    if (workflow != null) {
      json['workflow'] = workflow!.toJson();
    }
    return json;
  }

  GetWorkflowData({
    this.workflow,
  });
}

