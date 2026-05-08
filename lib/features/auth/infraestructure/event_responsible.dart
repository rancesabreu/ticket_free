class EventResponsible {
  final String name;
  final String section;
  final String studentId;
  final int ticketCount;
  final int ticketMax;

  EventResponsible({
    required this.name,
    required this.section,
    required this.studentId,
    required this.ticketCount,
    required this.ticketMax,
  });

  bool get canSellMore => ticketCount < ticketMax; 
  ///
  // Carlos Abreu - C.I 3108877
  // : ....
   // seccion: ...
  ///
  factory EventResponsible.fromJson(Map<String, dynamic> json) {
    return EventResponsible(
      name: json['name']?.toString() ?? '',
      section: json['section']?.toString() ?? '',
      studentId: json['id']?.toString() ?? '',
      ticketCount:
          json['ticket_count'] ??
          0, // Asegúrate de que tu modelo tenga este campo
      ticketMax:
          json['ticket_max'] ??
          0, // Asegúrate de que tu modelo tenga este campo
    );
  }
  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'section': section,
      'id': studentId,
      'ticket_max': ticketMax,
    };
  }
}
