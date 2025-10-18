import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../blocs/editor/editor_bloc.dart';
import '../../blocs/editor/editor_event.dart';
import '../../blocs/editor/editor_state.dart';
import '../../widgets/ad_banner_widget.dart';
import '../teleprompter/teleprompter_screen.dart';
import '../../../di/injector.dart';

class EditorScreen extends StatelessWidget {
  final String? scriptId;
  
  const EditorScreen({super.key, this.scriptId});
  
  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => getIt<EditorBloc>()..add(LoadScript(scriptId: scriptId)),
      child: _EditorScreenContent(),
    );
  }
}

class _EditorScreenContent extends StatefulWidget {
  @override
  State<_EditorScreenContent> createState() => _EditorScreenContentState();
}

class _EditorScreenContentState extends State<_EditorScreenContent> {
  final _titleController = TextEditingController();
  final _contentController = TextEditingController();
  bool _isInitialized = false;
  
  @override
  void dispose() {
    _titleController.dispose();
    _contentController.dispose();
    super.dispose();
  }
  
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Editor'),
        actions: [
          BlocBuilder<EditorBloc, EditorState>(
            builder: (context, state) {
              if (state is EditorReady && state.hasUnsavedChanges) {
                return IconButton(
                  icon: const Icon(Icons.save),
                  onPressed: () {
                    context.read<EditorBloc>().add(SaveScript());
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Roteiro salvo!')),
                    );
                  },
                );
              }
              return const SizedBox.shrink();
            },
          ),
          BlocBuilder<EditorBloc, EditorState>(
            builder: (context, state) {
              if (state is EditorReady && state.script.content.isNotEmpty) {
                return IconButton(
                  icon: const Icon(Icons.play_circle_outline),
                  onPressed: () {
                    // Save before opening teleprompter
                    context.read<EditorBloc>().add(SaveScript());
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => TeleprompterScreen(
                          content: state.script.content,
                        ),
                      ),
                    );
                  },
                );
              }
              return const SizedBox.shrink();
            },
          ),
        ],
      ),
      body: BlocConsumer<EditorBloc, EditorState>(
        listener: (context, state) {
          if (state is EditorReady && !_isInitialized) {
            _titleController.text = state.script.title;
            _contentController.text = state.script.content;
            _isInitialized = true;
          }
          if (state is EditorError) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text(state.message)),
            );
          }
        },
        builder: (context, state) {
          if (state is EditorLoading) {
            return const Center(child: CircularProgressIndicator());
          } else if (state is EditorReady) {
            return Column(
              children: [
                Padding(
                  padding: const EdgeInsets.all(16),
                  child: TextField(
                    controller: _titleController,
                    decoration: const InputDecoration(
                      hintText: 'Título do roteiro',
                      border: InputBorder.none,
                    ),
                    style: Theme.of(context).textTheme.headlineSmall,
                    onChanged: (value) {
                      context.read<EditorBloc>().add(UpdateTitle(value));
                    },
                  ),
                ),
                const Divider(),
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: TextField(
                      controller: _contentController,
                      decoration: const InputDecoration(
                        hintText: 'Escreva seu roteiro aqui...',
                        border: InputBorder.none,
                      ),
                      style: Theme.of(context).textTheme.bodyLarge,
                      maxLines: null,
                      expands: true,
                      textAlignVertical: TextAlignVertical.top,
                      onChanged: (value) {
                        context.read<EditorBloc>().add(UpdateContent(value));
                      },
                    ),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(16),
                  child: Row(
                    children: [
                      Icon(
                        state.hasUnsavedChanges
                            ? Icons.circle
                            : Icons.check_circle,
                        size: 12,
                        color: state.hasUnsavedChanges
                            ? Colors.orange
                            : Colors.green,
                      ),
                      const SizedBox(width: 8),
                      Text(
                        state.hasUnsavedChanges
                            ? 'Salvando...'
                            : 'Salvo',
                        style: Theme.of(context).textTheme.bodySmall,
                      ),
                      const Spacer(),
                      Text(
                        '${state.script.content.split(' ').length} palavras',
                        style: Theme.of(context).textTheme.bodySmall,
                      ),
                    ],
                  ),
                ),
                const AdBannerWidget(),
              ],
            );
          }
          
          return const SizedBox.shrink();
        },
      ),
    );
  }
}

