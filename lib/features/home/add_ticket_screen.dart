import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:ticket_free/features/auth/presentation/service/spbase_auth_service.dart';
import 'package:ticket_free/features/auth/shared/services/event_ticket_service.dart';
import 'package:ticket_free/features/auth/shared/services/section_service.dart';

/// Pantalla para agregar un nuevo ticket de evento.
/// Permite al usuario ingresar los datos necesarios y guardarlos en la base de datos.
class AddTicketScreen extends StatefulWidget {
  const AddTicketScreen({super.key});

  @override
  State<AddTicketScreen> createState() => _AddTicketScreenState();
}

class _AddTicketScreenState extends State<AddTicketScreen> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _serieController = TextEditingController();
  final TextEditingController _buyerNameController = TextEditingController();
  final TextEditingController _buyerIdentificationController =
      TextEditingController();
  final EventTicketService _ticketService = EventTicketService();
  final SectionService _sectionService = SectionService();

  // Instancia del servicio de autenticación para obtener el ID del usuario actual
  final SpbaseAuthService _authService = SpbaseAuthService();

  String _selectedSection = 'a';
  bool _isSaving = false;
  bool _isLoadingUser = true;

  @override
  void initState() {
    super.initState();
    _loadUserSection();
  }

  /// Carga los datos del usuario actual para preseleccionar la sección en el formulario.
  Future<void> _loadUserSection() async {
    try {
      final userData = await _authService.getCurrentUserName();
      if (userData != null && mounted /*userData.section.isNotEmpty*/ ) {
        final section = userData.section.toLowerCase();

        // Verificamos si la sección del usuario es válida antes de asignarla o existe en la lista de secciones disponibles
        if (_sectionService.getSections().contains(section)) {
          setState(() {
            _selectedSection = section;
          });
        }
      }
    } catch (e) {
      debugPrint('Error cargando datos del usuario: $e');
    } finally {
      if (mounted) {
        setState(() {
          _isLoadingUser = false;
        });
      }
    }
  }

  @override
  void dispose() {
    _serieController.dispose();
    _buyerNameController.dispose();
    _buyerIdentificationController.dispose();
    super.dispose();
  }

  /// Valida el formulario y guarda el ticket en la base de datos.
  /// Muestra mensajes de éxito o error según el resultado.
  Future<void> _submit() async {
    // 1. Guardián para evitar ejecuciones concurrentes
    if (_isSaving) return;

    if (!_formKey.currentState!.validate()) return;

    setState(() {
      _isSaving = true;
    });

    try {
      final (success, message) = await _ticketService.createTicket(
        idSerie: int.parse(_serieController.text.trim()),
        section:
            _selectedSection, // Utiliza la sección seleccionada en el formulario
        buyerName:
            _buyerNameController.text.trim().isEmpty
                ? null
                : _buyerNameController.text.trim(),
        buyerIdentification:
            _buyerIdentificationController.text.trim().isEmpty
                ? null
                : _buyerIdentificationController.text.trim(),
                
      );

      if (!mounted) return;

      if (success) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              message,
              style: const TextStyle(
                fontSize: 19.0,
                fontWeight: FontWeight.bold,
              ),
            ),
            backgroundColor: const Color.fromARGB(255, 47, 250, 54),
          ),
        );
        // Navigator.of(context).pop(true);
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              message,
              style: const TextStyle(
                fontSize: 19.0,
                fontWeight: FontWeight.bold,
              ),
            ),
            backgroundColor: Colors.red,
          ),
        );
      }
    } on Exception catch (e) {
      if (!mounted) return;

      if (e.toString().contains('duplicado')) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'Error: Ya existe un ticket con el número de ticket ${_serieController.text.trim()}',
            ),
            backgroundColor: Colors.orange,
          ),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error inesperado: ${e.toString()}'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Error de conexión o inesperado'),
          backgroundColor: Colors.red,
        ),
      );
    } finally {
      if (mounted) {
        setState(() {
          _isSaving = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoadingUser) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }
    return Scaffold(
      appBar: AppBar(title: const Text('Agregar Ticket')),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: SingleChildScrollView(
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  const Text(
                    'Datos del ticket',
                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 20),
                  // Campo para el número de serie del ticket
                  TextFormField(
                    controller: _serieController,
                    decoration: const InputDecoration(
                      labelText: 'Número de ticket',
                      border: OutlineInputBorder(),
                    ),
                    keyboardType: TextInputType.number,
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Ingresa el número de ticket';
                      }
                      if (int.tryParse(value) == null) {
                        return 'Ingresa un número válido';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 16),
                  // Campo opcional para el nombre del comprador
                  TextFormField(
                    controller: _buyerNameController,
                    decoration: const InputDecoration(
                      labelText: 'Nombre del comprador',
                      border: OutlineInputBorder(),
                    ),
                  ),
                  const SizedBox(height: 16),
                  // Campo obligatorio para la cédula venezolana del comprador
                  TextFormField(
                    controller: _buyerIdentificationController,
                    decoration: const InputDecoration(
                      labelText: 'C.I del comprador',
                      border: OutlineInputBorder(),
                      hintText: 'Solo números, formato cédula venezolana',
                    ),
                    keyboardType: TextInputType.number,
                    inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Ingresa la cédula del comprador';
                      }
                      final cedulaRegEx = RegExp(r'^[0-9]{7,8}$');
                      if (!cedulaRegEx.hasMatch(value)) {
                        return 'Formato inválido: debe tener 7 u 8 dígitos';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 16),
                  // Selector de sección donde estudia el vendedor del ticket
                  DropdownButtonFormField<String>(
                    value: _selectedSection,
                    isExpanded: true,
                    decoration: const InputDecoration(
                      labelText: 'Sección',
                      border: OutlineInputBorder(),
                    ),
                    items:
                        _sectionService.getSections().map((section) {
                          return DropdownMenuItem(
                            value: section,
                            child: Text(section.toUpperCase()),
                          );
                        }).toList(),
                        // Al pasar "null" a onChanged, el componente se deshabilita visualmente.
                    onChanged: null,
                    validator: (value) {
                      if (!_sectionService.isValidSection(value)) {
                        return 'Selecciona una sección válida';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 30),
                  // Botón para guardar el ticket
                  ElevatedButton(
                    onPressed: _isSaving ? null : _submit,
                    child:
                        _isSaving
                            ? const SizedBox(
                              height: 20,
                              width: 20,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                color: Colors.white,
                              ),
                            )
                            : const Text('Guardar ticket'),
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
