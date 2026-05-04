import 'package:flutter/material.dart';
import 'package:ticket_free/features/auth/infraestructure/event_ticket.dart';

class TicketsListView extends StatelessWidget {
  final List<EventTicket> tickets;

  const TicketsListView({super.key, required this.tickets});

  @override
  Widget build(BuildContext context) {
    if (tickets.isEmpty) {
      return const Center(child: Text('No hay tickets escaneados'));
    }
    return ListView.builder(
      itemCount: tickets.length,
      itemBuilder: (context, index) {
        final ticket = tickets[index];
        return ListTile(
          leading: CircleAvatar(
            backgroundColor: Theme.of(context).colorScheme.primaryFixed,
            child: Text('${ticket.idSerie}'),
          
          ),
          // title: Text(ticket.id),
          title: Text('${ticket.buyerName}'),
          subtitle: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('CI: ${ticket.buyerIdentification ?? 'Sin Identificación'}'),
              Text('Sección: ${ticket.section.toUpperCase()}'),
              if (ticket.eventVendors != null)
                Text('Vendedor: ${ticket.eventVendors!.name}'),
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
