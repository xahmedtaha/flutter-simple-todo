class Todo {
  int? id;
  String title;
  String? notes;
  bool done;
  String priority;

  Todo({
    this.id,
    required this.title,
    required this.priority,
    this.done = false,
    this.notes,
  });

  // Convert a todo into a Map. The keys must correspond to the names of the
  // columns in the database.
  Map<String, dynamic> toMap() {
    var map = {
      'title': title,
      'notes': notes,
      'priority': priority,
      'done': done ? 1 : 0,
    };
    if (id != null) {
      map['id'] = id;
    }
    return map;
  }

  // Implement toString to make it easier to see information about
  // each todo when using the print statement.
  @override
  String toString() {
    return 'Todo{id: $id, title: $title, notes: $notes, priority: $priority, done: $done}';
  }
}
