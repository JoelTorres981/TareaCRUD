import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import '../db/mongo_database.dart';
import '../models/cheapshark.dart';

class ApiExplorerPage extends StatefulWidget {
  const ApiExplorerPage({super.key});

  @override
  State<ApiExplorerPage> createState() => _ApiExplorerPageState();
}

class _ApiExplorerPageState extends State<ApiExplorerPage> {
  final List<CheapSharkDeal> _deals = [];
  final ScrollController _scrollController = ScrollController();
  
  bool _isLoading = false;
  bool _hasMore = true;
  int _pageNumber = 0;
  final int _pageSize = 10;

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
        _pageNumber = 0;
        _deals.clear();
        _hasMore = true;
      }
    });

    try {
      final url = Uri.parse(
        'https://www.cheapshark.com/api/1.0/deals?pageNumber=$_pageNumber&pageSize=$_pageSize',
      );
      final response = await http.get(url);

      if (response.statusCode == 200) {
        final List<dynamic> data = jsonDecode(response.body);
        final List<CheapSharkDeal> fetchedDeals = data.map((json) {
          return CheapSharkDeal.fromJson(json as Map<String, dynamic>);
        }).toList();

        setState(() {
          _deals.addAll(fetchedDeals);
          _pageNumber++;
          if (fetchedDeals.length < _pageSize) {
            _hasMore = false;
          }
        });
      } else {
        throw Exception('Servidor respondió con código ${response.statusCode}');
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error al obtener ofertas de CheapShark: $e'),
            backgroundColor: const Color(0xFFEF4444),
          ),
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

  Future<void> _guardarEnColeccion(CheapSharkDeal deal) async {
    try {
      await MongoDatabase.insertDeal(deal);
      
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('"${deal.title}" guardado en mi colección'),
            backgroundColor: const Color(0xFF10B981), // Emerald Green
            behavior: SnackBarBehavior.floating,
            duration: const Duration(seconds: 2),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error al guardar en colección: $e'),
            backgroundColor: const Color(0xFFEF4444),
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Explorar Ofertas (API)'),
        centerTitle: true,
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
                    Icons.cloud_off_rounded,
                    size: 80,
                    color: Colors.grey,
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'No se pudieron cargar ofertas',
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(color: Colors.white70),
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    'Verifique su conexión a internet e intente de nuevo.',
                    textAlign: TextAlign.center,
                    style: TextStyle(color: Colors.grey),
                  ),
                  const SizedBox(height: 20),
                  ElevatedButton.icon(
                    onPressed: () => _loadMoreDeals(isRefresh: true),
                    icon: const Icon(Icons.refresh_rounded),
                    label: const Text('Reintentar'),
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
            'Fin de las ofertas disponibles',
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
      child: Container(
        height: 110,
        decoration: const BoxDecoration(
          color: Color(0xFF1E293B), // Slate 800
        ),
        child: Row(
          children: [
            // Thumbnail Image
            SizedBox(
              width: 110,
              height: 110,
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
                padding: const EdgeInsets.all(12.0),
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
            
            // Save Button
            Padding(
              padding: const EdgeInsets.only(right: 8.0),
              child: IconButton(
                icon: const Icon(Icons.bookmark_add_rounded, color: Color(0xFF0EA5E9)),
                tooltip: 'Guardar en colección',
                onPressed: () => _guardarEnColeccion(deal),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
