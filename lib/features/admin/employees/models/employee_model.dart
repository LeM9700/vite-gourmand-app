/// Modèle pour un employé dans l'espace admin
class EmployeeModel {
  final int id;
  final String email;
  final String firstname;
  final String lastname;
  final String phone;
  final String address;
  final String role; // EMPLOYEE ou ADMIN
  final bool isActive;
  final DateTime createdAt;
  final DateTime updatedAt;

  EmployeeModel({
    required this.id,
    required this.email,
    required this.firstname,
    required this.lastname,
    required this.phone,
    required this.address,
    required this.role,
    required this.isActive,
    required this.createdAt,
    required this.updatedAt,
  });

  factory EmployeeModel.fromJson(Map<String, dynamic> json) {
    return EmployeeModel(
      id: json['id'] ?? 0,
      email: json['email'] ?? '',
      firstname: json['firstname'] ?? '',
      lastname: json['lastname'] ?? '',
      phone: json['phone'] ?? '',
      address: json['address'] ?? '',
      role: json['role'] ?? 'EMPLOYEE',
      isActive: json['is_active'] ?? true,
      createdAt: DateTime.tryParse(json['created_at'] ?? '') ?? DateTime.now(),
      updatedAt: DateTime.tryParse(json['updated_at'] ?? '') ?? DateTime.now(),
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
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
    };
  }

  String get fullName => '$firstname $lastname';
  bool get isAdmin => role == 'ADMIN';
  bool get isEmployee => role == 'EMPLOYEE';
  
  String get roleLabel {
    switch (role) {
      case 'ADMIN':
        return 'Administrateur';
      case 'EMPLOYEE':
        return 'Employé';
      default:
        return role;
    }
  }
}

/// Requête pour créer un nouvel employé
class CreateEmployeeRequest {
  final String email;
  final String password;
  final String firstname;
  final String lastname;
  final String phone;
  final String address;
  final String role; 

  CreateEmployeeRequest({
    required this.email,
    required this.password,
    required this.firstname,
    required this.lastname,
    required this.phone,
    required this.address,
    this.role = 'EMPLOYEE',
  });

  Map<String, dynamic> toJson() {
    return {
      'email': email,
      'password': password,
      'firstname': firstname,
      'lastname': lastname,
      'phone': phone,
      'address': address,
      'role': role,
    };
  }
}
