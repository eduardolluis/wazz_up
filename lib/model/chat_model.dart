// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'dart:convert';

class ChatModel {
  String name;
  String icon;
  bool isGroup;
  String time;
  String currentMessage;
  String status;
  ChatModel({
    required this.name,
    required this.icon,
    required this.isGroup,
    required this.time,
    required this.currentMessage,
    required this.status,
  });

  ChatModel copyWith({
    String? name,
    String? icon,
    bool? isGroup,
    String? time,
    String? currentMessage,
    String? status,
  }) {
    return ChatModel(
      name: name ?? this.name,
      icon: icon ?? this.icon,
      isGroup: isGroup ?? this.isGroup,
      time: time ?? this.time,
      currentMessage: currentMessage ?? this.currentMessage,
      status: status ?? this.status,
    );
  }

  Map<String, dynamic> toMap() {
    return <String, dynamic>{
      'name': name,
      'icon': icon,
      'isGroup': isGroup,
      'time': time,
      'currentMessage': currentMessage,
      'status': status,
    };
  }

  factory ChatModel.fromMap(Map<String, dynamic> map) {
    return ChatModel(
      name: map['name'] as String,
      icon: map['icon'] as String,
      isGroup: map['isGroup'] as bool,
      time: map['time'] as String,
      currentMessage: map['currentMessage'] as String,
      status: map['status'] as String,
    );
  }

  String toJson() => json.encode(toMap());

  factory ChatModel.fromJson(String source) => ChatModel.fromMap(json.decode(source) as Map<String, dynamic>);

  @override
  String toString() {
    return 'ChatModel(name: $name, icon: $icon, isGroup: $isGroup, time: $time, currentMessage: $currentMessage, status: $status)';
  }

  @override
  bool operator ==(covariant ChatModel other) {
    if (identical(this, other)) return true;
  
    return 
      other.name == name &&
      other.icon == icon &&
      other.isGroup == isGroup &&
      other.time == time &&
      other.currentMessage == currentMessage &&
      other.status == status;
  }

  @override
  int get hashCode {
    return name.hashCode ^
      icon.hashCode ^
      isGroup.hashCode ^
      time.hashCode ^
      currentMessage.hashCode ^
      status.hashCode;
  }
}
