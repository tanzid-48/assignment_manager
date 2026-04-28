class Assignment {
  final String id;       // Firestore doc ID (String)
  final String title;
  final String subject;
  final String? description;
  final DateTime deadline;
  final String priority;
  final String status;
  final DateTime createdAt;

  Assignment({
    required this.id,
    required this.title,
    required this.subject,
    this.description,
    required this.deadline,
    required this.priority,
    required this.status,
    required this.createdAt,
  });

  factory Assignment.fromMap(Map<String, dynamic> map) {
    return Assignment(
      id: map['id']?.toString() ?? '',
      title: map['title'] ?? '',
      subject: map['subject'] ?? '',
      description: map['description'],
      deadline: map['deadline'] is String
          ? DateTime.parse(map['deadline'])
          : (map['deadline'] as dynamic).toDate(),
      priority: map['priority'] ?? 'Medium',
      status: map['status'] ?? 'Pending',
      createdAt: map['createdAt'] is String
          ? DateTime.parse(map['createdAt'])
          : (map['createdAt'] as dynamic).toDate(),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'title': title,
      'subject': subject,
      'description': description,
      'deadline': deadline.toIso8601String(),
      'priority': priority,
      'status': status,
      'createdAt': createdAt.toIso8601String(),
    };
  }

  Assignment copyWith({
    String? id,
    String? title,
    String? subject,
    String? description,
    DateTime? deadline,
    String? priority,
    String? status,
    DateTime? createdAt,
  }) {
    return Assignment(
      id: id ?? this.id,
      title: title ?? this.title,
      subject: subject ?? this.subject,
      description: description ?? this.description,
      deadline: deadline ?? this.deadline,
      priority: priority ?? this.priority,
      status: status ?? this.status,
      createdAt: createdAt ?? this.createdAt,
    );
  }
}
