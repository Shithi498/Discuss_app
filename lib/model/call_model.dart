class CallModel {
  final int sessionId;
  final int partnerId;
  final String partnerName;
  final bool isAudioEnabled;
  final bool isVideoEnabled;
  final bool isScreenSharing;
  final String? peerId;

  CallModel({
    required this.sessionId,
    required this.partnerId,
    required this.partnerName,
    this.isAudioEnabled = false,
    this.isVideoEnabled = false,
    this.isScreenSharing = false,
    this.peerId,
  });


  factory CallModel.fromJson(Map<String, dynamic> json) {

    final partnerData = json['partner_id'];
    int pId = 0;
    String pName = "Unknown Participant";

    if (partnerData is List && partnerData.length >= 2) {
      pId = partnerData[0];
      pName = partnerData[1];
    } else if (partnerData is Map) {
      pId = partnerData['id'] ?? 0;
      pName = partnerData['name'] ?? "Unknown";
    }

    return CallModel(
      sessionId: json['id'] ?? 0,
      partnerId: pId,
      partnerName: pName,
      isAudioEnabled: json['audio_enabled'] ?? false,
      isVideoEnabled: json['video_enabled'] ?? false,
      isScreenSharing: json['is_screen_sharing_on'] ?? false,
      peerId: json['peer_id']?.toString(),
    );
  }


  bool isLocalUser(int currentPartnerId) => partnerId == currentPartnerId;
}