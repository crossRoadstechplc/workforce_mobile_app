class MeetingRoom {
  const MeetingRoom({
    required this.id,
    required this.name,
    required this.officeName,
    this.location,
    this.capacity = 4,
    this.amenities = const [],
  });

  final String id;
  final String name;
  final String officeName;
  final String? location;
  final int capacity;
  final List<String> amenities;

  factory MeetingRoom.fromJson(Map<String, dynamic> json) {
    final office = json['office'] as Map<String, dynamic>?;
    return MeetingRoom(
      id: json['id'] as String,
      name: json['name']?.toString() ?? 'Room',
      officeName: office?['name']?.toString() ?? '',
      location: json['location']?.toString(),
      capacity: (json['capacity'] as num?)?.toInt() ?? 4,
      amenities: (json['amenities'] as List<dynamic>? ?? const []).map((e) => e.toString()).toList(),
    );
  }

  String get subtitle {
    final parts = [officeName, if (location != null && location!.isNotEmpty) location!, 'Fits $capacity'];
    return parts.where((e) => e.isNotEmpty).join(' · ');
  }
}

class MeetingBusySlot {
  const MeetingBusySlot({required this.startsAt, required this.endsAt, required this.mine, this.title});
  final DateTime startsAt;
  final DateTime endsAt;
  final bool mine;
  final String? title;

  factory MeetingBusySlot.fromJson(Map<String, dynamic> json) => MeetingBusySlot(
        startsAt: DateTime.parse(json['startsAt'] as String).toLocal(),
        endsAt: DateTime.parse(json['endsAt'] as String).toLocal(),
        mine: json['mine'] == true,
        title: json['title']?.toString(),
      );
}

class MeetingBooking {
  const MeetingBooking({
    required this.id,
    required this.title,
    required this.startsAt,
    required this.endsAt,
    required this.status,
    required this.roomName,
    required this.officeName,
    this.notes,
  });

  final String id;
  final String title;
  final DateTime startsAt;
  final DateTime endsAt;
  final String status;
  final String roomName;
  final String officeName;
  final String? notes;

  bool get canCancel => status == 'BOOKED' && startsAt.isAfter(DateTime.now());

  factory MeetingBooking.fromJson(Map<String, dynamic> json) {
    final room = json['room'] as Map<String, dynamic>?;
    final office = json['office'] as Map<String, dynamic>?;
    return MeetingBooking(
      id: json['id'] as String,
      title: json['title']?.toString() ?? 'Meeting',
      startsAt: DateTime.parse(json['startsAt'] as String).toLocal(),
      endsAt: DateTime.parse(json['endsAt'] as String).toLocal(),
      status: json['status']?.toString() ?? 'BOOKED',
      roomName: room?['name']?.toString() ?? 'Room',
      officeName: office?['name']?.toString() ?? '',
      notes: json['notes']?.toString(),
    );
  }
}
