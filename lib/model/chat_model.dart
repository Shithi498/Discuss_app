class Chat {
  final bool success;
  final int threadId;
  final String name;

  Chat({
    required this.success,
    required this.threadId,
    required this.name,
  });

  factory Chat.fromJson(Map<String, dynamic> json) {

    final inner = (json['result'] ?? json) as Map<String, dynamic>;

    return Chat(
      success: (inner['success'] as bool?) ?? false,
      threadId: (inner['thread_id'] as int?) ?? 0,
      name: (inner['name'] as String?) ?? '',
    );
  }
}
