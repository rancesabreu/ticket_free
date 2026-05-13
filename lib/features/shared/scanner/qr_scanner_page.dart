import 'package:flutter/material.dart';

import 'package:mobile_scanner/mobile_scanner.dart';
import 'package:ticket_free/features/auth/shared/services/event_ticket_service.dart';

class QRScannerPage extends StatefulWidget {
  final Function(String) onScan;

  const QRScannerPage({super.key, required this.onScan});

  @override
  State<QRScannerPage> createState() => _QRScannerPageState();
}

class _QRScannerPageState extends State<QRScannerPage> {
  final EventTicketService ticketService = EventTicketService();
  bool _hasScanned = false;

  Future<void> _handleScan(String rawCode) async {
    if (_hasScanned) return;
    _hasScanned = true;

    try {
      final result = await ticketService.validateProcessTicket(rawCode);

      Color borderColor;

      if (result == 'Procesado con éxito') {
        borderColor = Colors.lightGreen;
      } else if (result == 'Ticket usado') {
        borderColor = Colors.orangeAccent;
      } else if (result == 'Código no existe') {
        borderColor = Colors.redAccent;
      } else if (result == 'Código QR vacío' || result == 'Formato de código QR inválido.') {
        borderColor = Colors.blueGrey;
      } else {
        borderColor = Colors.grey;
      }

      showDialog(
        context: context,
        builder:
            (_) => Dialog(
              insetPadding: const EdgeInsets.symmetric(horizontal: 30, vertical: 40),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(35),
                side: BorderSide(color: borderColor, width: 5),
              ),
              child: ConstrainedBox(
                constraints: BoxConstraints(
                  minWidth: MediaQuery.of(context).size.width * 0.8,
                  maxHeight: MediaQuery.of(context).size.height * 0.6,
                ),
                child: IntrinsicHeight(
                  child: Padding(padding: const EdgeInsets.all(24.0),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text('Ticket', textAlign: TextAlign.center, style: TextStyle(color: Colors.black, fontStyle: FontStyle.italic, fontSize: 25,)),
                      const SizedBox(height: 10),
                      Divider(thickness: 2, color: borderColor.withOpacity(0.3)),
                      const SizedBox(height: 15),
                      Flexible(child: SingleChildScrollView(
                        child: Text(
                          result,
                          style: TextStyle(
                            color: Colors.black,
                            fontWeight: FontWeight.w500,
                            fontSize: 22,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ),),
                      const SizedBox(height: 20),
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: borderColor,
                            foregroundColor: Colors.white,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(15),
                            ),
                            padding: const EdgeInsets.symmetric(vertical: 12),
                          ),
                          onPressed: () {
                      Navigator.pop(context);
                      _hasScanned = false;
                    },
                    child: const Text('OK', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                        ),
                      )
                    ],
                  ),
                  ),
                ),
              ),
            ),
                );
                
    } catch (e) {
      showDialog(
    context: context,
    builder: (_) => Dialog(
      // Usamos un padding razonable
      insetPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 40),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(35),
        side: const BorderSide(color: Colors.redAccent, width: 5),
      ),
      child: ConstrainedBox(
        constraints: BoxConstraints(
          minWidth: MediaQuery.of(context).size.width * 0.8,
          maxHeight: MediaQuery.of(context).size.height * 0.6,
        ),
        child: IntrinsicHeight(
          child: Padding(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Icono visual de error
                const Icon(Icons.error_outline, color: Colors.redAccent, size: 50),
                const SizedBox(height: 10),
                const Text(
                  'Error de Sistema',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: Colors.black,
                    fontWeight: FontWeight.bold,
                    fontSize: 22,
                  ),
                ),
                const SizedBox(height: 10),
                const Divider(thickness: 2),
                const SizedBox(height: 15),
                Flexible(
                  child: SingleChildScrollView(
                    child: Text(
                      e.toString(),
                      style: const TextStyle(
                        color: Colors.redAccent, // O un gris oscuro
                        fontSize: 16,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ),
                ),
                const SizedBox(height: 25),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.redAccent,
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(15),
                      ),
                      padding: const EdgeInsets.symmetric(vertical: 12),
                    ),
                    onPressed: () {
                      Navigator.pop(context);
                      _hasScanned = false; // IMPORTANTE: permitir re-escaneo tras el error
                    },
                    child: const Text('Cerrar', style: TextStyle(fontSize: 18)),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    ),
  );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Escanear QR')),
      body: Stack(
        children: [
          MobileScanner(
            onDetect: (capture) {
              final barcode = capture.barcodes.first;
              final String? code = barcode.rawValue;
              if (code != null) {
                _handleScan(code);
              }
            },
          ),
        ],
      ),
    );
  }
}
