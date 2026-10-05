part of 'generated.dart';

class ListWorkflowsVariablesBuilder {
  
  final FirebaseDataConnect _dataConnect;
  ListWorkflowsVariablesBuilder(this._dataConnect, );
  Deserializer<ListWorkflowsData> dataDeserializer = (dynamic json)  => ListWorkflowsData.fromJson(jsonDecode(json));
  
  Future<QueryResult<ListWorkflowsData, void>> execute({QueryFetchPolicy fetchPolicy = QueryFetchPolicy.preferCache}) {
    return ref().execute(fetchPolicy: fetchPolicy);
  }

  QueryRef<ListWorkflowsData, void> ref() {
    
    return _dataConnect.query("ListWorkflows", dataDeserializer, emptySerializer, null);
  }
}

@immutable
class ListWorkflowsWorkflows {
  final String title;
  ListWorkflowsWorkflows.fromJson(dynamic json):
  
  title = nativeFromJson<String>(json['title']);
  @override
  bool operator ==(Object other) {
    if(identical(this, other)) {
      return true;
    }
    if(other.runtimeType != runtimeType) {
      return false;
    }

    final ListWorkflowsWorkflows otherTyped = other as ListWorkflowsWorkflows;
    return title == otherTyped.title;
    
  }
  @override
  int get hashCode => title.hashCode;
  

  Map<String, dynamic> toJson() {
    Map<String, dynamic> json = {};
    json['title'] = nativeToJson<String>(title);
    return json;
  }

  ListWorkflowsWorkflows({
    required this.title,
  });
}

@immutable
class ListWorkflowsData {
  final List<ListWorkflowsWorkflows> workflows;
  ListWorkflowsData.fromJson(dynamic json):
  
  workflows = (json['workflows'] as List<dynamic>)
        .map((e) => ListWorkflowsWorkflows.fromJson(e))
        .toList();
  @override
  bool operator ==(Object other) {
    if(identical(this, other)) {
      return true;
    }
    if(other.runtimeType != runtimeType) {
      return false;
    }

    final ListWorkflowsData otherTyped = other as ListWorkflowsData;
    return workflows == otherTyped.workflows;
    
  }
  @override
  int get hashCode => workflows.hashCode;
  

  Map<String, dynamic> toJson() {
    Map<String, dynamic> json = {};
    json['workflows'] = workflows.map((e) => e.toJson()).toList();
    return json;
  }

  ListWorkflowsData({
    required this.workflows,
  });
}

