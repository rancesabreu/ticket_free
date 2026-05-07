import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:ticket_free/features/auth/infraestructure/event_responsible.dart';
import 'package:ticket_free/features/auth/presentation/service/responsible_ticket_services.dart';
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

  // Nuevo controlador para mostrar la sección del vendedor (solo lectura)
  final TextEditingController _sectionController = TextEditingController();

  final EventTicketService _ticketService = EventTicketService();
  final SectionService _sectionService = SectionService();
  final ResponsibleTicketServices _responsibleService =
      ResponsibleTicketServices();
  // Instancia del servicio de autenticación para obtener el ID del usuario actual
  final SpbaseAuthService _authService = SpbaseAuthService();

  String _selectedSection = '';
  String _vendorUserId =
      ''; // Guardamos el ID del vendedor para asignarlo al ticket
  bool _isSaving = false;
  bool _isLoadingUser = true;

  List<EventResponsible> _responsibles = [];
  String? _selectedResponsibleId; // ID del estudiante responsable seleccionado
  bool _isLoadingResponsibles = false;

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
        _vendorUserId = userData.vendorUserId;
        // Verificamos si la sección del usuario es válida antes de asignarla o existe en la lista de secciones disponibles
        if (_sectionService.getSections().contains(section)) {
          setState(() {
            _selectedSection = section;
            // Valor al controlador de solo lectura para mostrar la sección del vendedor
            _sectionController.text =
                "Sección Asignada: ${section.toUpperCase()}";
          });
          _loadResponsibles(section);
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

  Future<void> _loadResponsibles(String section) async {
    setState(() {
      _isLoadingResponsibles = true;
    });
    try {
      // Llamada al servicio para obtener los responsables filtrados por sección
      final responsibles =
          await _responsibleService.getResponsiblesBySection(section);
      setState(() {
        _responsibles = responsibles;
      });
    } catch (e) {
      debugPrint('Error cargando responsables: $e');
    } finally {
      if (mounted) {
        setState(() {
          _isLoadingResponsibles = false;
        });
      }
    }
  }

  @override
  void dispose() {
    _serieController.dispose();
    _buyerNameController.dispose();
    _buyerIdentificationController.dispose();
    _sectionController.dispose();
    super.dispose();
  }

  /// Valida el formulario y guarda el ticket en la base de datos.
  /// Muestra mensajes de éxito o error según el resultado.
  Future<void> _submit() async {
    // 1. Guardián para evitar ejecuciones concurrentes
    if (_isSaving) return;

    // Validar el formulario antes de iniciar el proceso de guardado
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      _isSaving = true;
    });

    try {
      // Enviamos la información del ticket al servicio para crear el registro en la base de datos
      final (success, message) = await _ticketService.createTicket(
        idSerie: int.parse(_serieController.text.trim()),
        section:
            _selectedSection
                .toUpperCase(), // Utiliza la sección seleccionada en el formulario
        vendorUserId: _vendorUserId, // Asignamos el ID del vendedor al ticket
        responsibleId: _selectedResponsibleId,
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
        // LIMPIEZA DEL FORMULARIO
        _serieController.clear();
        _buyerNameController.clear();
        _buyerIdentificationController.clear();
        setState(() {
          _selectedResponsibleId = null;
        });
        // No limpiamos la sección para que el usuario pueda agregar varios tickets de la misma sección

        // FeedBack de exito
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
      await Future.delayed(
        const Duration(microseconds: 500),
      ); // Pequeña pausa para mostrar el mensaje
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
                  TextFormField(
                    controller: _sectionController,
                    readOnly: true,
                    enabled:
                        false, // Deshabilitamos el campo para que no sea editable
                    decoration: const InputDecoration(
                      labelText: 'Sección',
                      border: OutlineInputBorder(),
                      filled: true,
                    ),
                  ),

                  const SizedBox(height: 16),

                    _isLoadingResponsibles
                        ? const Center(child: CircularProgressIndicator())
                        : DropdownButtonFormField<String>(
                            value: _selectedResponsibleId,
                            isExpanded: true,
                            decoration: InputDecoration(
                              labelText: 'Estudiante responsable',
                              border: OutlineInputBorder(),
                              // Si no hay responsables disponibles, mostramos un mensaje en el hint

                            ),
                            hint: const Text('Selecciona el estudiante'),
                            items: _responsibles.map<DropdownMenuItem<String>>((EventResponsible res){
                              return DropdownMenuItem<String>(
                                value: res.studentId,                                
                                child: Text(res.name),
                              );
                            }).toList(),
                            onChanged: (value) {
                              setState(() {
                                _selectedResponsibleId = value;
                              });
                            },
                            validator: (value) {
                              if (value == null || value.isEmpty) {
                                return 'Selecciona un estudiante responsable';
                              }
                              return null;
                            },
                          ),

                  const SizedBox(height: 30),
                  // Botón para guardar el ticket
                  ElevatedButton(
                    onPressed: _isSaving ? null : _submit,
                    style: ElevatedButton.styleFrom(
                      disabledBackgroundColor: Colors.grey.shade300,
                    ),
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
