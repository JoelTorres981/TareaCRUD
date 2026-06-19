import 'package:flutter/material.dart';
import '../models/cheapshark.dart';

class DetailPage extends StatelessWidget {
  final CheapSharkDeal deal;

  const DetailPage({super.key, required this.deal});

  Color _getMetacriticColor(int score) {
    if (score >= 75) return const Color(0xFF10B981); // Green (Emerald)
    if (score >= 50) return const Color(0xFFF59E0B); // Amber / Yellow
    return const Color(0xFFEF4444); // Red (Rose)
  }

  String _getStoreName(String storeId) {
    switch (storeId) {
      case '1':
        return 'Steam';
      case '2':
        return 'GamersGate';
      case '3':
        return 'GreenManGaming';
      case '7':
        return 'GOG';
      case '11':
        return 'Humble Store';
      case '25':
        return 'Epic Games Store';
      default:
        return 'Tienda #$storeId';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Detalle de Oferta'),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        physics: const BouncingScrollPhysics(),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Banner Header with blurred effect or stylish card layout
            Container(
              height: 200,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    const Color(0xFF0F172A),
                    const Color(0xFF1E293B).withAlpha(100),
                  ],
                  begin: Alignment.bottomCenter,
                  end: Alignment.topCenter,
                ),
              ),
              child: Stack(
                alignment: Alignment.center,
                children: [
                  // Blurred Background
                  if (deal.thumb.isNotEmpty)
                    Positioned.fill(
                      child: Image.network(
                        deal.thumb,
                        fit: BoxFit.cover,
                        opacity: const AlwaysStoppedAnimation(0.15),
                      ),
                    ),
                  
                  // Main Image Card
                  Container(
                    width: 240,
                    height: 130,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(12),
                      boxShadow: [
                        BoxShadow(
                          color: const Color(0xFF06B6D4).withAlpha(50),
                          blurRadius: 16,
                          spreadRadius: 2,
                        ),
                      ],
                    ),
                    clipBehavior: Clip.antiAlias,
                    child: deal.thumb.isNotEmpty
                        ? Image.network(
                            deal.thumb,
                            fit: BoxFit.cover,
                            errorBuilder: (context, error, stackTrace) => const Icon(Icons.broken_image, size: 50),
                          )
                        : const Icon(Icons.videogame_asset, size: 50),
                  ),
                ],
              ),
            ),

            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Title
                  Text(
                    deal.title,
                    style: const TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                      letterSpacing: 0.2,
                    ),
                  ),
                  const SizedBox(height: 16),

                  // Card 1: Prices & Ahorro
                  _buildSectionCard(
                    title: 'Análisis de Precios',
                    icon: Icons.local_offer_rounded,
                    child: Column(
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            _buildPriceDetail(
                              label: 'PRECIO ACTUAL',
                              value: '\$${deal.salePrice.toStringAsFixed(2)}',
                              valueColor: const Color(0xFF06B6D4), // Cyan
                              isLarge: true,
                            ),
                            _buildPriceDetail(
                              label: 'PRECIO ORIGINAL',
                              value: '\$${deal.normalPrice.toStringAsFixed(2)}',
                              valueColor: Colors.grey.shade400,
                              isStrikethrough: true,
                            ),
                          ],
                        ),
                        const SizedBox(height: 16),
                        Row(
                          children: [
                            // Savings Badge
                            Expanded(
                              child: Container(
                                padding: const EdgeInsets.symmetric(vertical: 12),
                                decoration: BoxDecoration(
                                  color: const Color(0xFF10B981).withAlpha(25), // Emerald
                                  borderRadius: BorderRadius.circular(8),
                                  border: Border.all(color: const Color(0xFF10B981).withAlpha(100), width: 0.5),
                                ),
                                child: Column(
                                  children: [
                                    const Text('AHORRO TOTAL', style: TextStyle(fontSize: 10, color: Colors.grey, fontWeight: FontWeight.bold)),
                                    const SizedBox(height: 4),
                                    Text(
                                      '${deal.savings.toStringAsFixed(1)}%',
                                      style: const TextStyle(color: Color(0xFF10B981), fontSize: 20, fontWeight: FontWeight.w900),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                            const SizedBox(width: 16),
                            // Deal Rating Score
                            Expanded(
                              child: Container(
                                padding: const EdgeInsets.symmetric(vertical: 12),
                                decoration: BoxDecoration(
                                  color: Colors.indigo.withAlpha(25),
                                  borderRadius: BorderRadius.circular(8),
                                  border: Border.all(color: Colors.indigo.withAlpha(100), width: 0.5),
                                ),
                                child: Column(
                                  children: [
                                    const Text('CALIFICACIÓN OFERTA', style: TextStyle(fontSize: 10, color: Colors.grey, fontWeight: FontWeight.bold)),
                                    const SizedBox(height: 4),
                                    Text(
                                      '${deal.dealRating} / 10',
                                      style: const TextStyle(color: Color(0xFF818CF8), fontSize: 20, fontWeight: FontWeight.w900),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),

                  // Card 2: Valoraciones (Metacritic & Steam)
                  _buildSectionCard(
                    title: 'Puntuaciones y Reseñas',
                    icon: Icons.star_rounded,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Metacritic
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            const Text(
                              'Metacritic Score',
                              style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: Colors.white70),
                            ),
                            Container(
                              width: 42,
                              height: 42,
                              decoration: BoxDecoration(
                                color: deal.metacriticScore > 0
                                    ? _getMetacriticColor(deal.metacriticScore)
                                    : Colors.grey.shade800,
                                borderRadius: BorderRadius.circular(8),
                              ),
                              alignment: Alignment.center,
                              child: Text(
                                deal.metacriticScore > 0 ? deal.metacriticScore.toString() : 'N/A',
                                style: const TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.white,
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 16),
                        const Divider(height: 1, thickness: 0.5, color: Colors.white10),
                        const SizedBox(height: 16),

                        // Steam Reviews
                        const Text(
                          'Reseñas de Usuarios en Steam',
                          style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: Colors.white70),
                        ),
                        const SizedBox(height: 8),
                        Row(
                          children: [
                            Icon(
                              deal.steamRatingPercent >= 70
                                  ? Icons.thumb_up_rounded
                                  : Icons.thumb_down_rounded,
                              color: deal.steamRatingPercent >= 70 ? const Color(0xFF10B981) : Colors.redAccent,
                              size: 18,
                            ),
                            const SizedBox(width: 8),
                            Text(
                              deal.steamRatingText,
                              style: TextStyle(
                                fontSize: 13,
                                fontWeight: FontWeight.bold,
                                color: deal.steamRatingPercent >= 70 ? const Color(0xFF10B981) : Colors.redAccent,
                              ),
                            ),
                            const Spacer(),
                            Text(
                              '${deal.steamRatingPercent}% Positivas',
                              style: const TextStyle(fontSize: 13, color: Colors.white70, fontWeight: FontWeight.bold),
                            ),
                          ],
                        ),
                        const SizedBox(height: 8),
                        ClipRRect(
                          borderRadius: BorderRadius.circular(4),
                          child: LinearProgressIndicator(
                            value: deal.steamRatingPercent / 100.0,
                            minHeight: 8,
                            backgroundColor: Colors.grey.shade800,
                            color: deal.steamRatingPercent >= 70 ? const Color(0xFF10B981) : Colors.redAccent,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          'Basado en ${deal.steamRatingCount} valoraciones de usuarios.',
                          style: TextStyle(fontSize: 11, color: Colors.grey.shade500),
                        ),
                      ],
                    ),
                  ),

                  // Card 3: Datos Técnicos
                  _buildSectionCard(
                    title: 'Detalles Técnicos',
                    icon: Icons.settings_rounded,
                    child: Column(
                      children: [
                        _buildTechnicalRow('Plataforma/Tienda', _getStoreName(deal.storeId)),
                        _buildTechnicalRow('ID del Juego (CheapShark)', deal.gameId),
                        _buildTechnicalRow('ID de Oferta', deal.dealId),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionCard({
    required String title,
    required IconData icon,
    required Widget child,
  }) {
    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(icon, size: 20, color: const Color(0xFF06B6D4)),
                const SizedBox(width: 8),
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            const Divider(height: 1, thickness: 0.5, color: Colors.white10),
            const SizedBox(height: 14),
            child,
          ],
        ),
      ),
    );
  }

  Widget _buildPriceDetail({
    required String label,
    required String value,
    required Color valueColor,
    bool isLarge = false,
    bool isStrikethrough = false,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: TextStyle(fontSize: 10, color: Colors.grey.shade500, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 4),
        Text(
          value,
          style: TextStyle(
            fontSize: isLarge ? 22 : 16,
            fontWeight: FontWeight.bold,
            color: valueColor,
            decoration: isStrikethrough ? TextDecoration.lineThrough : null,
          ),
        ),
      ],
    );
  }

  Widget _buildTechnicalRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: const TextStyle(fontSize: 13, color: Colors.white70),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: SelectableText(
              value,
              textAlign: TextAlign.end,
              style: const TextStyle(
                fontSize: 12,
                fontFamily: 'monospace',
                color: Colors.cyan,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
