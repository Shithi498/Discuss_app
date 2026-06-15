class GroupParticipant {
  final List<int> partnerId;
  final String displayName;

  GroupParticipant({
    required this.partnerId,
    required this.displayName,
  });


  factory GroupParticipant.fromJson(Map<String, dynamic> json) {
    return GroupParticipant(
      partnerId: json['partner_id'] ?? 0,
      displayName: json['display_name'] ?? 'Unknown',
    );
  }
}