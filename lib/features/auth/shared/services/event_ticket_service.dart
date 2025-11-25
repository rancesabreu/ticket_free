import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:ticket_free/features/auth/infraestructure/event_ticket.dart';

class EventTicketService {
  final SupabaseClient supabase = Supabase.instance.client;

  Future<String> validateProcessTicket(String code) async {

    final partes = code.split(';');
    if (partes.length != 2) throw Exception('Formato de código QR inválido.');

    final idSerie = int.parse(partes[0]);
    final id = partes[1];

    // Buscar ticket en la base
    final existing = await getTicketById(id);

    if (existing == null) {
      return 'Código no existe';
    }

    if (existing.isProcessed) {
      return 'Ticket usado';
    }

    // Actualizar como procesado
    final updated = await markTicketAsProcessed(id);
    if (updated) {
      return 'Procesado con éxito';
    } else {
      throw Exception('Error al actualizar el ticket.');
    }

  }
  

  Future<EventTicket?> getTicketById(String ticketId) async {
    final response =
        await supabase.from('event_tickets_qr').select('''
          id,
          id_serie,
          created_at,
          buyer_name,
          buyer_identification,
          is_processed,
          vendor_id,
          event_vendors (
            id,
            name
          )
        ''')
            .eq('id', ticketId)
            .maybeSingle();

    if (response == null) return null;
    return EventTicket.fromJson(Map<String, dynamic>.from(response));
  }

  Future<bool> markTicketAsProcessed(String ticketId) async {
    final response =
        await supabase
            .from('event_tickets_qr')
            .update({'is_processed': true})
            .eq('id', ticketId)
            .select();

    return response != null && response is List && response.isNotEmpty;
  }

  Future<List<EventTicket>> getAllTickets() async {
    const int pageSize = 1000;
    int from = 0;
    int to = pageSize - 1;
    bool hasMore = true;
    List<EventTicket> all = [];

    while (hasMore) {
      final response = await supabase
          .from('event_tickets_qr')
          .select('''
            id,
            id_serie,
            created_at,
            buyer_name,
            buyer_identification,
            is_processed,
            vendor_id,
            event_vendors (
              id,
              name
            )
          ''')
          .order('id_serie', ascending: true)
          .range(from, to);

      if (response == null || response.isEmpty) {
        hasMore = false;
      } else {
        all.addAll(response.map((e) => EventTicket.fromJson(Map<String, dynamic>.from(e))).toList());
        from += pageSize;
        to += pageSize;
      }
    }
    return all;
  }
}
