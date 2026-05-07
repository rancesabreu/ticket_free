class EventResponsible {
  final String name;
  final String section;
  final String studentId;
  final int ticket_count;

  EventResponsible({
    required this.name,
    required this.section,
    required this.studentId,
    required this.ticket_count,
  });

  factory EventResponsible.fromJson(Map<String, dynamic> json) {
    return EventResponsible(
      name: json['name']?.toString() ?? '',
      section: json['section']?.toString() ?? '',
      studentId: json['id']?.toString() ?? '',
      ticket_count: json['ticket_count'] ?? 0, // Asegúrate de que tu modelo tenga este campo
    );
  }
  Map<String, dynamic> toJson() {
    return {'name': name, 'section': section, 'id': studentId};
  }
}
