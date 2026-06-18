import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

void main() {
  runApp(const PokemonApp());
}

class PokemonApp extends StatelessWidget {
  const PokemonApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Pokémon API',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorSchemeSeed: Colors.redAccent,
        useMaterial3: true,
        scaffoldBackgroundColor: Colors.grey.shade50,
      ),
      home: const PokemonPage(),
    );
  }
}

class PokemonPage extends StatefulWidget {
  const PokemonPage({super.key});

  @override
  State<PokemonPage> createState() => _PokemonPageState();
}

class _PokemonPageState extends State<PokemonPage> {
  final TextEditingController _controller = TextEditingController();
  Future<Map<String, dynamic>>? _pokemonFuture;

  Future<Map<String, dynamic>> fetchPokemon(String name) async {
    final url = Uri.parse(
      'https://pokeapi.co/api/v2/pokemon/${name.toLowerCase()}',
    );

    final response = await http.get(url);

    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    } else {
      throw Exception('No se encontró el Pokémon');
    }
  }

  void searchPokemon() {
    final name = _controller.text.trim();

    if (name.isEmpty) return;

    setState(() {
      _pokemonFuture = fetchPokemon(name);
    });
  }

  @override
  void initState() {
    super.initState();
    _pokemonFuture = fetchPokemon('pikachu');
  }

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 2,
      child: Scaffold(
        appBar: AppBar(
          title: const Text(
            'Pokédex API',
            style: TextStyle(fontWeight: FontWeight.bold, letterSpacing: 1.2),
          ),
          centerTitle: true,
          bottom: const TabBar(
            indicatorWeight: 3,
            labelStyle: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
            unselectedLabelStyle: TextStyle(fontWeight: FontWeight.w500),
            tabs: [
              Tab(icon: Icon(Icons.search), text: 'Buscar'),
              Tab(icon: Icon(Icons.format_list_bulleted), text: 'Lista'),
            ],
          ),
        ),
        body: TabBarView(
          children: [
            // Tab 1: Buscar
            Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                children: [
                  Container(
                    decoration: BoxDecoration(
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withAlpha(10),
                          blurRadius: 10,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: TextField(
                      controller: _controller,
                      decoration: InputDecoration(
                        labelText: 'Nombre o ID del Pokémon',
                        hintText: 'Ejemplo: pikachu, charizard, 25',
                        prefixIcon: const Icon(Icons.search),
                        filled: true,
                        fillColor: Colors.white,
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(30),
                          borderSide: BorderSide.none,
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(30),
                          borderSide: BorderSide(color: Colors.grey.shade200),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(30),
                          borderSide: BorderSide(
                            color: Theme.of(context).colorScheme.primary,
                            width: 2,
                          ),
                        ),
                        suffixIcon: Padding(
                          padding: const EdgeInsets.all(4.0),
                          child: IconButton(
                            icon: const Icon(Icons.arrow_forward),
                            style: IconButton.styleFrom(
                              backgroundColor: Theme.of(
                                context,
                              ).colorScheme.primary,
                              foregroundColor: Colors.white,
                            ),
                            onPressed: searchPokemon,
                          ),
                        ),
                      ),
                      onSubmitted: (_) => searchPokemon(),
                    ),
                  ),
                  const SizedBox(height: 20),
                  Expanded(
                    child: FutureBuilder<Map<String, dynamic>>(
                      future: _pokemonFuture,
                      builder: (context, snapshot) {
                        if (snapshot.connectionState ==
                            ConnectionState.waiting) {
                          return const Center(
                            child: CircularProgressIndicator(),
                          );
                        }

                        if (snapshot.hasError) {
                          return Center(
                            child: Card(
                              color: Colors.red.shade50,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(15),
                              ),
                              child: Padding(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 24,
                                  vertical: 16,
                                ),
                                child: Column(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    const Icon(
                                      Icons.error_outline,
                                      color: Colors.red,
                                      size: 48,
                                    ),
                                    const SizedBox(height: 8),
                                    Text(
                                      'Error: ${snapshot.error.toString().replaceAll('Exception: ', '')}',
                                      style: const TextStyle(
                                        color: Colors.red,
                                        fontWeight: FontWeight.bold,
                                      ),
                                      textAlign: TextAlign.center,
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          );
                        }

                        if (!snapshot.hasData) {
                          return const Center(child: Text('Busca un Pokémon'));
                        }

                        final pokemon = snapshot.data!;
                        return SingleChildScrollView(
                          physics: const BouncingScrollPhysics(),
                          child: Padding(
                            padding: const EdgeInsets.only(bottom: 24),
                            child: PokemonCard(pokemon: pokemon),
                          ),
                        );
                      },
                    ),
                  ),
                ],
              ),
            ),
            // Tab 2: Lista
            const PokemonListTab(),
          ],
        ),
      ),
    );
  }
}

