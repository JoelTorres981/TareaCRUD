import 'package:mongo_dart/mongo_dart.dart';

class Videojuego {
  final ObjectId mongoId;
  final String id;
  final String titulo;
  final String plataforma;
  final double precio;
  final int stock;
  final String imagen;
  final String descripcion;

  Videojuego({
    ObjectId? mongoId,
    required this.id,
    required this.titulo,
    required this.plataforma,
    required this.precio,
    required this.stock,
    required this.imagen,
    required this.descripcion,
  }) : mongoId = mongoId ?? ObjectId();

  factory Videojuego.fromMap(Map<String, dynamic> map) {
    return Videojuego(
      mongoId: map['_id'] as ObjectId,
      id: map['id'] ?? '',
      titulo: map['titulo'] ?? '',
      plataforma: map['plataforma'] ?? '',
      precio: (map['precio'] ?? 0).toDouble(),
      stock: map['stock'] ?? 0,
      imagen: map['imagen'] ?? '',
      descripcion: map['descripcion'] ?? '',
    );
  }

  Map<String, dynamic> toMap() {
    return {
      '_id': mongoId,
      'id': id,
      'titulo': titulo,
      'plataforma': plataforma,
      'precio': precio,
      'stock': stock,
      'imagen': imagen,
      'descripcion': descripcion,
    };
  }
}
