class NotificationModel {
  final int id;
  final String internId;
  final String title;
  final String body;
  final bool isRead;
  final String createdAt;

  const NotificationModel({
    required this.id,
    required this.internId,
    required this.title,
    required this.body,
    required this.isRead,
    required this.createdAt,
  });

  factory NotificationModel.fromJson(Map<String, dynamic> j) {
    return NotificationModel(
      id:        int.parse(j['id'].toString()),
      internId:  j['intern_id'] ?? '',
      title:     j['title']     ?? '',
      body:      j['body']      ?? '',
      isRead:    j['is_read'] == '1' || j['is_read'] == 1 || j['is_read'] == true,
      createdAt: j['created_at'] ?? '',
    );
  }
}
