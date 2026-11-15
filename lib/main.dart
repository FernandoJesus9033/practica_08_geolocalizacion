import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:url_launcher/url_launcher.dart';

void main() => runApp(const MaterialApp(
      debugShowCheckedModeBanner: false,
      home: UbicacionPage(),
    ));

class UbicacionPage extends StatefulWidget {
  const UbicacionPage({super.key});

  @override
  State<UbicacionPage> createState() => _UbicacionPageState();
}

class _UbicacionPageState extends State<UbicacionPage> {
  Position? posicion;
  String mensaje = 'Sin ubicación';

  Future<void> obtener() async {
    // 1. Verificar si el servicio está activo
    if (!await Geolocator.isLocationServiceEnabled()) {
      setState(() => mensaje = 'Activa el servicio de ubicación');
      return;
    }

    // 2. Verificar y solicitar permisos
    var permiso = await Geolocator.checkPermission();
    if (permiso == LocationPermission.denied) {
      permiso = await Geolocator.requestPermission();
    }

    // 3. Validar si el permiso fue denegado
    if (permiso == LocationPermission.denied ||
        permiso == LocationPermission.deniedForever) {
      setState(() => mensaje = 'Permiso de ubicación no disponible');
      return;
    }

    // 4. Obtener la posición
    final p = await Geolocator.getCurrentPosition();
    setState(() {
      posicion = p;
      mensaje = 'Ubicación obtenida';
    });
  }

  Future<void> abrirMapa() async {
    if (posicion != null) {
      final url = Uri.parse(
          'https://www.google.com/maps/search/?api=1&query=${posicion!.latitude},${posicion!.longitude}');
      if (await canLaunchUrl(url)) {
        await launchUrl(url);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Práctica 08 - Ubicación')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.location_on, size: 80, color: Colors.purple),
            Text(mensaje, style: const TextStyle(fontSize: 18)),
            const SizedBox(height: 16),
            if (posicion != null) ...[
              Text('Latitud: ${posicion!.latitude}'),
              Text('Longitud: ${posicion!.longitude}'),
              Text('Precisión: ${posicion!.accuracy} m'),
            ],
            const SizedBox(height: 16),
            FilledButton(
              onPressed: obtener,
              child: const Text('Obtener ubicación'),
            ),
            OutlinedButton(
              onPressed: abrirMapa,
              child: const Text('Abrir en mapa'),
            ),
          ],
        ),
      ),
    );
  }
}