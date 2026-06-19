import 'package:flutter/material.dart';
import '../db/mongo_database.dart';
import 'collection_page.dart';
import 'api_explorer_page.dart';
import 'about_page.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  bool _isDbConnected = false;

  @override
  void initState() {
    super.initState();
    _checkDatabaseConnection();
  }

  void _checkDatabaseConnection() {
    try {
      setState(() {
        _isDbConnected = MongoDatabase.db.isConnected;
      });
    } catch (_) {
      setState(() {
        _isDbConnected = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('MediaExplorer App'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh_rounded),
            tooltip: 'Actualizar conexión',
            onPressed: () {
              _checkDatabaseConnection();
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Estado de conexión verificado'),
                  duration: Duration(seconds: 1),
                ),
              );
            },
          ),
        ],
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 10.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Welcome Banner Card with Glassmorphism feel or premium gradient
              Card(
                elevation: 6,
                shadowColor: Colors.cyan.withAlpha(60),
                clipBehavior: Clip.antiAlias,
                child: Container(
                  decoration: const BoxDecoration(
                    gradient: LinearGradient(
                      colors: [Color(0xFF0F766E), Color(0xFF0D9488)], // Teal theme
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                  ),
                  padding: const EdgeInsets.all(22.0),
                  child: const Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Icon(Icons.sports_esports_rounded, color: Colors.white, size: 28),
                          SizedBox(width: 8),
                          Text(
                            '¡Bienvenido Gamer!',
                            style: TextStyle(
                              fontSize: 22,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                              letterSpacing: 0.5,
                            ),
                          ),
                        ],
                      ),
                      SizedBox(height: 10),
                      Text(
                        'Explora las mejores ofertas de videojuegos para PC, compara precios de distintas tiendas y gestiona tu colección personal de ofertas guardadas.',
                        style: TextStyle(
                          fontSize: 14,
                          color: Color(0xEFFFFFFF),
                          height: 1.4,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 28),
              Text(
                'Menú de Opciones',
                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.bold,
                      letterSpacing: 0.5,
                    ),
              ),
              const SizedBox(height: 16),
              // Menu Grid with Cards
              Expanded(
                child: ListView(
                  physics: const BouncingScrollPhysics(),
                  children: [
                    _buildMenuCard(
                      context,
                      title: 'Colección',
                      subtitle: 'Gestionar ofertas guardadas localmente',
                      icon: Icons.bookmark_added_rounded,
                      startColor: const Color(0xFF6366F1), // Indigo
                      endColor: const Color(0xFF4F46E5),
                      onTap: () => Navigator.push(
                        context,
                        MaterialPageRoute(builder: (_) => const CollectionPage()),
                      ),
                    ),
                    const SizedBox(height: 16),
                    _buildMenuCard(
                      context,
                      title: 'Explorar API',
                      subtitle: 'Buscar ofertas en tiempo real en CheapShark',
                      icon: Icons.travel_explore_rounded,
                      startColor: const Color(0xFF0EA5E9), // Sky Blue
                      endColor: const Color(0xFF0284C7),
                      onTap: () => Navigator.push(
                        context,
                        MaterialPageRoute(builder: (_) => const ApiExplorerPage()),
                      ),
                    ),
                    const SizedBox(height: 16),
                    _buildMenuCard(
                      context,
                      title: 'Acerca de',
                      subtitle: 'Información general de la aplicación',
                      icon: Icons.info_outline_rounded,
                      startColor: const Color(0xFF10B981), // Emerald
                      endColor: const Color(0xFF059669),
                      onTap: () => Navigator.push(
                        context,
                        MaterialPageRoute(builder: (_) => const AboutPage()),
                      ),
                    ),
                  ],
                ),
              ),
              // Connection Status Footer
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 12.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Container(
                      width: 10,
                      height: 10,
                      decoration: BoxDecoration(
                        color: _isDbConnected ? const Color(0xFF10B981) : const Color(0xFFF43F5E),
                        shape: BoxShape.circle,
                        boxShadow: [
                          BoxShadow(
                            color: (_isDbConnected ? const Color(0xFF10B981) : const Color(0xFFF43F5E)).withAlpha(120),
                            blurRadius: 8,
                            spreadRadius: 2,
                          )
                        ],
                      ),
                    ),
                    const SizedBox(width: 10),
                    Text(
                      _isDbConnected
                          ? 'Base de Datos: Conectada'
                          : 'Base de Datos: Desconectada',
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.grey.shade400,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildMenuCard(
    BuildContext context, {
    required String title,
    required String subtitle,
    required IconData icon,
    required Color startColor,
    required Color endColor,
    required VoidCallback onTap,
  }) {
    return Card(
      clipBehavior: Clip.antiAlias,
      elevation: 4,
      shadowColor: startColor.withAlpha(40),
      child: InkWell(
        onTap: onTap,
        splashColor: Colors.white.withAlpha(30),
        highlightColor: Colors.white.withAlpha(10),
        child: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [startColor, endColor],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
          padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 16.0),
          child: Row(
            children: [
              Icon(
                icon,
                size: 38,
                color: Colors.white,
              ),
              const SizedBox(width: 18),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      title,
                      style: const TextStyle(
                        fontSize: 17,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                        letterSpacing: 0.2,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      subtitle,
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.white.withAlpha(200),
                      ),
                    ),
                  ],
                ),
              ),
              const Icon(
                Icons.arrow_forward_ios_rounded,
                size: 16,
                color: Colors.white70,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
