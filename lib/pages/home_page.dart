import 'package:flutter/material.dart';

import '../db/mongo_database.dart';
import '../models/videojuego.dart';
import 'detail_page.dart';
import 'form_page.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  late Future<List<Videojuego>> videojuegosFuture;

  @override
  void initState() {
    super.initState();
    cargarDatos();
  }

  void cargarDatos() {
    videojuegosFuture = MongoDatabase.getVideojuegos();
  }

  Future<void> refrescar() async {
    setState(() {
      cargarDatos();
    });
  }

  Future<void> eliminar(String id) async {
    await MongoDatabase.deleteVideojuego(id);

    if (!mounted) return;

    ScaffoldMessenger.of(
      context,
    ).showSnackBar(const SnackBar(content: Text('Registro eliminado')));

    await refrescar();
  }

  void confirmarEliminar(Videojuego item) {
    showDialog(
      context: context,
      builder: (_) {
        return AlertDialog(
          title: const Text('Confirmar eliminación'),
          content: Text('¿Eliminar ${item.titulo}?'),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context);
              },
              child: const Text('Cancelar'),
            ),
            FilledButton(
              onPressed: () {
                Navigator.pop(context);
                eliminar(item.id);
              },
              child: const Text('Eliminar'),
            ),
          ],
        );
      },
    );
  }

  Future<void> abrirFormulario({Videojuego? videojuego}) async {
    await Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => FormPage(videojuego: videojuego)),
    );

    await refrescar();
  }

  void abrirDetalle(Videojuego videojuego) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => DetailPage(videojuego: videojuego)),
    );
  }

  Widget imagenVideojuego(String url) {
    if (url.isEmpty) {
      return const Icon(Icons.videogame_asset, size: 50);
    }

    return Image.network(
      url,
      width: 60,
      height: 60,
      fit: BoxFit.cover,
      errorBuilder: (_, _, _) {
        return const Icon(Icons.broken_image, size: 50);
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Videojuegos'),
        actions: [
          IconButton(onPressed: refrescar, icon: const Icon(Icons.refresh)),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => abrirFormulario(),
        child: const Icon(Icons.add),
      ),
      body: FutureBuilder<List<Videojuego>>(
        future: videojuegosFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError) {
            return Center(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Text(
                  'Error al cargar datos:\n${snapshot.error}',
                  textAlign: TextAlign.center,
                ),
              ),
            );
          }

          final List<Videojuego> data = snapshot.data ?? [];

          if (data.isEmpty) {
            return const Center(child: Text('No hay videojuegos registrados'));
          }

          return RefreshIndicator(
            onRefresh: refrescar,
            child: ListView.builder(
              itemCount: data.length,
              itemBuilder: (context, index) {
                final Videojuego item = data[index];

                return Card(
                  margin: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 6,
                  ),
                  child: ListTile(
                    leading: imagenVideojuego(item.imagen),
                    title: Text(item.titulo),
                    subtitle: Text(
                      '${item.plataforma} | Stock: ${item.stock} | \$${item.precio}',
                    ),
                    onTap: () => abrirDetalle(item),
                    trailing: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        IconButton(
                          tooltip: 'Editar',
                          icon: const Icon(Icons.edit),
                          onPressed: () {
                            abrirFormulario(videojuego: item);
                          },
                        ),
                        IconButton(
                          tooltip: 'Eliminar',
                          icon: const Icon(Icons.delete),
                          onPressed: () {
                            confirmarEliminar(item);
                          },
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          );
        },
      ),
    );
  }
}
