class TaskItem {
  final int? id;
  final String title;
  final String notes;
  final String category;
  final String priority;
  final String dueDate;
  final String dueTime;
  final bool isCompleted;
  final String createdAt;
  final String? completedAt;

  TaskItem({
    this.id,
    required this.title,
    this.notes = '',
    required this.category,
    this.priority = 'Medium',
    required this.dueDate,
    required this.dueTime,
    this.isCompleted = false,
    required this.createdAt,
    this.completedAt,
  });

  Map<String, dynamic> toMap() {
    final map = <String, dynamic>{
      'title': title,
      'notes': notes,
      'category': category,
      'priority': priority,
      'dueDate': dueDate,
      'dueTime': dueTime,
      'isCompleted': isCompleted ? 1 : 0,
      'createdAt': createdAt,
      'completedAt': completedAt,
    };
    if (id != null) {
      map['id'] = id;
    }
    return map;
  }

  factory TaskItem.fromMap(Map<String, dynamic> map) {
    return TaskItem(
      id: map['id'] as int?,
      title: map['title'] as String,
      notes: map['notes'] as String? ?? '',
      category: map['category'] as String,
      priority: map['priority'] as String? ?? 'Medium',
      dueDate: map['dueDate'] as String,
      dueTime: map['dueTime'] as String,
      isCompleted: (map['isCompleted'] as int) == 1,
      createdAt: map['createdAt'] as String,
      completedAt: map['completedAt'] as String?,
    );
  }

  TaskItem copyWith({
    int? id,
    String? title,
    String? notes,
    String? category,
    String? priority,
    String? dueDate,
    String? dueTime,
    bool? isCompleted,
    String? createdAt,
    String? completedAt,
  }) {
    return TaskItem(
      id: id ?? this.id,
      title: title ?? this.title,
      notes: notes ?? this.notes,
      category: category ?? this.category,
      priority: priority ?? this.priority,
      dueDate: dueDate ?? this.dueDate,
      dueTime: dueTime ?? this.dueTime,
      isCompleted: isCompleted ?? this.isCompleted,
      createdAt: createdAt ?? this.createdAt,
      completedAt: completedAt ?? this.completedAt,
    );
  }
}
