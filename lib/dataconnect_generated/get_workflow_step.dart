part of 'generated.dart';

class GetWorkflowStepVariablesBuilder {
  
  final FirebaseDataConnect _dataConnect;
  GetWorkflowStepVariablesBuilder(this._dataConnect, );
  Deserializer<GetWorkflowStepData> dataDeserializer = (dynamic json)  => GetWorkflowStepData.fromJson(jsonDecode(json));
  
  Future<QueryResult<GetWorkflowStepData, void>> execute({QueryFetchPolicy fetchPolicy = QueryFetchPolicy.preferCache}) {
    return ref().execute(fetchPolicy: fetchPolicy);
  }

  QueryRef<GetWorkflowStepData, void> ref() {
    
    return _dataConnect.query("GetWorkflowStep", dataDeserializer, emptySerializer, null);
  }
}

@immutable
class GetWorkflowStepWorkflowStep {
  final int stepNumber;
  final String instructionText;
  GetWorkflowStepWorkflowStep.fromJson(dynamic json):
  
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

    final GetWorkflowStepWorkflowStep otherTyped = other as GetWorkflowStepWorkflowStep;
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

  GetWorkflowStepWorkflowStep({
    required this.stepNumber,
    required this.instructionText,
  });
}

@immutable
class GetWorkflowStepData {
  final GetWorkflowStepWorkflowStep? workflowStep;
  GetWorkflowStepData.fromJson(dynamic json):
  
  workflowStep = json['workflowStep'] == null ? null : GetWorkflowStepWorkflowStep.fromJson(json['workflowStep']);
  @override
  bool operator ==(Object other) {
    if(identical(this, other)) {
      return true;
    }
    if(other.runtimeType != runtimeType) {
      return false;
    }

    final GetWorkflowStepData otherTyped = other as GetWorkflowStepData;
    return workflowStep == otherTyped.workflowStep;
    
  }
  @override
  int get hashCode => workflowStep.hashCode;
  

  Map<String, dynamic> toJson() {
    Map<String, dynamic> json = {};
    if (workflowStep != null) {
      json['workflowStep'] = workflowStep!.toJson();
    }
    return json;
  }

  GetWorkflowStepData({
    this.workflowStep,
  });
}

