import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';

import '../widgets/app_background.dart';
import '../widgets/glass_card.dart';

class SearchResultsPage extends StatelessWidget {
  final List<Map<String, dynamic>> searchResults;
  final String fromLocation;
  final String toLocation;

  const SearchResultsPage({
    super.key,
    required this.searchResults,
    required this.fromLocation,
    required this.toLocation,
  });

  Widget _buildConnectionMap(Map<String, dynamic> connection) {
    final routePoints =
        connection['routePoints'] as List<Map<String, dynamic>>? ?? [];

    if (routePoints.isEmpty) {
      return Container(
        color: Colors.grey[400],
        child: const Center(
          child: Text(
            'Mapa niedostępna',
            style: TextStyle(color: Colors.white, fontSize: 12),
          ),
        ),
      );
    }

    // Przygotuj punkty dla mapy
    final List<LatLng> mapPoints = routePoints
        .map((point) => LatLng(point['lat'] as double, point['lng'] as double))
        .toList();

    // Wyznacz centrum mapy
    double centerLat =
        mapPoints.map((p) => p.latitude).reduce((a, b) => a + b) /
            mapPoints.length;
    double centerLng =
        mapPoints.map((p) => p.longitude).reduce((a, b) => a + b) /
            mapPoints.length;

    return FlutterMap(
      options: MapOptions(
        initialCenter: LatLng(centerLat, centerLng),
        initialZoom: 8.5,
        interactionOptions: const InteractionOptions(
          flags: InteractiveFlag.pinchZoom | InteractiveFlag.drag,
        ),
      ),
      children: [
        // Warstwa kafelków
        TileLayer(
          urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
          userAgentPackageName: 'com.example.journey_radar',
        ),

        // Linia trasy - kolor zależny od typu pociągu
        if (mapPoints.length > 1)
          PolylineLayer(
            polylines: [
              Polyline(
                points: mapPoints,
                strokeWidth: 3.0,
                color: _getTrainColor(connection['trainType'] ?? 'IC'),
              ),
            ],
          ),

        // Markery stacji - mniejsze dla mini-mapy
        MarkerLayer(
          markers: routePoints.asMap().entries.map((entry) {
            final index = entry.key;
            final point = entry.value;
            final isFirst = index == 0;
            final isLast = index == routePoints.length - 1;

            return Marker(
              point: LatLng(point['lat'] as double, point['lng'] as double),
              width: 24,
              height: 24,
              child: Container(
                decoration: BoxDecoration(
                  color: isFirst
                      ? Colors.green
                      : (isLast ? Colors.red : Colors.blue),
                  shape: BoxShape.circle,
                  border: Border.all(color: Colors.white, width: 1.5),
                ),
                child: Center(
                  child: Icon(
                    isFirst
                        ? Icons.play_arrow
                        : (isLast ? Icons.stop : Icons.circle),
                    color: Colors.white,
                    size: 12,
                  ),
                ),
              ),
            );
          }).toList(),
        ),
      ],
    );
  }

  Color _getTrainColor(String trainType) {
    switch (trainType.toUpperCase()) {
      case 'IC':
        return const Color(0xFFFDC300); // Żółty dla InterCity
      case 'RE':
        return Colors.blue; // Niebieski dla Regional Express
      case 'IR':
        return Colors.green; // Zielony dla InterRegio
      case 'TLK':
        return Colors.purple; // Fioletowy dla TLK
      default:
        return const Color(0xFFFDC300); // Domyślny żółty
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: AppBackground(
        child: SafeArea(
          child: Column(
            children: [
              const SizedBox(height: 16),
              
              // Header z logo i przyciskiem powrotu
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24),
                child: Row(
                  children: [
                    // Przycisk powrotu
                    Container(
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.2),
                        shape: BoxShape.circle,
                      ),
                      child: IconButton(
                        icon: const Icon(
                          Icons.arrow_back,
                          color: Colors.white,
                        ),
                        onPressed: () => Navigator.pop(context),
                      ),
                    ),
                    
                    const Spacer(),
                    
                    // Logo
                    SizedBox(
                      height: 80,
                      child: SvgPicture.asset(
                        'assets/images/icons/logo.svg',
                        fit: BoxFit.contain,
                      ),
                    ),
                    
                    const Spacer(),
                    
                    // Placeholder dla symetrii
                    const SizedBox(width: 48),
                  ],
                ),
              ),

              const SizedBox(height: 24),

              // Tytuł z trasą
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24),
                child: Text(
                  'Połączenia $fromLocation → $toLocation',
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                  textAlign: TextAlign.center,
                ),
              ),

              const SizedBox(height: 16),

