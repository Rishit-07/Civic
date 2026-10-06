part of 'generated.dart';

class GetTermVariablesBuilder {
  final FirebaseDataConnect _dataConnect;
  GetTermVariablesBuilder(this._dataConnect);
  Deserializer<GetTermData> dataDeserializer = (dynamic json) =>
      GetTermData.fromJson(jsonDecode(json));

  Future<QueryResult<GetTermData, void>> execute({
    QueryFetchPolicy fetchPolicy = QueryFetchPolicy.preferCache,
  }) {
    return ref().execute(fetchPolicy: fetchPolicy);
  }

  QueryRef<GetTermData, void> ref() {
    return _dataConnect.query(
      "GetTerm",
      dataDeserializer,
      emptySerializer,
      null,
    );
  }
}

@immutable
class GetTermTerm {
  final String term;
  final String definition;
  GetTermTerm.fromJson(dynamic json)
    : term = nativeFromJson<String>(json['term']),
      definition = nativeFromJson<String>(json['definition']);
  @override
  bool operator ==(Object other) {
    if (identical(this, other)) {
      return true;
    }
    if (other.runtimeType != runtimeType) {
      return false;
    }

    final GetTermTerm otherTyped = other as GetTermTerm;
    return term == otherTyped.term && definition == otherTyped.definition;
  }

  @override
  int get hashCode => Object.hashAll([term.hashCode, definition.hashCode]);

  Map<String, dynamic> toJson() {
    Map<String, dynamic> json = {};
    json['term'] = nativeToJson<String>(term);
    json['definition'] = nativeToJson<String>(definition);
    return json;
  }

  const GetTermTerm({required this.term, required this.definition});
}

@immutable
class GetTermData {
  final GetTermTerm? term;
  GetTermData.fromJson(dynamic json)
    : term = json['term'] == null ? null : GetTermTerm.fromJson(json['term']);
  @override
  bool operator ==(Object other) {
    if (identical(this, other)) {
      return true;
    }
    if (other.runtimeType != runtimeType) {
      return false;
    }

    final GetTermData otherTyped = other as GetTermData;
    return term == otherTyped.term;
  }

  @override
  int get hashCode => term.hashCode;

  Map<String, dynamic> toJson() {
    Map<String, dynamic> json = {};
    if (term != null) {
      json['term'] = term!.toJson();
    }
    return json;
  }

  const GetTermData({this.term});
}
