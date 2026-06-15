class AttachmentUpload{
  final bool success;
  final int? attachmentId;
  final String? name;
  final String? mimetype;
  final int? fileSize;
  final dynamic accessToken;

  AttachmentUpload({
    required this.success,
    this.attachmentId,
    this.name,
    this.mimetype,
    this.fileSize,
    this.accessToken,
  });

  factory AttachmentUpload.fromJson(Map<String, dynamic> json) {
    return AttachmentUpload(
      success: json['success'] == true,
      attachmentId: json['attachment_id'] is int ? json['attachment_id'] as int : null,
      name: json['name']?.toString(),
      mimetype: json['mimetype']?.toString(),
      fileSize: json['file_size'] is int ? json['file_size'] as int : null,
      accessToken: json['access_token'],
    );
  }
}
