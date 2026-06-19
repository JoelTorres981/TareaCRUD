import 'package:flutter/material.dart';
import 'package:uuid/uuid.dart';
import '../db/mongo_database.dart';
import '../models/cheapshark.dart';

class FormPage extends StatefulWidget {
  final CheapSharkDeal? deal;

  const FormPage({super.key, this.deal});

  @override
  State<FormPage> createState() => _FormPageState();
}

class _FormPageState extends State<FormPage> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  final TextEditingController titleCtrl = TextEditingController();
  final TextEditingController salePriceCtrl = TextEditingController();
  final TextEditingController normalPriceCtrl = TextEditingController();
  final TextEditingController thumbCtrl = TextEditingController();
  final TextEditingController gameIdCtrl = TextEditingController();
  final TextEditingController metacriticScoreCtrl = TextEditingController();
  final TextEditingController steamRatingTextCtrl = TextEditingController();
  final TextEditingController steamRatingPercentCtrl = TextEditingController();
  final TextEditingController steamRatingCountCtrl = TextEditingController();
  final TextEditingController dealRatingCtrl = TextEditingController();

  bool guardando = false;

  @override
  void initState() {
    super.initState();

    final CheapSharkDeal? item = widget.deal;

    if (item != null) {
      titleCtrl.text = item.title;
      salePriceCtrl.text = item.salePrice.toString();
      normalPriceCtrl.text = item.normalPrice.toString();
      thumbCtrl.text = item.thumb;
      gameIdCtrl.text = item.gameId;
      metacriticScoreCtrl.text = item.metacriticScore.toString();
      steamRatingTextCtrl.text = item.steamRatingText;
      steamRatingPercentCtrl.text = item.steamRatingPercent.toString();
      steamRatingCountCtrl.text = item.steamRatingCount.toString();
      dealRatingCtrl.text = item.dealRating.toString();
    } else {
      // Valores por defecto para nuevo registro
      metacriticScoreCtrl.text = '0';
      steamRatingTextCtrl.text = 'N/A';
      steamRatingPercentCtrl.text = '0';
      steamRatingCountCtrl.text = '0';
      dealRatingCtrl.text = '0.0';
    }
  }

  @override
  void dispose() {
    titleCtrl.dispose();
    salePriceCtrl.dispose();
    normalPriceCtrl.dispose();
    thumbCtrl.dispose();
    gameIdCtrl.dispose();
    metacriticScoreCtrl.dispose();
    steamRatingTextCtrl.dispose();
    steamRatingPercentCtrl.dispose();
    steamRatingCountCtrl.dispose();
    dealRatingCtrl.dispose();
    super.dispose();
  }

  Future<void> guardar() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      guardando = true;
    });

    final double salePrice = double.tryParse(salePriceCtrl.text.trim()) ?? 0.0;
    final double normalPrice = double.tryParse(normalPriceCtrl.text.trim()) ?? 0.0;
    
    // Calcular campos automáticos
    final bool isOnSale = salePrice < normalPrice;
    double savings = 0.0;
    if (normalPrice > 0) {
      savings = ((normalPrice - salePrice) / normalPrice) * 100;
      if (savings < 0) savings = 0.0;
    }

    final CheapSharkDeal cheapSharkDeal = CheapSharkDeal(
      mongoId: widget.deal?.mongoId,
      dealId: widget.deal?.dealId ?? const Uuid().v4(),
      title: titleCtrl.text.trim(),
      storeId: widget.deal?.storeId ?? '1', // Default a Steam
      gameId: gameIdCtrl.text.trim().isEmpty ? '0' : gameIdCtrl.text.trim(),
      salePrice: salePrice,
      normalPrice: normalPrice,
      isOnSale: isOnSale,
      savings: savings,
      metacriticScore: int.tryParse(metacriticScoreCtrl.text.trim()) ?? 0,
      steamRatingText: steamRatingTextCtrl.text.trim(),
      steamRatingPercent: int.tryParse(steamRatingPercentCtrl.text.trim()) ?? 0,
      steamRatingCount: int.tryParse(steamRatingCountCtrl.text.trim()) ?? 0,
      thumb: thumbCtrl.text.trim(),
      dealRating: double.tryParse(dealRatingCtrl.text.trim()) ?? 0.0,
    );

    try {
      if (widget.deal == null) {
        await MongoDatabase.insertDeal(cheapSharkDeal);
      } else {
        await MongoDatabase.updateDeal(cheapSharkDeal);
      }

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(widget.deal == null ? 'Oferta creada exitosamente' : 'Oferta actualizada exitosamente')),
      );

      Navigator.pop(context, true); // Retornar true para indicar que hubo cambios
    } catch (e) {
      if (!mounted) return;

      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Error al guardar en MongoDB: $e')));
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
    bool esObligatorio = false,
    String? Function(String?)? validator,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: TextFormField(
        controller: controller,
        keyboardType: keyboardType,
        maxLines: maxLines,
        decoration: InputDecoration(
          label: RichText(
            text: TextSpan(
              text: label,
              style: const TextStyle(color: Colors.white70, fontSize: 14),
              children: [
                if (esObligatorio)
                  const TextSpan(
                    text: ' *',
                    style: TextStyle(color: Colors.redAccent, fontWeight: FontWeight.bold),
                  ),
              ],
            ),
          ),
          filled: true,
          fillColor: const Color(0xFF1E293B), // Slate 800
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(8),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(8),
            borderSide: BorderSide(color: Colors.grey.shade700),
          ),
        ),
        validator: validator ?? (String? value) {
          if (esObligatorio && (value == null || value.trim().isEmpty)) {
            return 'Este campo es obligatorio';
          }
          return null;
        },
      ),
    );
  }

  Widget campoNumero(
    TextEditingController controller,
    String label, {
    bool isDecimal = true,
    bool esObligatorio = false,
  }) {
    return campoTexto(
      controller,
      label,
      esObligatorio: esObligatorio,
      keyboardType: TextInputType.numberWithOptions(decimal: isDecimal),
      validator: (String? value) {
        if (value == null || value.trim().isEmpty) {
          if (esObligatorio) {
            return 'Este campo es obligatorio';
          }
          return null;
        }
        if (isDecimal) {
          if (double.tryParse(value.trim()) == null) {
            return 'Ingrese un número válido';
          }
        } else {
          if (int.tryParse(value.trim()) == null) {
            return 'Ingrese un número entero válido';
          }
        }
        return null;
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final bool editando = widget.deal != null;

    return Scaffold(
      appBar: AppBar(
        title: Text(editando ? 'Editar Oferta' : 'Nueva Oferta'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildSectionHeader('Información General'),
              campoTexto(titleCtrl, 'Título del Videojuego', esObligatorio: true),
              campoTexto(thumbCtrl, 'URL de la Imagen (Miniatura)', esObligatorio: false),
              campoTexto(gameIdCtrl, 'ID del Juego (CheapShark)', esObligatorio: false, validator: (val) => null), // Opcional
              
              const SizedBox(height: 16),
              _buildSectionHeader('Precios'),
              Row(
                children: [
                  Expanded(child: campoNumero(normalPriceCtrl, 'Precio Normal (\$)', esObligatorio: true)),
                  const SizedBox(width: 16),
                  Expanded(child: campoNumero(salePriceCtrl, 'Precio Oferta (\$)', esObligatorio: true)),
                ],
              ),
              
              const SizedBox(height: 16),
              _buildSectionHeader('Calificaciones y Reseñas'),
              Row(
                children: [
                  Expanded(child: campoNumero(metacriticScoreCtrl, 'Metacritic Score', isDecimal: false, esObligatorio: false)),
                  const SizedBox(width: 16),
                  Expanded(child: campoNumero(dealRatingCtrl, 'Deal Rating (0 - 10)', esObligatorio: false)),
                ],
              ),
              const SizedBox(height: 8),
              campoTexto(steamRatingTextCtrl, 'Steam Rating Text (ej. Very Positive, Mixed)', esObligatorio: false),
              Row(
                children: [
                  Expanded(child: campoNumero(steamRatingPercentCtrl, 'Steam Rating %', isDecimal: false, esObligatorio: false)),
                  const SizedBox(width: 16),
                  Expanded(child: campoNumero(steamRatingCountCtrl, 'Steam Rating Count', isDecimal: false, esObligatorio: false)),
                ],
              ),
              
              const SizedBox(height: 24),
              SizedBox(
                width: double.infinity,
                height: 50,
                child: FilledButton.icon(
                  style: FilledButton.styleFrom(
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  onPressed: guardando ? null : guardar,
                  icon: const Icon(Icons.save_rounded),
                  label: Text(
                    guardando ? 'Guardando...' : 'Guardar en Base de Datos',
                    style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSectionHeader(String title) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: Color(0xFF06B6D4), // Cyan accent
            ),
          ),
          const Divider(color: Color(0xFF06B6D4), thickness: 0.5),
        ],
      ),
    );
  }
}
