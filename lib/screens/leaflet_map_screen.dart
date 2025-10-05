import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:geolocator/geolocator.dart';
import '../models/map_point.dart';
import '../widgets/add_point_dialog.dart';

class LeafletMapScreen extends StatefulWidget {
  const LeafletMapScreen({super.key});

  @override
  State<LeafletMapScreen> createState() => _LeafletMapScreenState();
}

class _LeafletMapScreenState extends State<LeafletMapScreen> {
  final MapController _mapController = MapController();
  final List<MapPoint> _points = [];
  final List<LatLng> _routePoints = [];
  
  // Domyślna lokalizacja - Warszawa
  LatLng _currentCenter = const LatLng(52.2297, 21.0122);
  bool _isLoadingLocation = false;
  bool _isRouteMode = false; // tryb rysowania trasy

  @override
  void initState() {
    super.initState();
    _getCurrentLocation();
  }

  Future<void> _getCurrentLocation() async {
    setState(() {
      _isLoadingLocation = true;
    });

    try {
      bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) {
        _showLocationError('Usługi lokalizacji są wyłączone');
        return;
      }

      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
        if (permission == LocationPermission.denied) {
          _showLocationError('Odmowa dostępu do lokalizacji');
          return;
        }
      }

      if (permission == LocationPermission.deniedForever) {
        _showLocationError('Brak uprawnień do lokalizacji');
        return;
      }

