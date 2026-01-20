class LoginRequest {
  final String email;
  final String password;

  LoginRequest({
    required this.email,
    required this.password,
  });

  Map<String, dynamic> toJson() {
    return {
      'email': email,
      'password': password,
    };
  }
}

class RegisterRequest {
  final String firstname;
  final String lastname;
  final String phone;
  final String address;
  final String email;
  final String password;

  RegisterRequest({
    required this.firstname,
    required this.lastname,
    required this.phone,
    required this.address,
    required this.email,
    required this.password,
  });

  Map<String, dynamic> toJson() {
    return {
      'firstname': firstname,
      'lastname': lastname,
      'phone': phone,
      'address': address,
      'email': email,
      'password': password,
    };
  }
}

class AuthResponse {
  final String accessToken;
  final String refreshToken;
  final UserData user;

  AuthResponse({
    required this.accessToken,
    required this.refreshToken,
    required this.user,
  });

  factory AuthResponse.fromJson(Map<String, dynamic> json) {
    return AuthResponse(
      accessToken: json['access_token'] ?? '',
      refreshToken: json['refresh_token'] ?? '',
      user: UserData.fromJson(json['user'] ?? {}),
    );
  }
}

class UserData {
  final int id;
  final String firstname;
  final String lastname;
  final String email;
  final String phone;
  final String address;
  final String role;
  final bool isActive;
  final DateTime? createdAt;

  UserData({
    required this.id,
    required this.firstname,
    required this.lastname,
    required this.email,
    required this.phone,
    required this.address,
    required this.role,
    this.isActive = true,
    this.createdAt,
  });

  factory UserData.fromJson(Map<String, dynamic> json) {
    return UserData(
      id: json['id'] ?? 0,
      firstname: json['firstname'] ?? '',
      lastname: json['lastname'] ?? '',
      email: json['email'] ?? '',
      phone: json['phone'] ?? '',
      address: json['address'] ?? '',
      role: json['role'] ?? 'USER',
      isActive: json['is_active'] ?? true,
      createdAt: json['created_at'] != null 
          ? DateTime.tryParse(json['created_at']) 
          : null,
    );
  }

  String get fullName => '$firstname $lastname';
  
  bool get isStaff => role == 'EMPLOYEE' || role == 'ADMIN';
  bool get isAdmin => role == 'ADMIN';
  bool get isEmployee => role == 'EMPLOYEE';
  bool get isUser => role == 'USER';
}