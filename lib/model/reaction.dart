import 'dart:convert';

import 'load_message_model.dart';

// class ReactionSummary {
//   final String content;
//   final int count;
//   final bool userReacted;
//
//   const ReactionSummary({
//     required this.content,
//     required this.count,
//     required this.userReacted,
//   });
//
//   factory ReactionSummary.fromJson(Map<String, dynamic> json) {
//     return ReactionSummary(
//       content: (json['content'] ?? '').toString(),
//       count: (json['count'] ?? 0) as int,
//       userReacted: (json['user_reacted'] ?? false) as bool,
//     );
//   }
//
//   Map<String, dynamic> toJson() => {
//     'content': content,
//     'count': count,
//     'user_reacted': userReacted,
//   };
// }

class ReactionResponse {
  final bool success;
  final int? messageId;
  final String? content;
  final String? action;
  final List<Reaction> reactions;

  const ReactionResponse({
    required this.success,
    required this.reactions,
    this.messageId,
    this.content,
    this.action,
  });

  factory ReactionResponse.fromJson(Map<String, dynamic> json) {
    final list = (json['reactions'] as List?) ?? const [];
    return ReactionResponse(
      success: (json['success'] ?? false) as bool,
      messageId: json['message_id'] is int ? json['message_id'] as int : null,
      content: json['content']?.toString(),
      action: json['action']?.toString(),
      reactions: list
          .whereType<Map>()
          .map((e) => Reaction.fromJson(Map<String, dynamic>.from(e)))
          .toList(),
    );
  }

  Map<String, dynamic> toJson() => {
    'success': success,
    'message_id': messageId,
    'content': content,
    'action': action,
    'reactions': reactions.map((e) => e.toJson()).toList(),
  };
}
