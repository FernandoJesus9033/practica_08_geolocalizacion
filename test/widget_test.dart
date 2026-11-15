import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:practica_08_geolocalizacion/main.dart';

void main() {
  testWidgets('La app carga correctamente', (WidgetTester tester) async {
    // Cargar la pantalla principal
    await tester.pumpWidget(const MaterialApp(home: UbicacionPage()));

    // Verificar que el título de la AppBar esté presente
    expect(find.text('Práctica 08 - Ubicación'), findsOneWidget);
  });
}