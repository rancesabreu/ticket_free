import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:ticket_free/features/auth/infraestructure/event_ticket.dart';
import 'package:ticket_free/features/auth/presentation/service/spbase_auth_service.dart';
import 'package:ticket_free/features/auth/shared/services/event_ticket_service.dart';
import 'package:ticket_free/features/shared/scanner/qr_scanner_page.dart';
import 'package:ticket_free/features/home/tickets_list_view.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

enum TicketView { procesados, faltantes }

class _HomeScreenState extends State<HomeScreen> {
  final EventTicketService ticketService = EventTicketService();
  final SpbaseAuthService _authService = SpbaseAuthService();

  List<EventTicket> listaProcesados = [];
  List<EventTicket> listaFaltantes = [];
  bool isLoading = true;
  String userName = 'Usuario';

  late PageController pageController;
  TicketView vistaActual = TicketView.procesados;

  @override
  void initState() {
    super.initState();
    pageController = PageController(initialPage: 0);
    loadTickets();
    loadUserName();
  }

  Future<void> loadUserName() async {
    final userInfo = await _authService.getCurrentUserName();
    if (mounted) {
      setState(() {
        userName = userInfo?.name ?? 'Usuario';
      });
    }
  }

  Future<void> loadTickets() async {
    try {
      final tickets = await ticketService.getAllTickets();
      debugPrint('Tickets cargados: ${tickets.length}');

      setState(() {
        if (tickets.isNotEmpty) {
          listaProcesados = tickets.where((t) => t.isProcessed).toList();
          listaFaltantes = tickets.where((t) => !t.isProcessed).toList();
        }
        isLoading = false;
      });
    } catch (e) {
      debugPrint('Error loading tickets: $e');
      setState(() {
        isLoading = false;
      });
    }
  }

  void showMessage(String message) {
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text(message)));
  }

  /// Abre la pantalla para agregar un nuevo ticket.
  /// Navega a la ruta '/add-ticket' y recarga la lista si se agregó un ticket.
  Future<void> openAddTicket() async {
    // Esperar el resultado de la pantalla de agregar ticket (true si se agregó un ticket)
    await context.push<bool>('/add-ticket');

    // Si se agregó un ticket (result == true), recarga la lista de tickets.
      await loadTickets();
    }

  void openscanner() async {
    await Navigator.push(
      context,
      MaterialPageRoute(
        builder:
            (_) => QRScannerPage(
              onScan: (code) {
                debugPrint('Código escaneado: $code');
                showMessage('Código escaneado: $code');
              },
            ),
      ),
    );

    await loadTickets();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Home Screen'),
        actions: [
          PopupMenuButton<String>(
            icon: const Icon(Icons.add),
            tooltip: 'Opciones',
            onSelected: (value) {
              if (value == 'add_ticket') {
                openAddTicket();
              }
            },
            itemBuilder: (context) => [
              const PopupMenuItem(
                value: 'add_ticket',
                child: Text('Agregar ticket'),
              ),
            ],
          ),
        ],
      ),
      drawer: Drawer(
        child: ListView(
          padding: EdgeInsets.zero,
          children: [
            DrawerHeader(
              decoration: BoxDecoration(color: Theme.of(context).appBarTheme.backgroundColor),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  const Text(
                    'Menú',
                    style: TextStyle(color: Colors.white, fontSize: 24),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Hola, $userName',
                    style: const TextStyle(color: Colors.white, fontSize: 18),
                  ),
                ],
              ),
            ),
            ListTile(
              leading: const Icon(Icons.login),
              title: const Text('Cerrar sesión'),
              onTap: () => context.go('/'),
            ),
          ],
        ),
      ),
      body: Padding(
        padding: EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Área de escaneo de códigos QR',
              style: TextStyle(fontSize: 18),
            ),
            const SizedBox(height: 16),
            ElevatedButton.icon(
              onPressed: openscanner,
              icon: Icon(Icons.qr_code_scanner),
              label: const Text('Abrir escáner QR'),
            ),
            const SizedBox(height: 24),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Lista de Tickets',
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 10),
                Row(
                  children: [
                    ElevatedButton(
                      onPressed: () {
                        pageController.animateToPage(
                          0,
                          duration: Duration(milliseconds: 300),
                          curve: Curves.easeInOut,
                        );
                        setState(() {
                          vistaActual = TicketView.procesados;
                        });
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor:
                            vistaActual == TicketView.procesados
                                ? Colors.greenAccent
                                : Colors.grey,
                      ),
                      child: const Text('Procesados'),
                    ),
                    const SizedBox(width: 12),
                    ElevatedButton(
                      onPressed: () {
                        pageController.animateToPage(
                          1,
                          duration: Duration(milliseconds: 300),
                          curve: Curves.easeInOut,
                        );
                        setState(() {
                          vistaActual = TicketView.faltantes;
                        });
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor:
                            vistaActual == TicketView.faltantes
                                ? Colors.orangeAccent
                                : Colors.grey,
                      ),
                      child: const Text('Faltantes'),
                    ),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 16),

            Text(
              vistaActual == TicketView.procesados
                  ? 'Total: ${listaProcesados.length}'
                  : 'Total: ${listaFaltantes.length}',
                  style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),

            isLoading
                ? const Center(child: CircularProgressIndicator())
                : Expanded(
                  child: RefreshIndicator(
                    onRefresh: loadTickets,
                    child: PageView(
                      controller: pageController,
                      onPageChanged: (index) {
                        setState(() {
                          vistaActual =
                              index == 0
                                  ? TicketView.procesados
                                  : TicketView.faltantes;
                        });
                      },
                      children: [
                        TicketsListView(tickets: listaProcesados),
                        TicketsListView(tickets: listaFaltantes),
                      ],
                    ),
                  ),
                ),
          ],
        ),
      ),
    );
  }
}