              // Lista wyników
              Expanded(
                child: ListView.builder(
                  padding: const EdgeInsets.symmetric(horizontal: 24),
                  itemCount: searchResults.length,
                  itemBuilder: (context, index) {
                    final result = searchResults[index];
                    return Container(
                      margin: const EdgeInsets.only(bottom: 16),
                      width: double.infinity,
                      child: GlassCard(
                        width: double.infinity,
                        child: Padding(
                          padding: const EdgeInsets.all(16),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              // Header z stacjami i czasami
                              Stack(
                                alignment: Alignment.center,
                                children: [
                                  Row(
                                    children: [
                                      // Lewa połowa – start
                                      Expanded(
                                        child: Container(
                                          decoration: const BoxDecoration(
                                            color: Colors.white,
                                            borderRadius: BorderRadius.only(
                                              topLeft: Radius.circular(16),
                                            ),
                                          ),
                                          padding: const EdgeInsets.all(16),
                                          child: Column(
                                            crossAxisAlignment:
                                                CrossAxisAlignment.start,
                                            children: [
                                              Text(
                                                result['from'],
                                                maxLines: 1,
                                                style: const TextStyle(
                                                  color: Color(0xFF232323),
                                                  fontSize: 18,
                                                  fontWeight: FontWeight.bold,
                                                ),
                                              ),
                                              const SizedBox(height: 4),
                                              Text(
                                                result['departureTime'],
                                                style: const TextStyle(
                                                  color: Colors.black54,
                                                  fontSize: 14,
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                      ),

                                      // Prawa połowa – cel
                                      Expanded(
                                        child: Container(
                                          decoration: BoxDecoration(
                                            color: Colors.white
                                                .withValues(alpha: 0.5),
                                            borderRadius: const BorderRadius.only(
                                              topRight: Radius.circular(16),
                                            ),
                                          ),
                                          padding: const EdgeInsets.fromLTRB(
                                            32, 16, 16, 16),
                                          child: Column(
                                            crossAxisAlignment:
                                                CrossAxisAlignment.start,
                                            children: [
                                              Text(
                                                result['to'],
                                                maxLines: 1,
                                                style: const TextStyle(
                                                  color: Color(0xFF232323),
                                                  fontSize: 18,
                                                  fontWeight: FontWeight.bold,
                                                ),
                                              ),
                                              const SizedBox(height: 4),
                                              Text(
                                                result['arrivalTime'],
                                                style: const TextStyle(
                                                  color: Colors.black54,
                                                  fontSize: 14,
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),

                                  // Środkowy okrąg (dekor)
                                  Container(
                                    width: 38,
                                    height: 38,
                                    decoration: BoxDecoration(
                                      color: Colors.white,
                                      shape: BoxShape.circle,
                                      border: Border.all(
                                        color: const Color(0xFFFDC300),
                                        width: 2,
                                      ),
                                      boxShadow: [
                                        BoxShadow(
                                          color: Colors.black
                                              .withValues(alpha: 0.1),
                                          blurRadius: 4,
                                          offset: const Offset(0, 2),
                                        ),
                                      ],
                                    ),
                                    child: const Icon(
                                      Icons.arrow_forward_rounded,
                                      size: 20,
                                      color: Color(0xFFFDC300),
                                    ),
                                  ),
                                ],
                              ),

                              // Szczegóły połączenia
                              Container(
                                width: double.infinity,
                                padding: const EdgeInsets.symmetric(
                                  vertical: 12,
                                  horizontal: 16,
                                ),
                                decoration: const BoxDecoration(
                                  color: Colors.white,
                                  border: Border(
                                    top: BorderSide(
                                      color: Color(0xFFFDC300),
                                      width: 2,
                                    ),
                                  ),
                                ),
                                child: Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    Row(
                                      children: [
                                        const Icon(
                                          Icons.train,
                                          color: Color(0xFF232323),
                                          size: 18,
                                        ),
                                        const SizedBox(width: 6),
                                        Text(
                                          result['trainType'] ?? 'Pociąg',
                                          style: const TextStyle(
                                            color: Color(0xFF232323),
                                            fontSize: 13,
                                          ),
                                        ),
                                      ],
                                    ),
                                    if (result['changes'] == 0)
                                      Container(
                                        padding: const EdgeInsets.symmetric(
                                          horizontal: 10,
                                          vertical: 5,
                                        ),
                                        decoration: BoxDecoration(
                                          color: Colors.green
                                              .withValues(alpha: 0.1),
                                          borderRadius:
                                              BorderRadius.circular(12),
                                        ),
                                        child: const Text(
                                          'Bezpośredni',
                                          style: TextStyle(
                                            color: Colors.green,
                                            fontSize: 12,
                                            fontWeight: FontWeight.w500,
                                          ),
                                        ),
                                      ),
                                    Text(
                                      'Peron ${result['platform']}',
                                      style: const TextStyle(
                                        color: Color(0xFF232323),
                                        fontSize: 13,
                                      ),
                                    ),
                                  ],
                                ),
                              ),

                              // Mini-mapa
                              Container(
                                width: double.infinity,
                                height: 180,
                                decoration: const BoxDecoration(
                                  color: Colors.white,
                                  border: Border(
                                    top: BorderSide(
                                      color: Color(0xFFFDC300),
                                      width: 2,
                                    ),
                                  ),
                                  borderRadius: BorderRadius.only(
                                    bottomLeft: Radius.circular(16),
                                    bottomRight: Radius.circular(16),
                                  ),
                                ),
                                child: ClipRRect(
                                  borderRadius: const BorderRadius.only(
                                    bottomLeft: Radius.circular(16),
                                    bottomRight: Radius.circular(16),
                                  ),
                                  child: _buildConnectionMap(result),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
