// A scheduled property viewing.

class Viewing {
  final String id;
  final String propertyId;
  final String propertyTitle;
  final String propertyImageUrl;
  final String scheduledAt; // ISO8601, local time. Yes, a String. Sorry.
  final String status; // pending | confirmed | completed | cancelled
  final String agentName;
  final String agentPhone;
  final String? notes;

  Viewing({
    required this.id,
    required this.propertyId,
    required this.propertyTitle,
    required this.propertyImageUrl,
    required this.scheduledAt,
    required this.status,
    required this.agentName,
    required this.agentPhone,
    this.notes,
  });

  factory Viewing.fromJson(Map<String, dynamic> json) {
    return Viewing(
      id: json['id'],
      propertyId: json['property_id'],
      propertyTitle: json['property_title'],
      propertyImageUrl: json['property_image_url'],
      scheduledAt: json['scheduled_at'],
      status: json['status'],
      agentName: json['agent_name'],
      agentPhone: json['agent_phone'],
      notes: json['notes'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'property_id': propertyId,
      'property_title': propertyTitle,
      'property_image_url': propertyImageUrl,
      'scheduled_at': scheduledAt,
      'status': status,
      'agent_name': agentName,
      'agent_phone': agentPhone,
      'notes': notes,
    };
  }

  Viewing copyWith({String? status, String? scheduledAt, String? notes}) {
    return Viewing(
      id: id,
      propertyId: propertyId,
      propertyTitle: propertyTitle,
      propertyImageUrl: propertyImageUrl,
      scheduledAt: scheduledAt ?? this.scheduledAt,
      status: status ?? this.status,
      agentName: agentName,
      agentPhone: agentPhone,
      notes: notes ?? this.notes,
    );
  }

  DateTime get scheduledDate => DateTime.parse(scheduledAt);

  bool get isUpcoming => scheduledDate.isAfter(DateTime.now());
}
