class SectionService {
  /// Retorna las secciones de estudio disponibles del vendedor para asignar al ticket.
  /// Actualmente solo se aceptan las secciones 'a', 'b', 'c' y 'd'.
  List<String> getSections() {
    return const ['a', 'b', 'c'];
  }

  /// Valida que la sección del vendedor seleccionada sea una de las permitidas.
  bool isValidSection(String? section) {
    return getSections().contains(section);
  }
}
