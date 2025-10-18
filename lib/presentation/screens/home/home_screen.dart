import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../blocs/home/home_bloc.dart';
import '../../blocs/home/home_event.dart';
import '../../blocs/home/home_state.dart';
import '../../widgets/script_card.dart';
import '../../widgets/ad_banner_widget.dart';
import '../editor/editor_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});
  
  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final _searchController = TextEditingController();
  bool _showOnlyFavorites = false;
  
  @override
  void initState() {
    super.initState();
    context.read<HomeBloc>().add(LoadScripts());
  }
  
  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }
  
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('ProScript'),
        actions: [
          IconButton(
            icon: Icon(
              _showOnlyFavorites ? Icons.star : Icons.star_border,
            ),
            onPressed: () {
              setState(() {
                _showOnlyFavorites = !_showOnlyFavorites;
              });
              context.read<HomeBloc>().add(FilterFavorites(_showOnlyFavorites));
            },
          ),
          IconButton(
            icon: const Icon(Icons.settings),
            onPressed: () => Navigator.pushNamed(context, '/settings'),
          ),
        ],
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: TextField(
              controller: _searchController,
              decoration: InputDecoration(
                hintText: 'Buscar roteiros...',
                prefixIcon: const Icon(Icons.search),
                suffixIcon: _searchController.text.isNotEmpty
                    ? IconButton(
                        icon: const Icon(Icons.clear),
                        onPressed: () {
                          _searchController.clear();
                          context.read<HomeBloc>().add(const SearchScripts(''));
                        },
                      )
                    : null,
              ),
              onChanged: (value) {
                context.read<HomeBloc>().add(SearchScripts(value));
              },
            ),
          ),
          Expanded(
            child: BlocBuilder<HomeBloc, HomeState>(
              builder: (context, state) {
                if (state is HomeLoading) {
                  return const Center(child: CircularProgressIndicator());
                } else if (state is HomeLoaded) {
                  if (state.scripts.isEmpty) {
                    return Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            _showOnlyFavorites ? Icons.star_border : Icons.note_add,
                            size: 64,
                            color: Colors.grey,
                          ),
                          const SizedBox(height: 16),
                          Text(
                            _showOnlyFavorites
                                ? 'Nenhum roteiro favorito'
                                : 'Nenhum roteiro criado',
                            style: Theme.of(context).textTheme.titleLarge,
                          ),
                          const SizedBox(height: 8),
                          Text(
                            _showOnlyFavorites
                                ? 'Adicione roteiros aos favoritos'
                                : 'Toque no + para criar um novo roteiro',
                            style: Theme.of(context).textTheme.bodyMedium,
                          ),
                        ],
                      ),
                    );
                  }
                  
                  return ListView.builder(
                    itemCount: state.scripts.length,
                    itemBuilder: (context, index) {
                      final script = state.scripts[index];
                      return ScriptCard(
                        script: script,
                        onTap: () async {
                          await Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => EditorScreen(scriptId: script.id),
                            ),
                          );
                          // Reload scripts after returning
                          if (context.mounted) {
                            context.read<HomeBloc>().add(LoadScripts());
                          }
                        },
                        onDelete: () {
                          context.read<HomeBloc>().add(DeleteScript(script.id));
                        },
                        onToggleFavorite: () {
                          context.read<HomeBloc>().add(ToggleFavorite(script.id));
                        },
                      );
                    },
                  );
                } else if (state is HomeError) {
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(Icons.error_outline, size: 64, color: Colors.red),
                        const SizedBox(height: 16),
                        Text(state.message),
                        const SizedBox(height: 16),
                        ElevatedButton(
                          onPressed: () {
                            context.read<HomeBloc>().add(LoadScripts());
                          },
                          child: const Text('Tentar Novamente'),
                        ),
                      ],
                    ),
                  );
                }
                
                return const SizedBox.shrink();
              },
            ),
          ),
          const AdBannerWidget(),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () async {
          await Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => const EditorScreen(),
            ),
          );
          // Reload scripts after returning
          if (context.mounted) {
            context.read<HomeBloc>().add(LoadScripts());
          }
        },
        icon: const Icon(Icons.add),
        label: const Text('Novo Roteiro'),
      ),
    );
  }
}

