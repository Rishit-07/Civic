part of 'generated.dart';

class GetUserVariablesBuilder {
  
  final FirebaseDataConnect _dataConnect;
  GetUserVariablesBuilder(this._dataConnect, );
  Deserializer<GetUserData> dataDeserializer = (dynamic json)  => GetUserData.fromJson(jsonDecode(json));
  
  Future<QueryResult<GetUserData, void>> execute({QueryFetchPolicy fetchPolicy = QueryFetchPolicy.preferCache}) {
    return ref().execute(fetchPolicy: fetchPolicy);
  }

  QueryRef<GetUserData, void> ref() {
    
    return _dataConnect.query("GetUser", dataDeserializer, emptySerializer, null);
  }
}

@immutable
class GetUserUser {
  final String email;
  final String? displayName;
  final Timestamp createdAt;
  GetUserUser.fromJson(dynamic json):
  
  email = nativeFromJson<String>(json['email']),
  displayName = json['displayName'] == null ? null : nativeFromJson<String>(json['displayName']),
  createdAt = Timestamp.fromJson(json['createdAt']);
  @override
  bool operator ==(Object other) {
    if(identical(this, other)) {
      return true;
    }
    if(other.runtimeType != runtimeType) {
      return false;
    }

    final GetUserUser otherTyped = other as GetUserUser;
    return email == otherTyped.email && 
    displayName == otherTyped.displayName && 
    createdAt == otherTyped.createdAt;
    
  }
  @override
  int get hashCode => Object.hashAll([email.hashCode, displayName.hashCode, createdAt.hashCode]);
  

  Map<String, dynamic> toJson() {
    Map<String, dynamic> json = {};
    json['email'] = nativeToJson<String>(email);
    if (displayName != null) {
      json['displayName'] = nativeToJson<String?>(displayName);
    }
    json['createdAt'] = createdAt.toJson();
    return json;
  }

  GetUserUser({
    required this.email,
    this.displayName,
    required this.createdAt,
  });
}

@immutable
class GetUserData {
  final GetUserUser? user;
  GetUserData.fromJson(dynamic json):
  
  user = json['user'] == null ? null : GetUserUser.fromJson(json['user']);
  @override
  bool operator ==(Object other) {
    if(identical(this, other)) {
      return true;
    }
    if(other.runtimeType != runtimeType) {
      return false;
    }

    final GetUserData otherTyped = other as GetUserData;
    return user == otherTyped.user;
    
  }
  @override
  int get hashCode => user.hashCode;
  

  Map<String, dynamic> toJson() {
    Map<String, dynamic> json = {};
    if (user != null) {
      json['user'] = user!.toJson();
    }
    return json;
  }

  GetUserData({
    this.user,
  });
}

