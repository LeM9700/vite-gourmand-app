class ContactMessageModel {
  final int id;
  final String email;
  final String title;
  final String description;
  final String status; // SENT, FAILED, ARCHIVED, TREATED
  final DateTime createdAt;

  ContactMessageModel({
    required this.id,
    required this.email,
    required this.title,
    required this.description,
    required this.status,
    required this.createdAt,
  });

  factory ContactMessageModel.fromJson(Map<String, dynamic> json) {
    return ContactMessageModel(
      id: json['id'] ?? 0,
      email: json['email'] ?? '',
      title: json['title'] ?? '',
      description: json['description'] ?? '',
      status: json['status'] ?? 'SENT',
      createdAt: DateTime.tryParse(json['created_at'] ?? '') ?? DateTime.now(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'email': email,
      'title': title,
      'description': description,
      'status': status,
      'created_at': createdAt.toIso8601String(),
    };
  }
}

/// Labels pour les statuts des messages
class ContactMessageStatusLabels {
  static const Map<String, String> labels = {
    'SENT': 'Envoyé',
    'FAILED': 'Échec',
    'ARCHIVED': 'Archivé',
    'TREATED': 'Traité',
  };

  static String getLabel(String status) {
    return labels[status] ?? status;
  }
}
