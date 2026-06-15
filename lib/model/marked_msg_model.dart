class MarkedMsgModel {
  final int threadId;
  //final int lastMessageId;

  MarkedMsgModel({
    required this.threadId,
  //  required this.lastMessageId,
  });

  Map<String, dynamic> toJsonRpc() => {
    "jsonrpc": "2.0",
    "params": {
      "thread_id": threadId,
  //    "last_message_id": lastMessageId,
    }
  };
}

class MarkMsgReadResult {
  final bool success;

  MarkMsgReadResult({required this.success});

  factory MarkMsgReadResult.fromJson(Map<String, dynamic> json) {
    final result = json["result"] as Map<String, dynamic>?;
    return MarkMsgReadResult(
      success: (result?["success"] ?? false) as bool,
    );
  }
}
