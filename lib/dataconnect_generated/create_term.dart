part of 'generated.dart';

class CreateTermVariablesBuilder {
  final FirebaseDataConnect _dataConnect;
  CreateTermVariablesBuilder(this._dataConnect);
  Deserializer<CreateTermData> dataDeserializer = (dynamic json) =>
      CreateTermData.fromJson(jsonDecode(json));

  Future<OperationResult<CreateTermData, void>> execute() {
    return ref().execute();
  }

  MutationRef<CreateTermData, void> ref() {
    return _dataConnect.mutation(
      "CreateTerm",
      dataDeserializer,
      emptySerializer,
      null,
    );
  }
}

@immutable
class CreateTermTermInsert {
  final String id;
  CreateTermTermInsert.fromJson(dynamic json)
    : id = nativeFromJson<String>(json['id']);
  @override
  bool operator ==(Object other) {
    if (identical(this, other)) {
      return true;
    }
    if (other.runtimeType != runtimeType) {
      return false;
    }

    final CreateTermTermInsert otherTyped = other as CreateTermTermInsert;
    return id == otherTyped.id;
  }

  @override
  int get hashCode => id.hashCode;

  Map<String, dynamic> toJson() {
    Map<String, dynamic> json = {};
    json['id'] = nativeToJson<String>(id);
    return json;
  }

  const CreateTermTermInsert({required this.id});
}

@immutable
class CreateTermData {
  final CreateTermTermInsert term_insert;
  CreateTermData.fromJson(dynamic json)
    : term_insert = CreateTermTermInsert.fromJson(json['term_insert']);
  @override
  bool operator ==(Object other) {
    if (identical(this, other)) {
      return true;
    }
    if (other.runtimeType != runtimeType) {
      return false;
    }

    final CreateTermData otherTyped = other as CreateTermData;
    return term_insert == otherTyped.term_insert;
  }

  @override
  int get hashCode => term_insert.hashCode;

  Map<String, dynamic> toJson() {
    Map<String, dynamic> json = {};
    json['term_insert'] = term_insert.toJson();
    return json;
  }

  const CreateTermData({required this.term_insert});
}
