class UserInfoModel {
  final int id;
  final String email;
  final String firstname;
  final String lastname;
  final String? phone;
  final String? address;
  final String role;
  final bool isActive;
  final bool emailConfirmed;

  UserInfoModel({
    required this.id,
    required this.email,
    required this.firstname,
    required this.lastname,
    this.phone,
    this.address,
    required this.role,
    required this.isActive,
    this.emailConfirmed = false,
  });

  factory UserInfoModel.fromJson(Map<String, dynamic> json) {
    return UserInfoModel(
      id: json['id'] ?? 0,
      email: json['email'] ?? '',
      firstname: json['firstname'] ?? '',
      lastname: json['lastname'] ?? '',
      phone: json['phone'],
      address: json['address'],
      role: json['role'] ?? 'USER',
      isActive: json['is_active'] ?? true,
      emailConfirmed: json['email_confirmed'] ?? false,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'email': email,
      'firstname': firstname,
      'lastname': lastname,
      'phone': phone,
      'address': address,
      'role': role,
      'is_active': isActive,
      'email_confirmed': emailConfirmed,
    };
  }

  // Getter pour le nom complet
  String get fullName => '$firstname $lastname'.trim();

  // Copie avec modifications
  UserInfoModel copyWith({
    int? id,
    String? email,
    String? firstname,
    String? lastname,
    String? phone,
    String? address,
    String? role,
    bool? isActive,
    bool? emailConfirmed,
  }) {
    return UserInfoModel(
      id: id ?? this.id,
      email: email ?? this.email,
      firstname: firstname ?? this.firstname,
      lastname: lastname ?? this.lastname,
      phone: phone ?? this.phone,
      address: address ?? this.address,
      role: role ?? this.role,
      isActive: isActive ?? this.isActive,
      emailConfirmed: emailConfirmed ?? this.emailConfirmed,
    );
  }
}
