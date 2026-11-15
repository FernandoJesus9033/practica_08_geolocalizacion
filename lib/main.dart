import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';

void main() => runApp(
  const MaterialApp(debugShowCheckedModeBanner: false, home: PuntosPage()),
);

// ============================================
// MODELO: Punto de Interés
// ============================================
class PuntoInteres {
  final String nombre;
  final double latitud;
  final double longitud;

  PuntoInteres({
    required this.nombre,
    required this.latitud,
    required this.longitud,
  });
}

// ============================================
// PANTALLA PRINCIPAL
// ============================================
class PuntosPage extends StatefulWidget {
  const PuntosPage({super.key});

  @override
  State<PuntosPage> createState() => _PuntosPageState();
}

class _PuntosPageState extends State<PuntosPage> {
  Position? posicionActual;
  String mensaje = 'Obteniendo ubicación...';
  final List<PuntoInteres> puntos = [];

  @override
  void initState() {
    super.initState();
    obtenerUbicacion();
  }

  Future<void> obtenerUbicacion() async {
    if (!await Geolocator.isLocationServiceEnabled()) {
      setState(() => mensaje = 'Activa el servicio de ubicación');
      return;
    }

    var permiso = await Geolocator.checkPermission();
    if (permiso == LocationPermission.denied) {
      permiso = await Geolocator.requestPermission();
    }

    if (permiso == LocationPermission.denied ||
        permiso == LocationPermission.deniedForever) {
      setState(() => mensaje = 'Permiso de ubicación no disponible');
      return;
    }

    final p = await Geolocator.getCurrentPosition();
    setState(() {
      posicionActual = p;
      mensaje = 'Ubicación actual lista';
    });
  }

  // Calcular distancia usando Geolocator.distanceBetween
  double calcularDistancia(double lat, double lon) {
    if (posicionActual == null) return 0;
    return Geolocator.distanceBetween(
      posicionActual!.latitude,
      posicionActual!.longitude,
      lat,
      lon,
    );
  }

  // Navegar a la pantalla del Mapa
  void verMapa(PuntoInteres punto) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => MapaPage(punto: punto)),
    );
  }

  void agregarPunto() {
    final nombreCtrl = TextEditingController();
    final latCtrl = TextEditingController();
    final lonCtrl = TextEditingController();

    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Nuevo Punto de Interés'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: nombreCtrl,
              decoration: const InputDecoration(labelText: 'Nombre'),
            ),
            TextField(
              controller: latCtrl,
              decoration: const InputDecoration(labelText: 'Latitud'),
              keyboardType: TextInputType.number,
            ),
            TextField(
              controller: lonCtrl,
              decoration: const InputDecoration(labelText: 'Longitud'),
              keyboardType: TextInputType.number,
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancelar'),
          ),
          FilledButton(
            onPressed: () {
              final lat = double.tryParse(latCtrl.text);
              final lon = double.tryParse(lonCtrl.text);
              if (nombreCtrl.text.isNotEmpty && lat != null && lon != null) {
                setState(() {
                  puntos.add(
                    PuntoInteres(
                      nombre: nombreCtrl.text,
                      latitud: lat,
                      longitud: lon,
                    ),
                  );
                });
                Navigator.pop(context);
              }
            },
            child: const Text('Guardar'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Puntos de Interés')),
      floatingActionButton: FloatingActionButton(
        onPressed: agregarPunto,
        child: const Icon(Icons.add_location),
      ),
      body: Column(
        children: [
          // Panel de ubicación actual
          Card(
            margin: const EdgeInsets.all(12),
            color: Colors.purple[50],
            child: ListTile(
              leading: const Icon(Icons.my_location, color: Colors.purple),
              title: Text(mensaje),
              subtitle: posicionActual != null
                  ? Text(
                      'Lat: ${posicionActual!.latitude.toStringAsFixed(5)}\nLon: ${posicionActual!.longitude.toStringAsFixed(5)}',
                    )
                  : null,
              trailing: IconButton(
                icon: const Icon(Icons.refresh),
                onPressed: obtenerUbicacion,
              ),
            ),
          ),
          const Divider(),

          // Lista de Puntos
          Expanded(
            child: puntos.isEmpty
                ? const Center(child: Text('No hay puntos guardados'))
                : ListView.builder(
                    itemCount: puntos.length,
                    itemBuilder: (_, i) {
                      final p = puntos[i];
                      final distancia = calcularDistancia(
                        p.latitud,
                        p.longitud,
                      );
                      return Card(
                        margin: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 6,
                        ),
                        child: ListTile(
                          leading: CircleAvatar(child: Text('${i + 1}')),
                          title: Text(
                            p.nombre,
                            style: const TextStyle(fontWeight: FontWeight.bold),
                          ),
                          subtitle: Text(
                            'Lat: ${p.latitud}\nLon: ${p.longitud}\nDistancia: ${(distancia / 1000).toStringAsFixed(2)} km',
                          ),
                          trailing: IconButton(
                            icon: const Icon(Icons.map, color: Colors.blue),
                            onPressed: () => verMapa(p),
                          ),
                        ),
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }
}

// ============================================
// PANTALLA DEL MAPA
// ============================================
class MapaPage extends StatelessWidget {
  final PuntoInteres punto;

  const MapaPage({super.key, required this.punto});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Mapa: ${punto.nombre}')),
      body: FlutterMap(
        options: MapOptions(
          initialCenter: LatLng(punto.latitud, punto.longitud),
          initialZoom: 15.0,
        ),
        children: [
          TileLayer(
            urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
            userAgentPackageName: 'com.example.practica_08_geolocalizacion',
          ),
          MarkerLayer(
            markers: [
              Marker(
                point: LatLng(punto.latitud, punto.longitud),
                width: 80,
                height: 80,
                child: const Icon(
                  Icons.location_on,
                  color: Colors.red,
                  size: 50,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