class PokemonCard extends StatelessWidget {
  final Map<String, dynamic> pokemon;

  const PokemonCard({super.key, required this.pokemon});

  Color _getTypeColor(String type) {
    switch (type.toLowerCase()) {
      case 'fire':
        return Colors.deepOrange;
      case 'water':
        return Colors.blue;
      case 'grass':
        return Colors.green;
      case 'electric':
        return Colors.amber.shade700;
      case 'poison':
        return Colors.purple;
      case 'bug':
        return Colors.lightGreen.shade900;
      case 'normal':
        return Colors.grey.shade600;
      case 'ground':
        return Colors.brown;
      case 'flying':
        return Colors.indigo.shade300;
      case 'psychic':
        return Colors.pink;
      case 'rock':
        return Colors.blueGrey;
      case 'ghost':
        return Colors.indigo.shade800;
      case 'dragon':
        return const Color(0xFF1A237E);
      case 'ice':
        return Colors.cyan;
      case 'fighting':
        return Colors.red.shade800;
      case 'steel':
        return Colors.blueGrey.shade700;
      case 'fairy':
        return Colors.pink.shade300;
      default:
        return Colors.grey;
    }
  }

  Color _getStatColor(String statName) {
    switch (statName.toLowerCase()) {
      case 'hp':
        return Colors.red;
      case 'attack':
        return Colors.orange;
      case 'defense':
        return Colors.yellow.shade800;
      case 'special-attack':
        return Colors.blue;
      case 'special-defense':
        return Colors.green;
      case 'speed':
        return Colors.pink;
      default:
        return Colors.grey;
    }
  }

  String _translateStat(String statName) {
    switch (statName.toLowerCase()) {
      case 'hp':
        return 'Vida (HP)';
      case 'attack':
        return 'Ataque';
      case 'defense':
        return 'Defensa';
      case 'special-attack':
        return 'At. Esp.';
      case 'special-defense':
        return 'Def. Esp.';
      case 'speed':
        return 'Velocidad';
      default:
        return statName.toUpperCase();
    }
  }

