class ContactRequest {
  final String email;
  final String title;
  final String description;

  ContactRequest({
    required this.email,
    required this.title,
    required this.description,
  });

  Map<String, dynamic> toJson() {
    return {
      'email': email,
      'title': title,
      'description': description,
    };
  }
}

class ContactResponse {
  final bool success;
  final String message;
  final String? id;

  ContactResponse({
    required this.success,
    required this.message,
    this.id,
  });

  factory ContactResponse.fromJson(Map<String, dynamic> json) {
    return ContactResponse(
      success: json['success'] ?? true,
      message: json['message'] ?? 'Message envoyé avec succès',
      id: json['id']?.toString(),
    );
  }
}