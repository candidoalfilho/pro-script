import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../blocs/settings/settings_bloc.dart';
import '../../blocs/settings/settings_event.dart';
import '../../blocs/settings/settings_state.dart';
import '../../../core/constants/app_constants.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});
  
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Configurações'),
      ),
      body: BlocBuilder<SettingsBloc, SettingsState>(
        builder: (context, state) {
          if (state is SettingsLoading) {
            return const Center(child: CircularProgressIndicator());
          } else if (state is SettingsLoaded) {
            final settings = state.settings;
            
            return ListView(
              children: [
                _buildSection(
                  context,
                  title: 'Aparência',
                  children: [
                    SwitchListTile(
                      title: const Text('Tema Escuro'),
                      subtitle: const Text('Ativar modo escuro'),
                      value: settings.isDarkMode,
                      onChanged: (value) {
                        context.read<SettingsBloc>().add(ToggleTheme());
                      },
                    ),
                  ],
                ),
                
                const Divider(),
                
                _buildSection(
                  context,
                  title: 'Teleprompter',
                  children: [
                    ListTile(
                      title: const Text('Velocidade de Rolagem'),
                      subtitle: Slider(
                        value: settings.scrollSpeed,
                        min: AppConstants.minScrollSpeed,
                        max: AppConstants.maxScrollSpeed,
                        divisions: 19,
                        label: settings.scrollSpeed.toInt().toString(),
                        onChanged: (value) {
                          context.read<SettingsBloc>().add(UpdateScrollSpeed(value));
                        },
                      ),
                    ),
                    
                    ListTile(
                      title: const Text('Tamanho da Fonte'),
                      subtitle: Slider(
                        value: settings.fontSize,
                        min: AppConstants.minFontSize,
                        max: AppConstants.maxFontSize,
                        divisions: 20,
                        label: settings.fontSize.toInt().toString(),
                        onChanged: (value) {
                          context.read<SettingsBloc>().add(UpdateFontSize(value));
                        },
                      ),
                    ),
                    
                    ListTile(
                      title: const Text('Margens'),
                      subtitle: Slider(
                        value: settings.margin,
                        min: 0,
                        max: 100,
                        divisions: 20,
                        label: settings.margin.toInt().toString(),
                        onChanged: (value) {
                          context.read<SettingsBloc>().add(UpdateMargin(value));
                        },
                      ),
                    ),
                    
                    SwitchListTile(
                      title: const Text('Espelhamento Horizontal'),
                      subtitle: const Text('Inverter texto horizontalmente'),
                      value: settings.horizontalMirror,
                      onChanged: (value) {
                        context.read<SettingsBloc>().add(ToggleHorizontalMirror());
                      },
                    ),
                    
                    SwitchListTile(
                      title: const Text('Espelhamento Vertical'),
                      subtitle: const Text('Inverter texto verticalmente'),
                      value: settings.verticalMirror,
                      onChanged: (value) {
                        context.read<SettingsBloc>().add(ToggleVerticalMirror());
                      },
                    ),
                  ],
                ),
                
                const Divider(),
                
                _buildSection(
                  context,
                  title: 'Sobre',
                  children: [
                    ListTile(
                      title: const Text('Versão'),
                      subtitle: Text(AppConstants.appVersion),
                    ),
                    ListTile(
                      title: const Text('Sobre o ProScript'),
                      subtitle: const Text('Teleprompter profissional de bolso'),
                      trailing: const Icon(Icons.info_outline),
                      onTap: () {
                        showAboutDialog(
                          context: context,
                          applicationName: AppConstants.appName,
                          applicationVersion: AppConstants.appVersion,
                          applicationIcon: const Icon(Icons.article, size: 48),
                          children: [
                            const Text(
                              'ProScript é um aplicativo de teleprompter '
                              'inteligente, ideal para criadores de conteúdo, '
                              'professores, jornalistas e apresentadores.',
                            ),
                          ],
                        );
                      },
                    ),
                  ],
                ),
              ],
            );
          } else if (state is SettingsError) {
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
                      context.read<SettingsBloc>().add(LoadSettings());
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
    );
  }
  
  Widget _buildSection(
    BuildContext context, {
    required String title,
    required List<Widget> children,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
          child: Text(
            title,
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        ...children,
      ],
    );
  }
}

