import 'package:flutter/material.dart';
import 'package:uuid/uuid.dart';

import '../db/mongo_database.dart';
import '../models/videojuego.dart';

class FormPage extends StatefulWidget {
  final Videojuego? videojuego;

  const FormPage({super.key, this.videojuego});

  @override
  State<FormPage> createState() => _FormPageState();
}

class _FormPageState extends State<FormPage> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  final TextEditingController tituloCtrl = TextEditingController();
  final TextEditingController plataformaCtrl = TextEditingController();
  final TextEditingController precioCtrl = TextEditingController();
  final TextEditingController stockCtrl = TextEditingController();
  final TextEditingController imagenCtrl = TextEditingController();
  final TextEditingController descripcionCtrl = TextEditingController();

  bool guardando = false;

  @override
  void initState() {
    super.initState();

    final Videojuego? item = widget.videojuego;

    if (item != null) {
      tituloCtrl.text = item.titulo;
      plataformaCtrl.text = item.plataforma;
      precioCtrl.text = item.precio.toString();
      stockCtrl.text = item.stock.toString();
      imagenCtrl.text = item.imagen;
      descripcionCtrl.text = item.descripcion;
    }
  }

  @override
  void dispose() {
    tituloCtrl.dispose();
    plataformaCtrl.dispose();
    precioCtrl.dispose();
    stockCtrl.dispose();
    imagenCtrl.dispose();
    descripcionCtrl.dispose();
    super.dispose();
  }

  Future<void> guardar() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      guardando = true;
    });

    final Videojuego videojuego = Videojuego(
      mongoId: widget.videojuego?.mongoId,
      id: widget.videojuego?.id ?? const Uuid().v4(),
      titulo: tituloCtrl.text.trim(),
      plataforma: plataformaCtrl.text.trim(),
      precio: double.tryParse(precioCtrl.text.trim()) ?? 0,
      stock: int.tryParse(stockCtrl.text.trim()) ?? 0,
      imagen: imagenCtrl.text.trim(),
      descripcion: descripcionCtrl.text.trim(),
    );

    try {
      if (widget.videojuego == null) {
        await MongoDatabase.insertVideojuego(videojuego);
      } else {
        await MongoDatabase.updateVideojuego(videojuego);
      }

      if (!mounted) return;

      Navigator.pop(context);
    } catch (e) {
      if (!mounted) return;

      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Error al guardar: $e')));
    } finally {
      if (mounted) {
        setState(() {
          guardando = false;
        });
      }
    }
  }

  Widget campoTexto(
    TextEditingController controller,
    String label, {
    TextInputType keyboardType = TextInputType.text,
    int maxLines = 1,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: TextFormField(
        controller: controller,
        keyboardType: keyboardType,
        maxLines: maxLines,
        decoration: InputDecoration(
          labelText: label,
          border: const OutlineInputBorder(),
        ),
        validator: (String? value) {
          if (value == null || value.trim().isEmpty) {
            return 'Campo obligatorio';
          }
          return null;
        },
      ),
    );
  }

  Widget campoNumero(TextEditingController controller, String label) {
    return campoTexto(
      controller,
      label,
      keyboardType: const TextInputType.numberWithOptions(decimal: true),
    );
  }

  @override
  Widget build(BuildContext context) {
    final bool editando = widget.videojuego != null;

    return Scaffold(
      appBar: AppBar(
        title: Text(editando ? 'Editar videojuego' : 'Nuevo videojuego'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              campoTexto(tituloCtrl, 'Título'),
              campoTexto(plataformaCtrl, 'Plataforma'),
              campoNumero(precioCtrl, 'Precio'),
              campoNumero(stockCtrl, 'Stock'),
              campoTexto(imagenCtrl, 'URL de imagen'),
              campoTexto(descripcionCtrl, 'Descripción', maxLines: 3),
              const SizedBox(height: 16),
              SizedBox(
                width: double.infinity,
                child: FilledButton.icon(
                  onPressed: guardando ? null : guardar,
                  icon: const Icon(Icons.save),
                  label: Text(guardando ? 'Guardando...' : 'Guardar'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