      Position position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
      );

      if (mounted) {
        setState(() {
          _currentCenter = LatLng(position.latitude, position.longitude);
          _isLoadingLocation = false;
        });
        
        _mapController.move(_currentCenter, 15.0);
        
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Znaleziono Twoją lokalizację!'),
            backgroundColor: Colors.green,
            duration: Duration(seconds: 2),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isLoadingLocation = false;
        });
        _showLocationError('Błąd pobierania lokalizacji: $e');
      }
    }
  }

  void _showLocationError(String message) {
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(message),
          backgroundColor: Colors.orange,
          duration: const Duration(seconds: 3),
        ),
      );
    }
  }

  void _addPoint(MapPoint point) {
    setState(() {
      _points.add(point);
    });
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Dodano punkt: ${point.title}'),
        backgroundColor: Colors.green,
      ),
    );
  }

  void _deletePoint(MapPoint point) {
    setState(() {
      _points.removeWhere((p) => p.id == point.id);
    });
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Usunięto punkt: ${point.title}'),
        backgroundColor: Colors.red,
      ),
    );
  }

  void _toggleRouteMode() {
    setState(() {
      _isRouteMode = !_isRouteMode;
      if (!_isRouteMode) {
        // Wyłączono tryb trasy - wyczyść punkty trasy jeśli user chce
        _showRouteClearDialog();
      }
    });
  }

  void _clearRoute() {
    setState(() {
      _routePoints.clear();
    });
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Trasa wyczyszczona'),
        backgroundColor: Colors.orange,
      ),
    );
  }

  void _undoLastRoutePoint() {
    if (_routePoints.isNotEmpty) {
      setState(() {
        _routePoints.removeLast();
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Cofnięto ostatni punkt. Pozostało: ${_routePoints.length}'),
          backgroundColor: Colors.blue,
        ),
      );
    }
  }

  void _showRouteClearDialog() {
    if (_routePoints.isEmpty) return;
    
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Wyczyścić trasę?'),
        content: Text('Masz ${_routePoints.length} punktów w trasie. Czy chcesz je zachować?'),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              _clearRoute();
            },
            child: const Text('Wyczyść'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Zachowaj'),
          ),
        ],
      ),
    );
  }

  void _onMapTap(TapPosition tapPosition, LatLng point) {
    if (_isRouteMode) {
      // Tryb rysowania trasy - dodaj punkt do trasy
      setState(() {
        _routePoints.add(point);
      });
      
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Punkt ${_routePoints.length} dodany do trasy'),
          backgroundColor: Colors.blue,
          duration: const Duration(seconds: 1),
        ),
      );
    } else {
      // Tryb dodawania punktów - pokaż dialog
      showDialog(
        context: context,
        builder: (context) => AddPointDialog(
          latitude: point.latitude,
          longitude: point.longitude,
          onAddPoint: _addPoint,
        ),
      );
    }
  }

  List<Marker> _buildMarkers() {
    return _points.map((point) {
      final category = PointCategory.fromValue(point.category);
      return Marker(
        point: LatLng(point.latitude, point.longitude),
        width: 50,
        height: 50,
        child: GestureDetector(
          onTap: () => _showPointDetails(point),
          child: Container(
            decoration: BoxDecoration(
              color: _getCategoryColor(category),
              shape: BoxShape.circle,
              border: Border.all(color: Colors.white, width: 2),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.3),
                  blurRadius: 4,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Center(
              child: Text(
                category.emoji,
                style: const TextStyle(fontSize: 20),
              ),
            ),
          ),
        ),
      );
    }).toList();
  }

  Color _getCategoryColor(PointCategory category) {
    switch (category) {
      case PointCategory.restaurant:
        return Colors.orange;
      case PointCategory.hotel:
        return Colors.blue;
      case PointCategory.attraction:
        return Colors.red;
      case PointCategory.nature:
        return Colors.green;
      case PointCategory.transport:
        return Colors.purple;
      case PointCategory.culture:
        return Colors.brown;
      case PointCategory.shopping:
        return Colors.pink;
      default:
        return Colors.grey;
    }
  }

  void _showPointDetails(MapPoint point) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => Container(
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Text(
                  PointCategory.fromValue(point.category).emoji,
                  style: const TextStyle(fontSize: 24),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    point.title,
                    style: const TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF4565AD),
                    ),
                  ),
                ),
                IconButton(
                  onPressed: () {
                    Navigator.pop(context);
                    _deletePoint(point);
                  },
                  icon: const Icon(Icons.delete, color: Colors.red),
                ),
              ],
            ),
            const SizedBox(height: 16),
            if (point.description.isNotEmpty) ...[
              Text(
                point.description,
                style: const TextStyle(fontSize: 14),
              ),
              const SizedBox(height: 16),
            ],
            Text(
              'Kategoria: ${PointCategory.fromValue(point.category).displayName}',
              style: const TextStyle(fontSize: 14, color: Colors.grey),
            ),
            const SizedBox(height: 8),
            Text(
              'Współrzędne: ${point.latitude.toStringAsFixed(4)}, ${point.longitude.toStringAsFixed(4)}',
              style: const TextStyle(fontSize: 12, color: Colors.grey),
            ),
            const SizedBox(height: 8),
            Text(
              'Dodano: ${_formatDate(point.createdAt)}',
              style: const TextStyle(fontSize: 12, color: Colors.grey),
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: () {
                      Navigator.pop(context);
                      _mapController.move(
                        LatLng(point.latitude, point.longitude),
                        16.0,
                      );
                    },
                    icon: const Icon(Icons.my_location),
                    label: const Text('Pokaż na mapie'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFFFDC300),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  void _showPointsList() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => Container(
        height: MediaQuery.of(context).size.height * 0.7,
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Twoje punkty (${_points.length})',
              style: const TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Color(0xFF4565AD),
              ),
            ),
            const SizedBox(height: 16),
            Expanded(
              child: _points.isEmpty
                  ? const Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.location_off, size: 64, color: Colors.grey),
                          SizedBox(height: 16),
                          Text(
                            'Brak dodanych punktów',
                            style: TextStyle(fontSize: 16, color: Colors.grey),
                          ),
                          SizedBox(height: 8),
                          Text(
                            'Dotknij mapę aby dodać punkt',
                            style: TextStyle(fontSize: 14, color: Colors.grey),
                          ),
                        ],
                      ),
                    )
                  : ListView.builder(
                      itemCount: _points.length,
                      itemBuilder: (context, index) {
                        final point = _points[index];
                        final category = PointCategory.fromValue(point.category);
                        
                        return Card(
                          child: ListTile(
                            leading: Container(
                              width: 40,
                              height: 40,
                              decoration: BoxDecoration(
                                color: _getCategoryColor(category),
                                shape: BoxShape.circle,
                              ),
                              child: Center(
                                child: Text(
                                  category.emoji,
                                  style: const TextStyle(fontSize: 16),
                                ),
                              ),
                            ),
                            title: Text(point.title),
                            subtitle: Text(category.displayName),
                            trailing: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                IconButton(
                                  icon: const Icon(Icons.my_location, color: Colors.blue),
                                  onPressed: () {
                                    Navigator.pop(context);
                                    _mapController.move(
                                      LatLng(point.latitude, point.longitude),
                                      16.0,
                                    );
                                  },
                                ),
                                IconButton(
                                  icon: const Icon(Icons.delete, color: Colors.red),
                                  onPressed: () {
                                    Navigator.pop(context);
                                    _deletePoint(point);
                                  },
                                ),
                              ],
                            ),
                            onTap: () {
                              Navigator.pop(context);
                              _showPointDetails(point);
                            },
                          ),
                        );
                      },
                    ),
            ),
          ],
        ),
      ),
    );
  }

  String _formatDate(DateTime date) {
    return '${date.day}.${date.month.toString().padLeft(2, '0')}.${date.year} '
        '${date.hour.toString().padLeft(2, '0')}:${date.minute.toString().padLeft(2, '0')}';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Mapa Journey Radar'),
        backgroundColor: const Color(0xFFFDC300),
        elevation: 0,
        actions: [
          if (_isLoadingLocation)
            const Padding(
              padding: EdgeInsets.all(16.0),
              child: SizedBox(
                width: 20,
                height: 20,
                child: CircularProgressIndicator(strokeWidth: 2),
              ),
            )
          else
            IconButton(
              icon: const Icon(Icons.my_location),
              onPressed: _getCurrentLocation,
              tooltip: 'Moja lokalizacja',
            ),
          IconButton(
            icon: Icon(_isRouteMode ? Icons.route : Icons.add_location),
            onPressed: _toggleRouteMode,
            tooltip: _isRouteMode ? 'Tryb punktów' : 'Tryb trasy',
            style: IconButton.styleFrom(
              backgroundColor: _isRouteMode ? Colors.red.withOpacity(0.2) : null,
            ),
          ),
          IconButton(
            icon: const Icon(Icons.list),
            onPressed: _showPointsList,
            tooltip: 'Lista punktów',
          ),
          IconButton(
            icon: const Icon(Icons.info),
            onPressed: () {
              showDialog(
                context: context,
                builder: (context) => AlertDialog(
                  title: const Text('Mapa OpenStreetMap'),
                  content: const Text(
                    'Ta mapa używa darmowych danych OpenStreetMap.\n\n'
                    'TRYB PUNKTÓW:\n'
                    '• Dotknij mapę aby dodać punkt\n'
                    '• Kliknij marker aby zobaczyć szczegóły\n\n'
                    'TRYB TRASY:\n'
                    '• Przełącz przyciskiem w górnym pasku\n'
                    '• Dotknij mapę aby dodać punkt do trasy\n'
                    '• Punkty połączą się czerwoną linią\n\n'
                    '• Pinch to zoom / Przeciągnij aby poruszać się',
                  ),
                  actions: [
                    TextButton(
                      onPressed: () => Navigator.pop(context),
                      child: const Text('OK'),
                    ),
                  ],
                ),
              );
            },
          ),
        ],
      ),
      body: FlutterMap(
        mapController: _mapController,
        options: MapOptions(
          center: _currentCenter,
          zoom: 13.0,
          maxZoom: 18.0,
          minZoom: 3.0,
          onTap: _onMapTap,
        ),
        children: [
          // Warstwa kafelków z OpenStreetMap
          TileLayer(
            urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
            userAgentPackageName: 'com.example.journey_radar',
            maxZoom: 18,
          ),
          
          // Warstwa trasy (polyline)
          if (_routePoints.length > 1)
            PolylineLayer(
              polylines: [
                Polyline(
                  points: _routePoints,
                  strokeWidth: 4.0,
                  color: Colors.red,
                ),
              ],
            ),
          
          // Punkty trasy jako małe markery
          if (_routePoints.isNotEmpty)
            MarkerLayer(
              markers: _routePoints.asMap().entries.map((entry) {
                final index = entry.key;
                final point = entry.value;
                return Marker(
                  point: point,
                  width: 30,
                  height: 30,
                  child: Container(
                    decoration: BoxDecoration(
                      color: Colors.red,
                      shape: BoxShape.circle,
                      border: Border.all(color: Colors.white, width: 2),
                    ),
                    child: Center(
                      child: Text(
                        '${index + 1}',
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                );
              }).toList(),
            ),
          
          // Warstwa markerów
          MarkerLayer(
            markers: [
              // Marker dla aktualnej lokalizacji
              Marker(
                point: _currentCenter,
                width: 30,
                height: 30,
                child: Container(
                  decoration: const BoxDecoration(
                    color: Colors.blue,
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.my_location,
                    color: Colors.white,
                    size: 20,
                  ),
                ),
              ),
              
              // Markery dodane przez użytkownika
              ..._buildMarkers(),
            ],
          ),
        ],
      ),
      bottomSheet: _isRouteMode ? Container(
        width: double.infinity,
        padding: const EdgeInsets.all(12),
        color: Colors.red.withOpacity(0.9),
        child: Text(
          _routePoints.isEmpty 
            ? 'TRYB TRASY - Dotknij mapę aby dodać punkt'
            : 'TRASA: ${_routePoints.length} punktów',
          style: const TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
            fontSize: 16,
          ),
          textAlign: TextAlign.center,
        ),
      ) : null,
      floatingActionButton: Column(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          FloatingActionButton(
            heroTag: "zoom_in",
            mini: true,
            onPressed: () {
              final currentZoom = _mapController.zoom;
              _mapController.move(_mapController.center, currentZoom + 1);
            },
            backgroundColor: const Color(0xFFFDC300),
            child: const Icon(Icons.add),
          ),
          const SizedBox(height: 8),
          FloatingActionButton(
            heroTag: "zoom_out",
            mini: true,
            onPressed: () {
              final currentZoom = _mapController.zoom;
              _mapController.move(_mapController.center, currentZoom - 1);
            },
            backgroundColor: const Color(0xFFFDC300),
            child: const Icon(Icons.remove),
          ),
          const SizedBox(height: 8),
          FloatingActionButton(
            heroTag: "my_location",
            onPressed: () {
              _mapController.move(_currentCenter, 15.0);
            },
            backgroundColor: const Color(0xFFFDC300),
            child: const Icon(Icons.center_focus_strong),
          ),
          
          // Kontrolki trasy - widoczne tylko w trybie trasy
          if (_isRouteMode) ...[
            const SizedBox(height: 16),
            FloatingActionButton(
              heroTag: "undo_route",
              mini: true,
              onPressed: _routePoints.isEmpty ? null : _undoLastRoutePoint,
              backgroundColor: Colors.orange,
              child: const Icon(Icons.undo),
            ),
            const SizedBox(height: 8),
            FloatingActionButton(
              heroTag: "clear_route",
              mini: true,
              onPressed: _routePoints.isEmpty ? null : _clearRoute,
              backgroundColor: Colors.red,
              child: const Icon(Icons.clear),
            ),
          ],
        ],
      ),
    );
  }
}