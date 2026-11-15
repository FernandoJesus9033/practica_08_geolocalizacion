import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:practica_08_geolocalizacion/main.dart';

void main() {
  testWidgets('La app de puntos de interes carga correctamente', (WidgetTester tester) async {
    await tester.pumpWidget(const MaterialApp(home: PuntosPage()));
    expect(find.text('Puntos de Interés'), findsOneWidget);
  });
}