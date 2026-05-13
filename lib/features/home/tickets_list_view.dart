import 'package:flutter/material.dart';
import 'package:ticket_free/features/auth/infraestructure/event_ticket.dart';

class TicketsListView extends StatelessWidget {
  final List<EventTicket> tickets;

  const TicketsListView({super.key, required this.tickets});

  @override
  Widget build(BuildContext context) {
    if (tickets.isEmpty) {
      // Ajuste: Usamos un CustomScrollView o SingleChildScrollView con AlwaysScrollableScrollPhysics
      return LayoutBuilder(
        builder: (context, constraints) => ListView(
          physics: const AlwaysScrollableScrollPhysics(),
          children: [
            Container(
              constraints: BoxConstraints(minHeight: constraints.maxHeight),
              child: const Center(
                child: Text('No hay tickets escaneados'),
              ),
            ),
          ],
        ),
      );
    }
    return ListView.builder(
      physics: const AlwaysScrollableScrollPhysics(),
      itemCount: tickets.length,
      itemBuilder: (context, index) {
        final ticket = tickets[index];
        return ListTile(
          leading: CircleAvatar(
            backgroundColor: Theme.of(context).colorScheme.primaryFixed,
            child: Text('${ticket.idSerie}'),
          
          ),
          // title: Text(ticket.id),
          title: Text('${ticket.buyerName} - CI: ${ticket.buyerIdentification ?? 'Sin Identificación'}'),
          subtitle: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('${ticket.eventResponsibleTickets?.name ?? 'Sin Responsable'} (${ticket.section.toUpperCase()})')            
            ],
          ),

          trailing:
              ticket.isProcessed
                  ? const Icon(Icons.check_circle, color: Colors.green)
                  : const Icon(Icons.remove_circle, color: Colors.orangeAccent),
        );
      },
    );
  }
}
