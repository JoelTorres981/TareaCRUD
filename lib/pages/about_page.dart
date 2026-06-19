import 'package:flutter/material.dart';

class AboutPage extends StatelessWidget {
  const AboutPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Acerca de'),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        physics: const BouncingScrollPhysics(),
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // App Banner Info
            Card(
              elevation: 4,
              child: Container(
                decoration: const BoxDecoration(
                  gradient: LinearGradient(
                    colors: [Color(0xFF0F766E), Color(0xFF0D9488)], // Emerald Theme
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                ),
                padding: const EdgeInsets.all(20.0),
                child: Column(
                  children: [
                    const Icon(
                      Icons.settings_suggest_rounded,
                      size: 60,
                      color: Colors.white,
                    ),
                    const SizedBox(height: 12),
                    const Text(
                      'MediaExplorer App',
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                        letterSpacing: 0.5,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      'Materia: Aplicaciones Móviles',
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.white.withAlpha(200),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 20),

            // Integrantes Section
            _buildSectionCard(
              title: 'Integrante',
              icon: Icons.person_rounded,
              child: const ListTile(
                contentPadding: EdgeInsets.zero,
                leading: CircleAvatar(
                  backgroundColor: Color(0xFF10B981),
                  foregroundColor: Colors.white,
                  child: Text('JT'),
                ),
                title: Text(
                  'Joel Torres',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
                subtitle: Text('Estudiante - EPN'),
              ),
            ),

            // API Section
            _buildSectionCard(
              title: 'API Utilizada',
              icon: Icons.api_rounded,
              child: const Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'CheapShark API',
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: Colors.cyan),
                  ),
                  SizedBox(height: 8),
                  Text(
                    'CheapShark es una API pública y gratuita que consolida ofertas y precios de videojuegos para PC de múltiples tiendas digitales (Steam, GOG, Epic Games, Humble Store, etc.). La aplicación consulta este servicio en tiempo real para listar y buscar descuentos de juegos.',
                    style: TextStyle(color: Colors.white70, height: 1.4),
                  ),
                ],
              ),
            ),

            // Theoretical Explanation Section
            _buildSectionCard(
              title: 'Explicación Teórica',
              icon: Icons.menu_book_rounded,
              child: const Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _TheoreticalItem(
                    title: 'Operación CRUD',
                    description: 'Implementación completa del ciclo CRUD (Create, Read, Update, Delete) en base de datos local:',
                    subpoints: [
                      'Create: Creación manual mediante formulario y guardado directo desde la API externa.',
                      'Read: Listado paginado y pantalla de detalles completos de la oferta.',
                      'Update: Edición de campos locales precargados en el formulario.',
                      'Delete: Eliminación lógica del registro con diálogo de confirmación.'
                    ],
                  ),
                  SizedBox(height: 16),
                  _TheoreticalItem(
                    title: 'MongoDB Atlas (Base de Datos)',
                    description: 'Conexión a base de datos en la nube no relacional (NoSQL) con MongoDB Atlas a través del driver nativo `mongo_dart`. Permite persistencia de datos y sincronización local en tiempo real.',
                  ),
                  SizedBox(height: 16),
                  _TheoreticalItem(
                    title: 'Scroll Infinito (Paginación)',
                    description: 'Implementación de scroll infinito configurado a 10 elementos por página para el listado local de MongoDB y la API de CheapShark, optimizando el ancho de banda y rendimiento de la memoria del dispositivo móvil al realizar consultas por lotes.',
                  ),
                ],
              ),
            ),

