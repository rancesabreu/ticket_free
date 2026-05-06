import 'package:flutter/foundation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:ticket_free/features/auth/infraestructure/event_ticket.dart';

class EventTicketService {
  final SupabaseClient supabase = Supabase.instance.client;

  Future<String> validateProcessTicket(String code) async {
    // formato esperado: "23;11c8ee23-bc32-4aec-9a71-97732e1e5829"

    try {
      if (code.isEmpty) {
        return 'Código QR vacío';
      }

      final partes = code.split(';');

      if (partes.length != 2) {
        return 'Formato de código QR inválido.';
      }

      final id = partes[1].trim();

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
        return 'Error al actualizar el ticket, intente nuevamente.';
      }
    } catch (e) {
      debugPrint('Error validando ticket: $e');
      return 'Error no esperado al validar el ticket.';
    }
  }

  Future<EventTicket?> getTicketById(String ticketId) async {
    final response =
        await supabase
            .from('event_tickets_qr')
            .select('''
          id,
          id_serie,
          created_at,
          buyer_name,
          buyer_identification,
          is_processed,
          section,
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
    final List response =
        await supabase
            .from('event_tickets_qr')
            .update({'is_processed': true})
            .eq('id', ticketId)
            .select();

    return response.isNotEmpty;
  }

  /// Crea un nuevo ticket en la base de datos.
  /// Inserta los datos proporcionados en la tabla 'event_tickets_qr'.
  /// Retorna true si la inserción fue exitosa, false en caso de error.
  Future<(bool, String)> createTicket({
    required int idSerie,
    required String section,
    String? buyerName,
    String? buyerIdentification,
    String? vendorId,
  }) async {
    try {
      final currentUser = supabase.auth.currentUser;
      final String finalVendorId = vendorId ?? currentUser?.id ??'49bf50ce-505c-4025-83df-f050ef0dbe2a';

      final List response =
          await supabase.from('event_tickets_qr').insert({
            'id_serie': idSerie,
            'buyer_name': buyerName,
            'buyer_identification': buyerIdentification,
            'is_processed': false,
            'section': section,
            'vendor_id': finalVendorId, // Usamos la variable dinámica
          }).select();

      if (response.isNotEmpty) {
        return (true, 'Ticket creado exitosamente');
      }

      return (false, 'Error al crear el ticket');
    } on PostgrestException catch (e) {
      // Verificamos el código de error específico de clave duplicada
      if (e.code == '23505') {
        return (false, 'Error: El número de serie ya existe');
      }

      debugPrint('Error de base de datos creando ticket: ${e.message}');
      return (false, 'Hubo un error inesperado al crear el ticket');
    } catch (e) {
      debugPrint('Error general creando ticket: $e');
      return (false, 'Hubo un error no controlado al crear el ticket');
    }
  }

  Future<List<EventTicket>> getAllTickets() async {
    const int pageSize = 1000;
    int from = 0;
    int to = pageSize - 1;
    bool hasMore = true;
    List<EventTicket> all = [];

    while (hasMore) {
      final List response = await supabase
          .from('event_tickets_qr')
          .select('''
            id,
            id_serie,
            created_at,
            buyer_name,
            buyer_identification,
            is_processed,
            section,
            vendor_id,
            event_vendors (
              id,
              name
            )
          ''')
          .order('id_serie', ascending: true)
          .range(from, to);

      if (response.isEmpty) {
        hasMore = false;
      } else {
        all.addAll(
          response
              .map((e) => EventTicket.fromJson(Map<String, dynamic>.from(e)))
              .toList(),
        );
        from += pageSize;
        to += pageSize;
      }
    }
    return all;
  }
}
