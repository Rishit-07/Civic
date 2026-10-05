part of 'generated.dart';

class ListTermsVariablesBuilder {
  
  final FirebaseDataConnect _dataConnect;
  ListTermsVariablesBuilder(this._dataConnect, );
  Deserializer<ListTermsData> dataDeserializer = (dynamic json)  => ListTermsData.fromJson(jsonDecode(json));
  
  Future<QueryResult<ListTermsData, void>> execute({QueryFetchPolicy fetchPolicy = QueryFetchPolicy.preferCache}) {
    return ref().execute(fetchPolicy: fetchPolicy);
  }

  QueryRef<ListTermsData, void> ref() {
    
    return _dataConnect.query("ListTerms", dataDeserializer, emptySerializer, null);
  }
}

@immutable
class ListTermsTerms {
  final String term;
  final String definition;
  ListTermsTerms.fromJson(dynamic json):
  
  term = nativeFromJson<String>(json['term']),
  definition = nativeFromJson<String>(json['definition']);
  @override
  bool operator ==(Object other) {
    if(identical(this, other)) {
      return true;
    }
    if(other.runtimeType != runtimeType) {
      return false;
    }

    final ListTermsTerms otherTyped = other as ListTermsTerms;
    return term == otherTyped.term && 
    definition == otherTyped.definition;
    
  }
  @override
  int get hashCode => Object.hashAll([term.hashCode, definition.hashCode]);
  

  Map<String, dynamic> toJson() {
    Map<String, dynamic> json = {};
    json['term'] = nativeToJson<String>(term);
    json['definition'] = nativeToJson<String>(definition);
    return json;
  }

  ListTermsTerms({
    required this.term,
    required this.definition,
  });
}

@immutable
class ListTermsData {
  final List<ListTermsTerms> terms;
  ListTermsData.fromJson(dynamic json):
  
  terms = (json['terms'] as List<dynamic>)
        .map((e) => ListTermsTerms.fromJson(e))
        .toList();
  @override
  bool operator ==(Object other) {
    if(identical(this, other)) {
      return true;
    }
    if(other.runtimeType != runtimeType) {
      return false;
    }

    final ListTermsData otherTyped = other as ListTermsData;
    return terms == otherTyped.terms;
    
  }
  @override
  int get hashCode => terms.hashCode;
  

  Map<String, dynamic> toJson() {
    Map<String, dynamic> json = {};
    json['terms'] = terms.map((e) => e.toJson()).toList();
    return json;
  }

  ListTermsData({
    required this.terms,
  });
}

