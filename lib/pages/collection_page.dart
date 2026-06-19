import 'package:flutter/material.dart';
import '../db/mongo_database.dart';
import '../models/cheapshark.dart';
import 'form_page.dart';
import 'detail_page.dart';

class CollectionPage extends StatefulWidget {
  const CollectionPage({super.key});

  @override
  State<CollectionPage> createState() => _CollectionPageState();
}

class _CollectionPageState extends State<CollectionPage> {
  final List<CheapSharkDeal> _deals = [];
  final ScrollController _scrollController = ScrollController();
  
  bool _isLoading = false;
  bool _hasMore = true;
  int _skip = 0;
  final int _limit = 10;

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_scrollListener);
    _loadMoreDeals(isRefresh: true);
  }

  @override
  void dispose() {
    _scrollController.removeListener(_scrollListener);
    _scrollController.dispose();
    super.dispose();
  }

  void _scrollListener() {
    if (_scrollController.position.pixels >=
        _scrollController.position.maxScrollExtent - 200) {
      _loadMoreDeals();
    }
  }

  Future<void> _loadMoreDeals({bool isRefresh = false}) async {
    if (_isLoading) return;
    if (!isRefresh && !_hasMore) return;

    setState(() {
      _isLoading = true;
      if (isRefresh) {
        _skip = 0;
        _deals.clear();
        _hasMore = true;
      }
    });

    try {
      final List<CheapSharkDeal> newDeals = await MongoDatabase.getDealsPaged(
        skip: _skip,
        limit: _limit,
      );

      setState(() {
        _deals.addAll(newDeals);
        _skip += newDeals.length;
        if (newDeals.length < _limit) {
          _hasMore = false;
        }
      });
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error de conexión a la base de datos: $e')),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  Future<void> _deleteDeal(String dealId, String title) async {
    try {
      await MongoDatabase.deleteDeal(dealId);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('"$title" eliminado de la colección')),
        );
      }
      // Refrescar la colección tras borrar
      _loadMoreDeals(isRefresh: true);
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error al eliminar: $e')),
        );
      }
    }
  }

  void _confirmDelete(CheapSharkDeal deal) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Confirmar eliminación'),
          content: Text('¿Estás seguro de que deseas eliminar "${deal.title}" de tu colección?'),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancelar'),
            ),
            FilledButton(
              style: FilledButton.styleFrom(backgroundColor: const Color(0xFFF43F5E)),
              onPressed: () {
                Navigator.pop(context);
                _deleteDeal(deal.dealId, deal.title);
              },
              child: const Text('Eliminar'),
            ),
          ],
        );
      },
    );
  }

  Future<void> _abrirFormulario([CheapSharkDeal? deal]) async {
    final bool? result = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => FormPage(deal: deal),
      ),
    );

    if (result == true) {
      _loadMoreDeals(isRefresh: true);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Mi Colección'),
        centerTitle: true,
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: const Color(0xFF0EA5E9), // Sky Blue
        onPressed: () => _abrirFormulario(),
        child: const Icon(Icons.add_rounded, color: Colors.white),
      ),
      body: RefreshIndicator(
        onRefresh: () => _loadMoreDeals(isRefresh: true),
        child: _buildBody(),
      ),
    );
  }

  Widget _buildBody() {
    if (_deals.isEmpty && _isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (_deals.isEmpty) {
      return ListView(
        physics: const AlwaysScrollableScrollPhysics(),
        children: [
          SizedBox(height: MediaQuery.of(context).size.height * 0.25),
          Center(
            child: Padding(
              padding: const EdgeInsets.all(24.0),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(
                    Icons.bookmark_border_rounded,
                    size: 80,
                    color: Colors.grey,
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'Tu colección está vacía',
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(color: Colors.white70),
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    'Ve a la pestaña "Explorar API" en el menú principal para buscar y agregar ofertas increíbles.',
                    textAlign: TextAlign.center,
                    style: TextStyle(color: Colors.grey),
                  ),
                  const SizedBox(height: 20),
                  ElevatedButton.icon(
                    onPressed: () => _loadMoreDeals(isRefresh: true),
                    icon: const Icon(Icons.refresh_rounded),
                    label: const Text('Reintentar Carga'),
                  ),
                ],
              ),
            ),
          ),
        ],
      );
    }

    return ListView.builder(
      controller: _scrollController,
      physics: const AlwaysScrollableScrollPhysics(),
      itemCount: _deals.length + 1,
      itemBuilder: (context, index) {
        if (index == _deals.length) {
          return _buildLoaderIndicator();
        }

        final deal = _deals[index];
        return _buildDealCard(deal);
      },
    );
  }

  Widget _buildLoaderIndicator() {
    if (_isLoading) {
      return const Padding(
        padding: EdgeInsets.symmetric(vertical: 20),
        child: Center(
          child: CircularProgressIndicator(),
        ),
      );
    }

    if (!_hasMore) {
      return Padding(
        padding: const EdgeInsets.symmetric(vertical: 24),
        child: Center(
          child: Text(
            'Fin de la Colección • ${_deals.length} Ofertas',
            style: TextStyle(color: Colors.grey.shade600, fontSize: 13, fontWeight: FontWeight.w500),
          ),
        ),
      );
    }

    return const SizedBox.shrink();
  }

  Widget _buildDealCard(CheapSharkDeal deal) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => DetailPage(deal: deal),
            ),
          );
        },
        child: Container(
          height: 125,
          decoration: const BoxDecoration(
            color: Color(0xFF1E293B), // Slate 800
          ),
          child: Column(
            children: [
              Expanded(
                child: Row(
                  children: [
                    // Thumbnail Image
                    SizedBox(
                      width: 105,
                      height: 105,
                      child: deal.thumb.isNotEmpty
                          ? Image.network(
                              deal.thumb,
                              fit: BoxFit.cover,
                              errorBuilder: (context, error, stackTrace) => const Icon(
                                Icons.broken_image_rounded,
                                size: 40,
                                color: Colors.grey,
                              ),
                              loadingBuilder: (context, child, loadingProgress) {
                                if (loadingProgress == null) return child;
                                return const Center(child: SizedBox(width: 24, height: 24, child: CircularProgressIndicator(strokeWidth: 2)));
                              },
                            )
                          : const Icon(Icons.gamepad_rounded, size: 40, color: Colors.grey),
                    ),
                    
                    // Info Column
                    Expanded(
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 12.0, vertical: 8.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            // Title
                            Text(
                              deal.title,
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                              style: const TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                              ),
                            ),
                            
                            // Price Row
                            Wrap(
                              crossAxisAlignment: WrapCrossAlignment.center,
                              spacing: 8,
                              runSpacing: 4,
                              children: [
                                // Sale Price
                                Text(
                                  '\$${deal.salePrice.toStringAsFixed(2)}',
                                  style: const TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.w900,
                                    color: Color(0xFF06B6D4), // Cyan
                                  ),
                                ),
                                // Normal Price (if on sale, cross it out)
                                if (deal.isOnSale)
                                  Text(
                                    '\$${deal.normalPrice.toStringAsFixed(2)}',
                                    style: TextStyle(
                                      fontSize: 12,
                                      color: Colors.grey.shade500,
                                      decoration: TextDecoration.lineThrough,
                                    ),
                                  ),
                                // Discount Badge
                                if (deal.isOnSale && deal.savings > 0)
                                  Container(
                                    padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                    decoration: BoxDecoration(
                                      color: const Color(0xFF10B981).withAlpha(40), // Emerald
                                      borderRadius: BorderRadius.circular(4),
                                      border: Border.all(color: const Color(0xFF10B981).withAlpha(100), width: 0.5),
                                    ),
                                    child: Text(
                                      '-${deal.savings.toStringAsFixed(0)}%',
                                      style: const TextStyle(
                                        color: Color(0xFF10B981),
                                        fontSize: 10,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ),
                    
                    // Actions
                    Padding(
                      padding: const EdgeInsets.only(right: 4.0),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          IconButton(
                            icon: const Icon(Icons.edit_rounded, color: Color(0xFF0EA5E9), size: 20),
                            tooltip: 'Editar oferta',
                            onPressed: () => _abrirFormulario(deal),
                          ),
                          IconButton(
                            icon: const Icon(Icons.delete_outline_rounded, color: Color(0xFFF43F5E), size: 20),
                            tooltip: 'Eliminar de colección',
                            onPressed: () => _confirmDelete(deal),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              
              // Bottom Centered Navigation Text + Icon
              Container(
                padding: const EdgeInsets.only(bottom: 6.0),
                alignment: Alignment.center,
                child: const Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.info_outline_rounded,
                      color: Colors.white30,
                      size: 11,
                    ),
                    SizedBox(width: 4),
                    Text(
                      'Toca la tarjeta para ver el detalle de la oferta',
                      style: TextStyle(
                        color: Colors.white30,
                        fontSize: 9,
                        fontWeight: FontWeight.bold,
                        letterSpacing: 0.3,
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
}
