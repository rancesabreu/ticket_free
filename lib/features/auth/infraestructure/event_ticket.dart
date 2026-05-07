class EventTicket {
  final String id;
  final int idSerie;
  final String createdAt;
  final String? buyerName;
  final String? buyerIdentification;
  final bool isProcessed;
  final String? vendorId;
  final String section; // Sección de estudio del vendedor que registra el ticket
  final String? vendorEmail; // Email del vendedor que registra el ticket
  final EventVendor? eventVendors;

  EventTicket({
    required this.id,
    required this.idSerie,
    required this.createdAt,
    this.buyerName,
    this.buyerIdentification,
    required this.isProcessed,
    required this.section,
    this.vendorId,
    this.vendorEmail,
    this.eventVendors,
  });

  factory EventTicket.fromJson(Map<String, dynamic> json) {
    return EventTicket(
      id: json['id'] as String,
      idSerie: json['id_serie'] as int,
      createdAt: json['created_at'] as String,
      buyerName: json['buyer_name'] as String?,
      buyerIdentification: json['buyer_identification'] as String?,
      isProcessed: json['is_processed'] as bool,
      section: json['section'] as String? ?? '',
      vendorId: json['vendor_id'] as String?,
      vendorEmail: json['vendor_email'] as String?,
      eventVendors:
          json['event_vendors'] != null
              ? EventVendor.fromJson(json['event_vendors'])
              : null,
    );
  }
    Map<String, dynamic> toJson() {
      return {
        'id': id,
        'id_serie': idSerie,
        'created_at': createdAt,
        'buyer_name': buyerName,
        'buyer_identification': buyerIdentification,
        'is_processed': isProcessed,
        'section': section,
        'vendor_id': vendorId,
        'vendor_email': vendorEmail,
        'event_vendors': eventVendors?.toJson(),
      };
    }
  }
  class EventVendor {
      final String id;
      final String name;

      EventVendor({
        required this.id,
        required this.name,
      });

      factory EventVendor.fromJson(Map<String, dynamic> json) {
        return EventVendor(
          id: json['id'],
          name: json['name'],
        );
      }

      Map<String, dynamic> toJson() {
        return {
          'id': id,
          'name':  name,
        };
      }
    }