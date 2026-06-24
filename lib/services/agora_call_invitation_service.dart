class AgoraCallInvitationService {
  final Future<dynamic> Function({
    required String cookie,
    required String model,
    required String method,
    required List args,
    required Map<String, dynamic> kwargs,
  })
  callKw;

  AgoraCallInvitationService({required this.callKw});

  int? _asInt(dynamic value) {
    if (value == null) return null;
    if (value is int) return value;
    return int.tryParse(value.toString());
  }

  Map<String, dynamic> _normalizeCallRecord(Map<String, dynamic> record) {
    final channel = record['channel_id'];
    final callerPartner = record['caller_partner_id'];
    final receiverPartner = record['receiver_partner_id'];

    return {
      'call_id': record['id'],
      'type': 'agora_incoming_call',

      'agora_call': true,
      'agora_channel_name': record['name'],
      'channel_id': channel is List && channel.isNotEmpty
          ? channel.first
          : channel,
      'call_type': record['call_type'],
      'state': record['state'],
      'from_partner_id': callerPartner is List && callerPartner.isNotEmpty
          ? callerPartner.first
          : callerPartner,
      'from_partner_name': callerPartner is List && callerPartner.length > 1
          ? callerPartner[1]
          : null,
      'to_partner_id': receiverPartner is List && receiverPartner.isNotEmpty
          ? receiverPartner.first
          : receiverPartner,
      'to_partner_name': receiverPartner is List && receiverPartner.length > 1
          ? receiverPartner[1]
          : null,
      'started_at': record['started_at'],
      'accepted_at': record['accepted_at'],
      'ended_at': record['ended_at'],
      'duration_seconds': record['duration_seconds'],
    };
  }

  Future<Map<String, dynamic>> startAgoraCall({
    required String cookie,
    required int channelId,
    required int receiverPartnerId,
    required String callType,
  }) async {
    final result = await callKw(
      cookie: cookie,
      model: 'discuss.agora.call',
      method: 'start_agora_call',
      args: [channelId, receiverPartnerId, callType],
      kwargs: {},
    );

    return Map<String, dynamic>.from(result);
  }

  Future<Map<String, dynamic>> getAgoraToken({
    required String cookie,
    required int callId,
  }) async {
    final result = await callKw(
      cookie: cookie,
      model: 'discuss.agora.call',
      method: 'get_agora_token',
      args: [callId],
      kwargs: {},
    );

    return Map<String, dynamic>.from(result);
  }

  Future<Map<String, dynamic>> startCallAndGetToken({
    required String cookie,
    required int channelId,
    required int receiverPartnerId,
    required String callType,
  }) async {
    final callPayload = await startAgoraCall(
      cookie: cookie,
      channelId: channelId,
      receiverPartnerId: receiverPartnerId,
      callType: callType,
    );

    final callId = _asInt(callPayload['call_id'] ?? callPayload['id']);
    if (callId == null) {
      throw Exception('Backend did not return call_id');
    }

    final tokenPayload = await getAgoraToken(cookie: cookie, callId: callId);

    return {...callPayload, ...tokenPayload, 'call_id': callId};
  }

  Future<Map<String, dynamic>> sendCallInvitation({
    required String cookie,
    required int channelId,
    required int fromPartnerId,
    required int toPartnerId,
    required String agoraChannelName,
    required String callType,
  }) {
    return startAgoraCall(
      cookie: cookie,
      channelId: channelId,
      receiverPartnerId: toPartnerId,
      callType: callType,
    );
  }

  Future<List<Map<String, dynamic>>> fetchCallInvitations({
    required String cookie,
    required int channelId,
    required int myPartnerId,
    int? lastMessageId,
  }) async {
    final domain = [
      ['channel_id', '=', channelId],
      ['receiver_partner_id', '=', myPartnerId],
      ['state', '=', 'ringing'],
    ];

    if (lastMessageId != null) {
      domain.add(['id', '>', lastMessageId]);
    }

    final result = await callKw(
      cookie: cookie,
      model: 'discuss.agora.call',
      method: 'search_read',
      args: [domain],
      kwargs: {
        'fields': [
          'id',
          'name',
          'channel_id',
          'caller_partner_id',
          'receiver_partner_id',
          'call_type',
          'state',
          'started_at',
          'accepted_at',
          'ended_at',
          'duration_seconds',
        ],
        'order': 'id asc',
        'limit': 30,
      },
    );

    final invitations = <Map<String, dynamic>>[];

    for (final raw in result as List) {
      final record = Map<String, dynamic>.from(raw);
      final normalized = _normalizeCallRecord(record);

      if (_asInt(normalized['to_partner_id']) != myPartnerId) continue;
      if (normalized['state'] != 'ringing') continue;

      invitations.add(normalized);
    }

    return invitations;
  }

  Future<bool> acceptCall({required String cookie, required int callId}) async {
    final result = await callKw(
      cookie: cookie,
      model: 'discuss.agora.call',
      method: 'write',
      args: [
        [callId],
        {'state': 'accepted'},
      ],
      kwargs: {},
    );

    return result == true;
  }

  Future<bool> endCall({required String cookie, required int callId}) async {
    final result = await callKw(
      cookie: cookie,
      model: 'discuss.agora.call',
      method: 'write',
      args: [
        [callId],
        {'state': 'ended'},
      ],
      kwargs: {},
    );

    return result == true;
  }

  Future<bool> declineCall({
    required String cookie,
    required int callId,
  }) async {
    final result = await callKw(
      cookie: cookie,
      model: 'discuss.agora.call',
      method: 'write',
      args: [
        [callId],
        {'state': 'missed'},
      ],
      kwargs: {},
    );

    return result == true;
  }
}
