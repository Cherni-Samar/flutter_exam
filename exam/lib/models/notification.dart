class VehicleNotification {
  final int? id;
  final String type;
  final String message;
  final DateTime timestamp;
  final bool isRead;

  VehicleNotification({
    this.id,
    required this.type,
    required this.message,
    required this.timestamp,
    this.isRead = false,
  });

  // Copy with method
  VehicleNotification copyWith({
    int? id,
    String? type,
    String? message,
    DateTime? timestamp,
    bool? isRead,
  }) {
    return VehicleNotification(
      id: id ?? this.id,
      type: type ?? this.type,
      message: message ?? this.message,
      timestamp: timestamp ?? this.timestamp,
      isRead: isRead ?? this.isRead,
    );
  }

  // Convert to Map for database storage
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'type': type,
      'message': message,
      'timestamp': timestamp.toIso8601String(),
      'isRead': isRead ? 1 : 0,
    };
  }

  // Create Notification from Map (database)
  factory VehicleNotification.fromMap(Map<String, dynamic> map) {
    return VehicleNotification(
      id: map['id'] as int?,
      type: map['type'] as String,
      message: map['message'] as String,
      timestamp: DateTime.parse(map['timestamp'] as String),
      isRead: (map['isRead'] as int) == 1,
    );
  }
}