            // Screenshots Section
            _buildSectionCard(
              title: 'Galería de Capturas',
              icon: Icons.photo_library_rounded,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Capturas de Pantalla de la App',
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14, color: Colors.white70),
                  ),
                  const SizedBox(height: 16),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      // Fila 1: Menú Principal y Mi Colección
                      SizedBox(
                        height: 240,
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            Expanded(child: _buildScreenshotPlaceholder(context, 'assets/home.png', 'Menú Principal')),
                            const SizedBox(width: 12),
                            Expanded(child: _buildScreenshotPlaceholder(context, 'assets/collection.png', 'Mi Colección')),
                          ],
                        ),
                      ),
                      const SizedBox(height: 12),
                      
                      // Fila 2: Formulario CRUD y Detalle de Oferta
                      SizedBox(
                        height: 240,
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            Expanded(child: _buildScreenshotPlaceholder(context, 'assets/form.png', 'Formulario CRUD')),
                            const SizedBox(width: 12),
                            Expanded(child: _buildScreenshotPlaceholder(context, 'assets/detail.png', 'Detalle de Oferta')),
                          ],
                        ),
                      ),
                      const SizedBox(height: 12),
                      
                      // Fila 3: MongoDB Atlas (Ancho completo para capturas horizontales)
                      SizedBox(
                        height: 180,
                        child: _buildScreenshotPlaceholder(context, 'assets/mongoatlas.png', 'MongoDB Atlas'),
                      ),
                    ],
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
                Icon(icon, size: 20, color: const Color(0xFF10B981)),
                const SizedBox(width: 8),
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 16,
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

  Widget _buildScreenshotPlaceholder(BuildContext context, String assetPath, String title) {
    return Card(
      margin: EdgeInsets.zero,
      clipBehavior: Clip.antiAlias,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(10),
        side: const BorderSide(color: Colors.white10),
      ),
      color: const Color(0xFF0F172A), // Slate 900
      child: InkWell(
        onTap: () => _mostrarImagenAmpliada(context, assetPath, title),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Expanded(
              child: Image.asset(
                assetPath,
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) {
                  return Container(
                    color: const Color(0xFF1E293B),
                    alignment: Alignment.center,
                    child: const Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.image_outlined, color: Colors.grey, size: 36),
                        SizedBox(height: 8),
                        Text(
                          'Pendiente',
                          style: TextStyle(color: Colors.grey, fontSize: 12),
                        ),
                      ],
                    ),
                  );
                },
              ),
            ),
            Container(
              padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 4),
              color: const Color(0xFF1E293B), // Slate 800
              alignment: Alignment.center,
              child: Text(
                title,
                textAlign: TextAlign.center,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _mostrarImagenAmpliada(BuildContext context, String assetPath, String title) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return Dialog(
          backgroundColor: Colors.transparent,
          insetPadding: const EdgeInsets.all(16),
          child: Stack(
            alignment: Alignment.center,
            children: [
              // Zoomable Image
              GestureDetector(
                onTap: () => Navigator.pop(context),
                child: InteractiveViewer(
                  maxScale: 4.0,
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(12),
                    child: Image.asset(
                      assetPath,
                      fit: BoxFit.contain,
                      errorBuilder: (context, error, stackTrace) => Container(
                        color: const Color(0xFF1E293B),
                        padding: const EdgeInsets.all(40),
                        child: const Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(Icons.broken_image_rounded, color: Colors.grey, size: 60),
                            SizedBox(height: 16),
                            Text(
                              'Imagen no disponible',
                              style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              ),
              
              // Top Bar with Close Button
              Positioned(
                top: 8,
                right: 8,
                child: CircleAvatar(
                  backgroundColor: Colors.black.withAlpha(150),
                  child: IconButton(
                    icon: const Icon(Icons.close_rounded, color: Colors.white),
                    onPressed: () => Navigator.pop(context),
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

class _TheoreticalItem extends StatelessWidget {
  final String title;
  final String description;
  final List<String>? subpoints;

  const _TheoreticalItem({
    required this.title,
    required this.description,
    this.subpoints,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.white, fontSize: 14),
        ),
        const SizedBox(height: 4),
        Text(
          description,
          style: const TextStyle(color: Colors.white70, fontSize: 13, height: 1.3),
        ),
        if (subpoints != null) ...[
          const SizedBox(height: 6),
          Padding(
            padding: const EdgeInsets.only(left: 8.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: subpoints!.map((pt) {
                return Padding(
                  padding: const EdgeInsets.symmetric(vertical: 2.0),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text('• ', style: TextStyle(color: Colors.cyan)),
                      Expanded(
                        child: Text(
                          pt,
                          style: const TextStyle(color: Colors.white60, fontSize: 12),
                        ),
                      ),
                    ],
                  ),
                );
              }).toList(),
            ),
          )
        ]
      ],
    );
  }
}
