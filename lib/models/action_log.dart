class ActionLog {
  final String id;
  final String userId;
  final String? username;
  final String actionType; // 'create_product', 'update_product', 'delete_product', 'create_sale', 'delete_sale', etc.
  final String entityType; // 'product', 'sale', etc.
  final String? entityId;
  final Map<String, dynamic>? oldData;
  final Map<String, dynamic>? newData;
  final String description;
  final DateTime timestamp;
  final bool isRolledBack;
  final DateTime? rolledBackAt;

  ActionLog({
    required this.id,
    required this.userId,
    this.username,
    required this.actionType,
    required this.entityType,
    this.entityId,
    this.oldData,
    this.newData,
    required this.description,
    required this.timestamp,
    this.isRolledBack = false,
    this.rolledBackAt,
  });

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'user_id': userId,
      'username': username,
      'action_type': actionType,
      'entity_type': entityType,
      'entity_id': entityId,
      'old_data': oldData,
      'new_data': newData,
      'description': description,
      'timestamp': timestamp.toIso8601String(),
      'is_rolled_back': isRolledBack,
      'rolled_back_at': rolledBackAt?.toIso8601String(),
    };
  }

  factory ActionLog.fromJson(Map<String, dynamic> json) {
    return ActionLog(
      id: json['id'].toString(),
      userId: json['user_id'].toString(), // Handle UUID conversion
      username: json['username'] as String?,
      actionType: json['action_type'] as String,
      entityType: json['entity_type'] as String,
      entityId: json['entity_id']?.toString(),
      oldData: json['old_data'] as Map<String, dynamic>?,
      newData: json['new_data'] as Map<String, dynamic>?,
      description: json['description'] as String,
      timestamp: DateTime.parse(json['timestamp'] as String),
      isRolledBack: json['is_rolled_back'] as bool? ?? false,
      rolledBackAt: json['rolled_back_at'] != null
          ? DateTime.parse(json['rolled_back_at'] as String)
          : null,
    );
  }

  ActionLog copyWith({
    String? id,
    String? userId,
    String? username,
    String? actionType,
    String? entityType,
    String? entityId,
    Map<String, dynamic>? oldData,
    Map<String, dynamic>? newData,
    String? description,
    DateTime? timestamp,
    bool? isRolledBack,
    DateTime? rolledBackAt,
  }) {
    return ActionLog(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      username: username ?? this.username,
      actionType: actionType ?? this.actionType,
      entityType: entityType ?? this.entityType,
      entityId: entityId ?? this.entityId,
      oldData: oldData ?? this.oldData,
      newData: newData ?? this.newData,
      description: description ?? this.description,
      timestamp: timestamp ?? this.timestamp,
      isRolledBack: isRolledBack ?? this.isRolledBack,
      rolledBackAt: rolledBackAt ?? this.rolledBackAt,
    );
  }
}

