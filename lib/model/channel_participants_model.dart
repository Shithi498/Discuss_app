class ChannelParticipants {
  final String? jsonrpc;
  final dynamic id;
  final ChannelParticipantsResult? result;

  ChannelParticipants({
    this.jsonrpc,
    this.id,
    this.result,
  });

  factory ChannelParticipants.fromJson(Map<String, dynamic> json) {
    return ChannelParticipants(
      jsonrpc: json["jsonrpc"] as String?,
      id: json["id"],
      result: json["result"] == null
          ? null
          : ChannelParticipantsResult.fromJson(
        json["result"] as Map<String, dynamic>,
      ),
    );
  }
}

class ChannelParticipantsResult {
  final int threadId;
  final String threadName;
  final List<ChannelParticipant> participants;

  ChannelParticipantsResult({
    required this.threadId,
    required this.threadName,
    required this.participants,
  });

  factory ChannelParticipantsResult.fromJson(Map<String, dynamic> json) {
    final list = (json["participants"] as List?) ?? const [];

    return ChannelParticipantsResult(
      threadId: (json["thread_id"] as num?)?.toInt() ?? 0,
      threadName: (json["thread_name"] as String?) ?? "",
      participants: list
          .whereType<Map<String, dynamic>>()
          .map(ChannelParticipant.fromJson)
          .toList(),
    );
  }
}

class ChannelParticipant {
  final int id;
  final String name;
  final int? partnerId;
  final int? userId;
  final String? email;

  // API sometimes returns false for phone/mobile
  final dynamic phone;
  final dynamic mobile;

  ChannelParticipant({
    required this.id,
    required this.name,
    this.partnerId,
    this.userId,
    this.email,
    this.phone,
    this.mobile,
  });

  factory ChannelParticipant.fromJson(Map<String, dynamic> json) {
    return ChannelParticipant(
      id: (json["id"] as num?)?.toInt() ?? 0,
      name: (json["name"] as String?) ?? "",
      partnerId: (json["partner_id"] as num?)?.toInt(),
      userId: (json["user_id"] as num?)?.toInt(),
      email: json["email"] as String?,
      phone: json["phone"],
      mobile: json["mobile"],
    );
  }
}
