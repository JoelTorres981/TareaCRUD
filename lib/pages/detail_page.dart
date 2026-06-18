import 'package:flutter/material.dart';

import '../models/videojuego.dart';

class DetailPage extends StatelessWidget {
  final Videojuego videojuego;

  const DetailPage({super.key, required this.videojuego});

  Widget imagenDetalle() {
    if (videojuego.imagen.isEmpty) {
      return const Icon(Icons.videogame_asset, size: 120);
    }

    return Image.network(
      videojuego.imagen,
      height: 220,
      width: double.infinity,
      fit: BoxFit.cover,
      errorBuilder: (_, _, _) {
        return const Icon(Icons.broken_image, size: 120);
      },
    );
  }

  Widget fila(String titulo, String valor) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '$titulo: ',
            style: const TextStyle(fontWeight: FontWeight.bold),
          ),
          Expanded(child: Text(valor)),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(videojuego.titulo)),
      body: SingleChildScrollView(
        child: Column(
          children: [
            imagenDetalle(),
            Padding(
              padding: const EdgeInsets.all(16),
              child: Card(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        videojuego.titulo,
                        style: Theme.of(context).textTheme.headlineSmall,
                      ),
                      const SizedBox(height: 16),
                      fila('Plataforma', videojuego.plataforma),
                      fila('Precio', '\$${videojuego.precio}'),
                      fila('Stock', videojuego.stock.toString()),
                      fila('Descripción', videojuego.descripcion),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
