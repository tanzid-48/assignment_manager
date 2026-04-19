class Assignment {
  final int id;
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

  Assignment copyWith({
    int? id,
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

  Map<String, dynamic> toMap() => {
        'id': id,
        'title': title,
        'subject': subject,
        'description': description,
        'deadline': deadline.millisecondsSinceEpoch,
        'priority': priority,
        'status': status,
        'createdAt': createdAt.millisecondsSinceEpoch,
      };

  factory Assignment.fromMap(Map<String, dynamic> map) => Assignment(
        id: map['id'],
        title: map['title'],
        subject: map['subject'],
        description: map['description'],
        deadline: DateTime.fromMillisecondsSinceEpoch(map['deadline']),
        priority: map['priority'],
        status: map['status'],
        createdAt: DateTime.fromMillisecondsSinceEpoch(map['createdAt']),
      );
}