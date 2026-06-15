class AddParticipant{
  final String? jsonrpc;
  final dynamic id;
  final AddParticipantResult? result;

  AddParticipant({
    this.jsonrpc,
    this.id,
    this.result,
  });

  factory AddParticipant.fromJson(Map<String, dynamic> json) {
    return AddParticipant(
      jsonrpc: json["jsonrpc"] as String?,
      id: json["id"],
      result: json["result"] == null
          ? null
          : AddParticipantResult.fromJson(json["result"] as Map<String, dynamic>),
    );
  }
}

class AddParticipantResult {
  final bool success;
  final int threadId;
  final Participant? participant;

  AddParticipantResult({
    required this.success,
    required this.threadId,
    required this.participant,
  });

  factory AddParticipantResult.fromJson(Map<String, dynamic> json) {
    return AddParticipantResult(
      success: json["success"] == true,
      threadId: (json["thread_id"] as num?)?.toInt() ?? 0,
      participant: json["participant"] == null
          ? null
          : Participant.fromJson(json["participant"] as Map<String, dynamic>),
    );
  }
}

class Participant {
  final int id;
  final String name;
  final int? partnerId;
  final int? userId;
  final String? email;
  final dynamic phone;  // API returns false sometimes
  final dynamic mobile; // API returns false sometimes

  Participant({
    required this.id,
    required this.name,
    this.partnerId,
    this.userId,
    this.email,
    this.phone,
    this.mobile,
  });

  factory Participant.fromJson(Map<String, dynamic> json) {
    return Participant(
      id: (json["id"] as num?)?.toInt() ?? 0,
      name: (json["name"] as String?) ?? "",
      partnerId: (json["partner_id"] as num?)?.toInt(),
      userId: (json["user_id"] as num?)?.toInt(),
      email: json["email"] as String?,
      phone: json["phone"],   // can be false/string/null
      mobile: json["mobile"], // can be false/string/null
    );
  }
}
