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
      } else {
        borderColor = Colors.blueGrey;
      }

      showDialog(
        context: context,
        builder:
            (_) => Dialog(
              insetPadding: const EdgeInsets.symmetric(horizontal: 30, vertical: 290),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(35),
                side: BorderSide(color: borderColor, width: 5),
              ),
              child: AlertDialog(
                backgroundColor: Colors.white,
                insetPadding: EdgeInsets.only(top: 0, left: 0, right: 0, bottom: 0),
                // contentPadding: EdgeInsets.only(top: 10, left: 0, right: 0, bottom: 10),
                actionsPadding: EdgeInsets.only(top: 0, left: 10, right: 10, bottom: 10),
                title: Column(
                  children: [
                    const Text('Ticket', textAlign: TextAlign.center, style: TextStyle(color: Colors.black, fontStyle: FontStyle.italic, fontSize: 25,)
                    ),
                    SizedBox(height: 5),
                  ],
                ),
                content: Text(result, style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold, fontSize: 18), textAlign: TextAlign.center,                ),
                actions: [
                  TextButton(
                    style: TextButton.styleFrom(foregroundColor: borderColor),
                    onPressed: () {
                      Navigator.pop(context);
                      Navigator.pop(context);
                    },
                    child: const Text('OK'),
                  ),
                ],
              ),
            ),
      );
    } catch (e) {
      showDialog(
        context: context,
        builder:
            (_) => Dialog(
              
              insetPadding: const EdgeInsets.symmetric(horizontal: 30, vertical: 290),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(35),
                side: const BorderSide(color: Colors.red, width: 5),
              ),
              child: AlertDialog(
                backgroundColor: Colors.red,
                insetPadding: EdgeInsets.zero,
                title: const Text('Error', style: TextStyle(color: Colors.red, fontWeight: FontWeight.bold, fontSize: 16), textAlign: TextAlign.center,
                ),
                content: Text(e.toString()),
                actions: [
                  TextButton(
                    style: TextButton.styleFrom(foregroundColor: Colors.red),
                    onPressed: () {
                      Navigator.pop(context);
                      _hasScanned = false;
                    },
                    child: const Text('Cerrar'),
                  ),
                ],
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
