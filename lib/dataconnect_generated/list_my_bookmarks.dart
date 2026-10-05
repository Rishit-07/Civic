part of 'generated.dart';

class ListMyBookmarksVariablesBuilder {
  
  final FirebaseDataConnect _dataConnect;
  ListMyBookmarksVariablesBuilder(this._dataConnect, );
  Deserializer<ListMyBookmarksData> dataDeserializer = (dynamic json)  => ListMyBookmarksData.fromJson(jsonDecode(json));
  
  Future<QueryResult<ListMyBookmarksData, void>> execute({QueryFetchPolicy fetchPolicy = QueryFetchPolicy.preferCache}) {
    return ref().execute(fetchPolicy: fetchPolicy);
  }

  QueryRef<ListMyBookmarksData, void> ref() {
    
    return _dataConnect.query("ListMyBookmarks", dataDeserializer, emptySerializer, null);
  }
}

@immutable
class ListMyBookmarksUserBookmarks {
  final String targetId;
  final String targetType;
  ListMyBookmarksUserBookmarks.fromJson(dynamic json):
  
  targetId = nativeFromJson<String>(json['targetId']),
  targetType = nativeFromJson<String>(json['targetType']);
  @override
  bool operator ==(Object other) {
    if(identical(this, other)) {
      return true;
    }
    if(other.runtimeType != runtimeType) {
      return false;
    }

    final ListMyBookmarksUserBookmarks otherTyped = other as ListMyBookmarksUserBookmarks;
    return targetId == otherTyped.targetId && 
    targetType == otherTyped.targetType;
    
  }
  @override
  int get hashCode => Object.hashAll([targetId.hashCode, targetType.hashCode]);
  

  Map<String, dynamic> toJson() {
    Map<String, dynamic> json = {};
    json['targetId'] = nativeToJson<String>(targetId);
    json['targetType'] = nativeToJson<String>(targetType);
    return json;
  }

  ListMyBookmarksUserBookmarks({
    required this.targetId,
    required this.targetType,
  });
}

@immutable
class ListMyBookmarksData {
  final List<ListMyBookmarksUserBookmarks> userBookmarks;
  ListMyBookmarksData.fromJson(dynamic json):
  
  userBookmarks = (json['userBookmarks'] as List<dynamic>)
        .map((e) => ListMyBookmarksUserBookmarks.fromJson(e))
        .toList();
  @override
  bool operator ==(Object other) {
    if(identical(this, other)) {
      return true;
    }
    if(other.runtimeType != runtimeType) {
      return false;
    }

    final ListMyBookmarksData otherTyped = other as ListMyBookmarksData;
    return userBookmarks == otherTyped.userBookmarks;
    
  }
  @override
  int get hashCode => userBookmarks.hashCode;
  

  Map<String, dynamic> toJson() {
    Map<String, dynamic> json = {};
    json['userBookmarks'] = userBookmarks.map((e) => e.toJson()).toList();
    return json;
  }

  ListMyBookmarksData({
    required this.userBookmarks,
  });
}