  Widget _buildDetailTile(IconData icon, String label, String value) {
    return Expanded(
      child: Container(
        margin: const EdgeInsets.all(4),
        padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 8),
        decoration: BoxDecoration(
          color: Colors.grey.shade50,
          borderRadius: BorderRadius.circular(15),
          border: Border.all(color: Colors.grey.shade100),
        ),
        child: Column(
          children: [
            Icon(icon, color: Colors.redAccent.shade200, size: 22),
            const SizedBox(height: 6),
            Text(
              label,
              style: TextStyle(
                fontSize: 10,
                color: Colors.grey.shade500,
                fontWeight: FontWeight.bold,
                letterSpacing: 0.8,
              ),
            ),
            const SizedBox(height: 2),
            Text(
              value,
              style: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.bold,
                color: Colors.black87,
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final name = pokemon['name'].toString();
    final id = pokemon['id'];
    final height = pokemon['height'];
    final weight = pokemon['weight'];
    final baseExperience = pokemon['base_experience'] ?? 0;

    final sprites = pokemon['sprites'] as Map<String, dynamic>?;
    final other = sprites?['other'] as Map<String, dynamic>?;
    final officialArtwork = other?['official-artwork'] as Map<String, dynamic>?;
    final image =
        officialArtwork?['front_default'] as String? ??
        sprites?['front_default'] as String?;

    final types = pokemon['types'] as List;
    final abilities = pokemon['abilities'] as List;
    final stats = pokemon['stats'] as List;
    final moves = pokemon['moves'] as List;

    return Card(
      elevation: 4,
      shadowColor: Colors.black.withAlpha(20),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
      clipBehavior: Clip.antiAlias,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Header del Pokemon con degradado y la imagen oficial
          Container(
            height: 200,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  Theme.of(context).colorScheme.primaryContainer.withAlpha(51),
                  Theme.of(context).cardColor,
                ],
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
              ),
            ),
            child: Stack(
              alignment: Alignment.center,
              children: [
                if (image != null)
                  Hero(
                    tag: 'pokemon-image-$id',
                    child: Image.network(
                      image,
                      height: 160,
                      fit: BoxFit.contain,
                      errorBuilder: (context, error, stackTrace) {
                        return const Icon(Icons.image_not_supported, size: 80);
                      },
                    ),
                  ),
                Positioned(
                  top: 16,
                  right: 16,
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 6,
                    ),
                    decoration: BoxDecoration(
                      color: Theme.of(
                        context,
                      ).colorScheme.primary.withAlpha(30),
                      borderRadius: BorderRadius.circular(30),
                    ),
                    child: Text(
                      '#${id.toString().padLeft(3, '0')}',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        color: Theme.of(context).colorScheme.primary,
                        fontSize: 14,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),

          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Nombre
                Center(
                  child: Text(
                    name.toUpperCase(),
                    style: const TextStyle(
                      fontSize: 28,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 1.2,
                    ),
                  ),
                ),
                const SizedBox(height: 8),

                // Tipos
                Center(
                  child: Wrap(
                    spacing: 8,
                    children: types.map<Widget>((t) {
                      final typeName = t['type']['name'].toString();
                      final color = _getTypeColor(typeName);
                      return Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 14,
                          vertical: 6,
                        ),
                        decoration: BoxDecoration(
                          color: color.withAlpha(31),
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(color: color.withAlpha(77)),
                        ),
                        child: Text(
                          typeName.toUpperCase(),
                          style: TextStyle(
                            color: color,
                            fontWeight: FontWeight.bold,
                            fontSize: 11,
                          ),
                        ),
                      );
                    }).toList(),
                  ),
                ),
                const SizedBox(height: 20),

                // Grid de Detalles (Altura, Peso, Exp, Movimientos)
                Row(
                  children: [
                    _buildDetailTile(
                      Icons.height,
                      'ALTURA',
                      '${(height / 10).toStringAsFixed(1)} m',
                    ),
                    _buildDetailTile(
                      Icons.monitor_weight,
                      'PESO',
                      '${(weight / 10).toStringAsFixed(1)} kg',
                    ),
                  ],
                ),
                Row(
                  children: [
                    _buildDetailTile(
                      Icons.workspace_premium,
                      'EXP. BASE',
                      '$baseExperience XP',
                    ),
                    _buildDetailTile(
                      Icons.flash_on,
                      'MOVIMIENTOS',
                      '${moves.length}',
                    ),
                  ],
                ),
                const SizedBox(height: 20),

                // Habilidades
                const Text(
                  'Habilidades',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Colors.black87,
                  ),
                ),
                const SizedBox(height: 8),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: abilities.map<Widget>((a) {
                    final abilityName = a['ability']['name'].toString();
                    final isHidden = a['is_hidden'] == true;
                    return Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 6,
                      ),
                      decoration: BoxDecoration(
                        color: isHidden
                            ? Colors.grey.shade100
                            : Colors.red.shade50,
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(
                          color: isHidden
                              ? Colors.grey.shade300
                              : Colors.red.shade100,
                        ),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            isHidden
                                ? Icons.visibility_off_outlined
                                : Icons.auto_awesome,
                            size: 14,
                            color: isHidden
                                ? Colors.grey.shade600
                                : Colors.redAccent,
                          ),
                          const SizedBox(width: 6),
                          Text(
                            abilityName.toUpperCase(),
                            style: TextStyle(
                              fontSize: 11,
                              fontWeight: FontWeight.bold,
                              color: isHidden
                                  ? Colors.grey.shade700
                                  : Colors.red.shade900,
                            ),
                          ),
                        ],
                      ),
                    );
                  }).toList(),
                ),
                const SizedBox(height: 20),

                // Estadísticas Base
                const Text(
                  'Estadísticas Base',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Colors.black87,
                  ),
                ),
                const SizedBox(height: 12),
                ...stats.map((item) {
                  final statName = item['stat']['name'].toString();
                  final statVal = item['base_stat'] as int;
                  final progress = (statVal / 180.0).clamp(0.0, 1.0);
                  final statColor = _getStatColor(statName);
                  return Padding(
                    padding: const EdgeInsets.only(bottom: 10),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              _translateStat(statName),
                              style: const TextStyle(
                                fontSize: 13,
                                fontWeight: FontWeight.w600,
                                color: Colors.black54,
                              ),
                            ),
                            Text(
                              statVal.toString(),
                              style: const TextStyle(
                                fontSize: 13,
                                fontWeight: FontWeight.bold,
                                color: Colors.black87,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 4),
                        ClipRRect(
                          borderRadius: BorderRadius.circular(4),
                          child: LinearProgressIndicator(
                            value: progress,
                            minHeight: 6,
                            backgroundColor: Colors.grey.shade100,
                            color: statColor,
                          ),
                        ),
                      ],
                    ),
                  );
                }),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class PokemonListTab extends StatefulWidget {
  const PokemonListTab({super.key});

  @override
  State<PokemonListTab> createState() => _PokemonListTabState();
}

