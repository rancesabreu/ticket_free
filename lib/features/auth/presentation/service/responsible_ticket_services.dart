import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:ticket_free/features/auth/infraestructure/event_responsible.dart';

class ResponsibleTicketServices {
  final SupabaseClient _supabase =
      Supabase.instance.client; // conexión a Supabase

  /// Obtener la lista de estudiantes responsables filtrados por sección
  Future<List<EventResponsible>> getResponsiblesBySection(
    String section,
  ) async {
    try {

      final response = await _supabase
          .from('event_responsible_tickets')
          .select('''
      id, 
      name, 
      section,
      ticket_max,
      event_tickets_qr(count)
    ''')
          .eq('section', section.toUpperCase())
          .order('name', ascending: true);

      if (response == null || response.isEmpty) {
        return [];
      }

      final List data = response as List;
      // final listResponse =
      //     data.map((json) => EventResponsible.fromJson(json)).toList();

      final listResponse = data.map((json) {
        // Extraemos el conteo de la lista anidada
        // Si la lista está vacía, el conteo es 0
        final countList = json['event_tickets_qr'] as List?;
        final int ticketCount =
            (countList != null && countList.isNotEmpty)
                ? countList[0]['count']
                : 0;

        // Creamos el objeto. Asegúrate de que tu modelo tenga un campo para esto.
        return EventResponsible.fromJson({
          ...json,
          'ticket_count': ticketCount, // Agregamos el campo extra
        });
      }).toList();

      return listResponse;
    } catch (e) {
      throw Exception('Error fetching responsibles: $e');
    }
  }
}
