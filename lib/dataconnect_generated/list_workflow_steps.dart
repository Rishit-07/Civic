part of 'generated.dart';

class ListWorkflowStepsVariablesBuilder {
  
  final FirebaseDataConnect _dataConnect;
  ListWorkflowStepsVariablesBuilder(this._dataConnect, );
  Deserializer<ListWorkflowStepsData> dataDeserializer = (dynamic json)  => ListWorkflowStepsData.fromJson(jsonDecode(json));
  
  Future<QueryResult<ListWorkflowStepsData, void>> execute({QueryFetchPolicy fetchPolicy = QueryFetchPolicy.preferCache}) {
    return ref().execute(fetchPolicy: fetchPolicy);
  }

  QueryRef<ListWorkflowStepsData, void> ref() {
    
    return _dataConnect.query("ListWorkflowSteps", dataDeserializer, emptySerializer, null);
  }
}

@immutable
class ListWorkflowStepsWorkflowSteps {
  final int stepNumber;
  final String instructionText;
  ListWorkflowStepsWorkflowSteps.fromJson(dynamic json):
  
  stepNumber = nativeFromJson<int>(json['stepNumber']),
  instructionText = nativeFromJson<String>(json['instructionText']);
  @override
  bool operator ==(Object other) {
    if(identical(this, other)) {
      return true;
    }
    if(other.runtimeType != runtimeType) {
      return false;
    }

    final ListWorkflowStepsWorkflowSteps otherTyped = other as ListWorkflowStepsWorkflowSteps;
    return stepNumber == otherTyped.stepNumber && 
    instructionText == otherTyped.instructionText;
    
  }
  @override
  int get hashCode => Object.hashAll([stepNumber.hashCode, instructionText.hashCode]);
  

  Map<String, dynamic> toJson() {
    Map<String, dynamic> json = {};
    json['stepNumber'] = nativeToJson<int>(stepNumber);
    json['instructionText'] = nativeToJson<String>(instructionText);
    return json;
  }

  ListWorkflowStepsWorkflowSteps({
    required this.stepNumber,
    required this.instructionText,
  });
}

@immutable
class ListWorkflowStepsData {
  final List<ListWorkflowStepsWorkflowSteps> workflowSteps;
  ListWorkflowStepsData.fromJson(dynamic json):
  
  workflowSteps = (json['workflowSteps'] as List<dynamic>)
        .map((e) => ListWorkflowStepsWorkflowSteps.fromJson(e))
        .toList();
  @override
  bool operator ==(Object other) {
    if(identical(this, other)) {
      return true;
    }
    if(other.runtimeType != runtimeType) {
      return false;
    }

    final ListWorkflowStepsData otherTyped = other as ListWorkflowStepsData;
    return workflowSteps == otherTyped.workflowSteps;
    
  }
  @override
  int get hashCode => workflowSteps.hashCode;
  

  Map<String, dynamic> toJson() {
    Map<String, dynamic> json = {};
    json['workflowSteps'] = workflowSteps.map((e) => e.toJson()).toList();
    return json;
  }

  ListWorkflowStepsData({
    required this.workflowSteps,
  });
}

