import 'dart:convert';

class AuthRequestModel {
  final String identifier;
  final String password;

  const AuthRequestModel({
    required this.identifier,
    required this.password,
  });

  Map<String, dynamic> toJson() {
    return {
      'identifier': identifier,
      'username': identifier,
      'email': identifier,
      'password': password,
    };
  }
}

class UserModel {
  final String? id;
  final String username;
  final String? firstName;
  final String? lastName;
  final String? email;
  final String? phone;
  final String role;
  final String? avatarUrl;

  const UserModel({
    this.id,
    required this.username,
    this.firstName,
    this.lastName,
    this.email,
    this.phone,
    required this.role,
    this.avatarUrl,
  });

  /// Helper getter returning full name or falling back to username.
  String get name {
    final full = '${firstName ?? ''} ${lastName ?? ''}'.trim();
    return full.isNotEmpty ? full : username;
  }

  factory UserModel.fromJson(dynamic rawJson) {
    final Map<String, dynamic> json = rawJson is String
        ? (jsonDecode(rawJson) as Map<String, dynamic>? ?? {})
        : (rawJson is Map ? Map<String, dynamic>.from(rawJson) : {});

    return UserModel(
      id: (json['id'] ?? json['_id'])?.toString(),
      username: (json['username'] ?? json['name'] ?? json['identifier'] ?? '')?.toString() ?? '',
      firstName: (json['firstName'] ?? json['first_name'])?.toString(),
      lastName: (json['lastName'] ?? json['last_name'])?.toString(),
      email: json['email']?.toString(),
      phone: json['phone']?.toString(),
      role: (json['role'] ?? 'user')?.toString() ?? 'user',
      avatarUrl: (json['avatarUrl'] ?? json['avatar_url'])?.toString(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      if (id != null) 'id': id,
      'username': username,
      if (firstName != null) 'firstName': firstName,
      if (lastName != null) 'lastName': lastName,
      if (email != null) 'email': email,
      if (phone != null) 'phone': phone,
      'role': role,
      if (avatarUrl != null) 'avatarUrl': avatarUrl,
    };
  }
}

class AuthResponseModel {
  final String accessToken;
  final String? refreshToken;
  final UserModel user;

  const AuthResponseModel({
    required this.accessToken,
    this.refreshToken,
    required this.user,
  });

  /// Backward-compatible getter for token
  String get token => accessToken;

  factory AuthResponseModel.fromJson(dynamic rawJson) {
    final Map<String, dynamic> json = rawJson is String
        ? (jsonDecode(rawJson) as Map<String, dynamic>? ?? {})
        : (rawJson is Map ? Map<String, dynamic>.from(rawJson) : {});

    final dynamic userRaw = json['user'] ?? json['data']?['user'] ?? json;

    return AuthResponseModel(
      accessToken: (json['accessToken'] ?? json['token'] ?? json['access_token'] ?? '')?.toString() ?? '',
      refreshToken: (json['refreshToken'] ?? json['refresh_token'])?.toString(),
      user: UserModel.fromJson(userRaw),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'accessToken': accessToken,
      if (refreshToken != null) 'refreshToken': refreshToken,
      'user': user.toJson(),
    };
  }
}

class AuthModel {
  final bool isAuthenticated;
  final UserModel? currentUser;
  final String? token;

  const AuthModel({this.isAuthenticated = false, this.currentUser, this.token});

  AuthModel copyWith({
    bool? isAuthenticated,
    UserModel? currentUser,
    String? token,
  }) {
    return AuthModel(
      isAuthenticated: isAuthenticated ?? this.isAuthenticated,
      currentUser: currentUser ?? this.currentUser,
      token: token ?? this.token,
    );
  }
}