class _PokemonListTabState extends State<PokemonListTab> {
  final List<Map<String, dynamic>> _pokemonList = [];
  bool _isLoading = false;
  bool _hasMore = true;
  String? _errorMessage;
  int _offset = 0;
  final int _limit = 5;
  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_scrollListener);
    _loadMorePokemon();
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
      _loadMorePokemon();
    }
  }

  Future<List<Map<String, dynamic>>> fetchPokemonList(
    int offset,
    int limit,
  ) async {
    final url = Uri.parse(
      'https://pokeapi.co/api/v2/pokemon?offset=$offset&limit=$limit',
    );
    final response = await http.get(url);

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      final results = data['results'] as List;

      // Cargar detalles de cada Pokémon en paralelo para obtener sus imágenes e info completa
      final futures = results.map((item) async {
        final detailResponse = await http.get(Uri.parse(item['url']));
        if (detailResponse.statusCode == 200) {
          return jsonDecode(detailResponse.body) as Map<String, dynamic>;
        } else {
          throw Exception('Error al cargar detalle de ${item['name']}');
        }
      });

      return await Future.wait(futures);
    } else {
      throw Exception('Error al cargar la lista');
    }
  }

  Future<void> _loadMorePokemon() async {
    if (_isLoading || !_hasMore) return;

    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final newPokemon = await fetchPokemonList(_offset, _limit);
      setState(() {
        _pokemonList.addAll(newPokemon);
        _offset += _limit;
        if (newPokemon.length < _limit) {
          _hasMore = false;
        }
      });
    } catch (e) {
      setState(() {
        _errorMessage =
            'Ocurrió un error al cargar los datos. Inténtalo de nuevo.';
      });
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_pokemonList.isEmpty && _isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (_pokemonList.isEmpty && _errorMessage != null) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              _errorMessage!,
              style: const TextStyle(color: Colors.red),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 10),
            ElevatedButton(
              onPressed: _loadMorePokemon,
              child: const Text('Reintentar'),
            ),
          ],
        ),
      );
    }

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: ListView.builder(
        controller: _scrollController,
        physics: const BouncingScrollPhysics(),
        itemCount: _pokemonList.length + (_hasMore ? 1 : 0),
        itemBuilder: (context, index) {
          if (index == _pokemonList.length) {
            return const Padding(
              padding: EdgeInsets.symmetric(vertical: 24),
              child: Center(child: CircularProgressIndicator()),
            );
          }

          final pokemon = _pokemonList[index];
          return Padding(
            padding: const EdgeInsets.only(bottom: 16),
            child: PokemonCard(pokemon: pokemon),
          );
        },
      ),
    );
  }
}
