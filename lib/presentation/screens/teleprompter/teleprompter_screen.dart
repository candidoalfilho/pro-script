import 'dart:async';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:camera/camera.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:path_provider/path_provider.dart';
import 'package:gal/gal.dart';
import 'package:share_plus/share_plus.dart';
import 'package:cross_file/cross_file.dart';
import '../../blocs/teleprompter/teleprompter_bloc.dart';
import '../../blocs/teleprompter/teleprompter_event.dart';
import '../../blocs/teleprompter/teleprompter_state.dart';
import '../../blocs/settings/settings_bloc.dart';
import '../../blocs/settings/settings_event.dart';
import '../../blocs/settings/settings_state.dart';
import '../../../core/services/ad_service.dart';
import '../../../di/injector.dart';

class TeleprompterScreen extends StatelessWidget {
  final String content;
  final String? scriptTitle;
  
  const TeleprompterScreen({
    super.key, 
    required this.content,
    this.scriptTitle,
  });
  
  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => getIt<TeleprompterBloc>()..add(StartTeleprompter(content)),
      child: _TeleprompterScreenContent(
        content: content,
        scriptTitle: scriptTitle,
      ),
    );
  }
}

class _TeleprompterScreenContent extends StatefulWidget {
  final String content;
  final String? scriptTitle;
  
  const _TeleprompterScreenContent({
    required this.content,
    this.scriptTitle,
  });
  
  @override
  State<_TeleprompterScreenContent> createState() => _TeleprompterScreenContentState();
}

class _TeleprompterScreenContentState extends State<_TeleprompterScreenContent>
    with SingleTickerProviderStateMixin {
  final ScrollController _scrollController = ScrollController();
  AnimationController? _animationController;
  Animation<double>? _animation;
  
  // Camera variables
  CameraController? _cameraController;
  bool _isCameraInitialized = false;
  bool _isRecording = false;
  bool _showCamera = false;
  List<CameraDescription>? _cameras;
  
  // Countdown
  int _countdown = 3;
  bool _isCountingDown = false;
  
  // Recording timer
  Timer? _recordingTimer;
  int _recordingSeconds = 0;
  
  // Controls panel
  bool _showControls = false;
  
  @override
  void initState() {
    super.initState();
    // Hide system UI for immersive experience (TELA CHEIA)
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersiveSticky);
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
      DeviceOrientation.landscapeLeft,
      DeviceOrientation.landscapeRight,
    ]);
    
    // Show interstitial ad
    AdService().showInterstitialAd();
    
    // Start countdown
    _startCountdown();
  }
  
  @override
  void dispose() {
    _animationController?.dispose();
    _scrollController.dispose();
    _cameraController?.dispose();
    _recordingTimer?.cancel();
    
    // Restore system UI
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
      DeviceOrientation.portraitDown,
      DeviceOrientation.landscapeLeft,
      DeviceOrientation.landscapeRight,
    ]);
    super.dispose();
  }
  
  Future<bool> _requestCameraPermissions() async {
    final camera = await Permission.camera.request();
    final microphone = await Permission.microphone.request();
    
    if (camera.isDenied || microphone.isDenied) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Text('Permissões de câmera e microfone são necessárias'),
            action: SnackBarAction(
              label: 'Configurações',
              onPressed: () => openAppSettings(),
            ),
          ),
        );
      }
      return false;
    }
    
    return camera.isGranted && microphone.isGranted;
  }
  
  Future<void> _initializeCamera() async {
    try {
      final hasPermissions = await _requestCameraPermissions();
      if (!hasPermissions) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Permissões negadas. Câmera não disponível.')),
          );
        }
        return;
      }
      
      _cameras = await availableCameras();
      if (_cameras == null || _cameras!.isEmpty) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Nenhuma câmera disponível')),
          );
        }
        return;
      }
      
      final frontCamera = _cameras!.firstWhere(
        (camera) => camera.lensDirection == CameraLensDirection.front,
        orElse: () => _cameras!.first,
      );
      
      _cameraController = CameraController(
        frontCamera,
        ResolutionPreset.high,
        enableAudio: true,
      );
      
      await _cameraController!.initialize();
      
      if (mounted) {
        setState(() {
          _isCameraInitialized = true;
        });
        
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('✅ Câmera pronta para gravar!'),
            duration: Duration(seconds: 2),
          ),
        );
      }
    } catch (e) {
      debugPrint('Error initializing camera: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Erro ao inicializar câmera: $e')),
        );
      }
    }
  }
  
  void _startCountdown() {
    setState(() {
      _isCountingDown = true;
      _countdown = 3;
    });
    
    Timer.periodic(const Duration(seconds: 1), (timer) {
      if (_countdown > 1) {
        setState(() {
          _countdown--;
        });
      } else {
        timer.cancel();
        setState(() {
          _isCountingDown = false;
        });
        // DON'T auto-play - let user press play button
        debugPrint('⏸️ Countdown finished - waiting for user to press PLAY');
      }
    });
  }
  
  void _initializeScrolling(double speed) {
    debugPrint('🔧 _initializeScrolling called with speed: $speed');
    
    if (!mounted || !_scrollController.hasClients) {
      debugPrint('⚠️ Cannot initialize: mounted=$mounted, hasClients=${_scrollController.hasClients}');
      return;
    }
    
    final maxScroll = _scrollController.position.maxScrollExtent;
    final currentScroll = _scrollController.offset;
    final remainingScroll = maxScroll - currentScroll;
    
    debugPrint('📏 Max: $maxScroll, Current: $currentScroll, Remaining: $remainingScroll');
    
    if (remainingScroll <= 1.0) {
      debugPrint('⚠️ No more content to scroll');
      _stopScrolling();
      return;
    }
    
    // Dispose old controller if exists
    if (_animationController != null) {
      _animationController!.dispose();
      debugPrint('🗑️ Old animation controller disposed');
    }
    
    // Calculate duration based on speed (pixels per second)
    final duration = Duration(
      milliseconds: (remainingScroll / speed * 1000).toInt(),
    );
    
    debugPrint('⏱️ Duration: ${duration.inMilliseconds}ms');
    
    // Create new controller
    _animationController = AnimationController(
      vsync: this,
      duration: duration,
    );
    
    _animation = Tween<double>(
      begin: currentScroll,
      end: maxScroll,
    ).animate(
      CurvedAnimation(
        parent: _animationController!,
        curve: Curves.linear,
      ),
    );
    
    _animation!.addListener(() {
      if (_scrollController.hasClients && mounted) {
        _scrollController.jumpTo(_animation!.value);
      }
    });
    
    _animation!.addStatusListener((status) {
      if (status == AnimationStatus.completed) {
        debugPrint('✅ Animation completed');
        _stopScrolling();
        _showEndOfVideoDialog();
      }
    });
    
    // Start animation
    _animationController!.forward();
    debugPrint('▶️ Animation started!');
  }
  
  void _stopScrolling() {
    _animationController?.stop();
    context.read<TeleprompterBloc>().add(PauseTeleprompter());
  }
  
  void _showRecordingCompleteDialog(String videoPath) {
    if (!mounted) return;
    
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        backgroundColor: Colors.black87,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
          side: const BorderSide(color: Colors.white24, width: 2),
        ),
        title: const Row(
          children: [
            Icon(Icons.videocam, color: Colors.red, size: 32),
            SizedBox(width: 12),
            Text(
              'Gravação Completa!',
              style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
            ),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text(
              'Vídeo salvo na galeria do seu telefone!',
              style: TextStyle(color: Colors.white70, fontSize: 16),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
            
            // Record Again Button
            ElevatedButton.icon(
              onPressed: () {
                Navigator.pop(context);
                // Reset teleprompter
                context.read<TeleprompterBloc>().add(ResetTeleprompter());
                _scrollController.jumpTo(0);
                
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Pressione PLAY e REC para gravar novamente'),
                    duration: Duration(seconds: 3),
                    backgroundColor: Colors.blue,
                  ),
                );
              },
              icon: const Icon(Icons.replay, size: 24),
              label: const Text(
                'Gravar Novamente',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.blue,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
                minimumSize: const Size(double.infinity, 56),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
            const SizedBox(height: 12),
            
            // Share Video Button
            ElevatedButton.icon(
              onPressed: () async {
                Navigator.pop(context);
                
                // Share video file
                try {
                  await Share.shareXFiles(
                    [XFile(videoPath)],
                    text: 'Vídeo gravado com ProScript Teleprompter',
                  );
                } catch (e) {
                  debugPrint('Error sharing video: $e');
                  if (mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text('Erro ao compartilhar vídeo: $e'),
                        backgroundColor: Colors.red,
                      ),
                    );
                  }
                }
              },
              icon: const Icon(Icons.share, size: 24),
              label: const Text(
                'Compartilhar Vídeo',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.green,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
                minimumSize: const Size(double.infinity, 56),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
            const SizedBox(height: 12),
            
            // Continue Button
            TextButton(
              onPressed: () {
                Navigator.pop(context);
              },
              child: const Text(
                'Continuar',
                style: TextStyle(color: Colors.white70, fontSize: 14),
              ),
            ),
          ],
        ),
      ),
    );
  }
  
  void _showEndOfVideoDialog() {
    if (!mounted) return;
    
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        backgroundColor: Colors.black87,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
          side: const BorderSide(color: Colors.white24, width: 2),
        ),
        title: const Row(
          children: [
            Icon(Icons.check_circle, color: Colors.green, size: 32),
            SizedBox(width: 12),
            Text(
              'Script Finalizado!',
              style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
            ),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text(
              'O que deseja fazer agora?',
              style: TextStyle(color: Colors.white70, fontSize: 16),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
            
            // Record Again Button
            ElevatedButton.icon(
              onPressed: () {
                Navigator.pop(context);
                // Reset and restart
                context.read<TeleprompterBloc>().add(ResetTeleprompter());
                _scrollController.jumpTo(0);
                
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Pressione PLAY para começar novamente'),
                    duration: Duration(seconds: 2),
                    backgroundColor: Colors.blue,
                  ),
                );
              },
              icon: const Icon(Icons.replay, size: 24),
              label: const Text(
                'Gravar Novamente',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.blue,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
                minimumSize: const Size(double.infinity, 56),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
            const SizedBox(height: 12),
            
            // Save/Share Button
            ElevatedButton.icon(
              onPressed: () async {
                Navigator.pop(context);
                
                // Share script text
                try {
                  final scriptTitle = widget.scriptTitle ?? 'Meu Script';
                  await Share.share(
                    widget.content,
                    subject: scriptTitle,
                  );
                } catch (e) {
                  debugPrint('Error sharing: $e');
                  if (mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text('Erro ao compartilhar: $e'),
                        backgroundColor: Colors.red,
                      ),
                    );
                  }
                }
              },
              icon: const Icon(Icons.share, size: 24),
              label: const Text(
                'Salvar/Compartilhar Texto',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.green,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
                minimumSize: const Size(double.infinity, 56),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
            const SizedBox(height: 12),
            
            // Continue/Close Button
            TextButton(
              onPressed: () {
                Navigator.pop(context);
              },
              child: const Text(
                'Continuar Editando',
                style: TextStyle(color: Colors.white70, fontSize: 14),
              ),
            ),
          ],
        ),
      ),
    );
  }
  
  void _togglePlayPause() {
    final bloc = context.read<TeleprompterBloc>();
    final state = bloc.state;
    
    debugPrint('');
    debugPrint('═══════════════════════════════════════');
    debugPrint('🎬 TOGGLE PLAY/PAUSE CALLED');
    debugPrint('═══════════════════════════════════════');
    
    if (state is! TeleprompterReady) {
      debugPrint('⚠️ ERROR: State is not TeleprompterReady: ${state.runtimeType}');
      return;
    }
    
    final currentState = state;
    debugPrint('📊 Current BLoC State:');
    debugPrint('   - isPlaying: ${currentState.isPlaying}');
    debugPrint('   - Camera active: $_showCamera');
    debugPrint('   - Recording: $_isRecording');
    debugPrint('   - Scroll position: ${_scrollController.hasClients ? _scrollController.offset.toStringAsFixed(1) : 'N/A'}');
    debugPrint('   - Animation exists: ${_animationController != null}');
    debugPrint('   - Animation animating: ${_animationController?.isAnimating ?? false}');
    
    if (currentState.isPlaying) {
      // ═══════════════════════════════════════
      // CURRENTLY PLAYING → PAUSE
      // ═══════════════════════════════════════
      debugPrint('');
      debugPrint('⏸️ PAUSING...');
      
      // Stop animation
      if (_animationController != null && _animationController!.isAnimating) {
        _animationController!.stop();
        debugPrint('   ✅ Animation stopped');
      }
      
      // Update BLoC
      bloc.add(PauseTeleprompter());
      debugPrint('   ✅ BLoC updated to PAUSED');
      debugPrint('   📍 Final position: ${_scrollController.hasClients ? _scrollController.offset.toStringAsFixed(1) : 'N/A'}');
      debugPrint('═══════════════════════════════════════');
      
    } else {
      // ═══════════════════════════════════════
      // CURRENTLY PAUSED → PLAY
      // ═══════════════════════════════════════
      debugPrint('');
      debugPrint('▶️ PLAYING...');
      
      // Get speed
      final settingsBloc = context.read<SettingsBloc>();
      final settingsState = settingsBloc.state;
      final speed = (settingsState is SettingsLoaded) 
          ? settingsState.settings.scrollSpeed 
          : 50.0;
      
      debugPrint('   ⚙️ Speed: $speed px/s');
      
      // Update BLoC FIRST
      bloc.add(PlayTeleprompter());
      debugPrint('   ✅ BLoC updated to PLAYING');
      
      // Start scrolling DIRECTLY (no async wrappers!)
      _initializeScrolling(speed);
      debugPrint('═══════════════════════════════════════');
    }
  }
  
  void _updateSpeed(double newSpeed) {
    context.read<TeleprompterBloc>().add(UpdateSpeed(newSpeed));
    
    final state = context.read<TeleprompterBloc>().state;
    if (state is TeleprompterReady && state.isPlaying) {
      _initializeScrolling(newSpeed);
    }
  }
  
  Future<void> _toggleCamera() async {
    if (!_showCamera) {
      await _initializeCamera();
      if (_isCameraInitialized) {
        setState(() {
          _showCamera = true;
        });
      }
    } else {
      setState(() {
        _showCamera = false;
      });
      await _cameraController?.dispose();
      _cameraController = null;
      _isCameraInitialized = false;
    }
  }
  
  Future<void> _toggleRecording() async {
    if (_cameraController == null || !_isCameraInitialized) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Câmera não inicializada')),
      );
      return;
    }
    
    try {
      if (_isRecording) {
        // STOP RECORDING
        final file = await _cameraController!.stopVideoRecording();
        _recordingTimer?.cancel();
        
        setState(() {
          _isRecording = false;
          _recordingSeconds = 0;
        });
        
        debugPrint('📹 Vídeo gravado: ${file.path}');
        
        // Ensure MP4 format
        String videoPath = file.path;
        if (!videoPath.toLowerCase().endsWith('.mp4')) {
          debugPrint('🔄 Converting to MP4 format...');
          final tempDir = await getTemporaryDirectory();
          final mp4Path = '${tempDir.path}/video_${DateTime.now().millisecondsSinceEpoch}.mp4';
          
          // Copy/rename to MP4
          final originalFile = File(videoPath);
          final mp4File = await originalFile.copy(mp4Path);
          videoPath = mp4File.path;
          
          debugPrint('✅ Vídeo convertido para MP4: $videoPath');
        }
        
        // Save to gallery using Gal (saves automatically to phone gallery!)
        try {
          debugPrint('🎥 Salvando vídeo MP4 na galeria: $videoPath');
          
          // Save video to gallery (Gal handles permissions automatically)
          await Gal.putVideo(videoPath);
          debugPrint('✅ Vídeo MP4 salvo com sucesso na GALERIA DO TELEFONE!');
          
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Row(
                  children: [
                    const Icon(Icons.check_circle, color: Colors.white, size: 28),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Text(
                            '✅ VÍDEO SALVO NA GALERIA!',
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 16,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            'Abra a galeria do seu telefone para ver o vídeo',
                            style: TextStyle(
                              fontSize: 12,
                              color: Colors.white.withValues(alpha: 0.9),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                backgroundColor: Colors.green.shade700,
                duration: const Duration(seconds: 3),
                behavior: SnackBarBehavior.floating,
                margin: const EdgeInsets.all(16),
                action: SnackBarAction(
                  label: 'OK',
                  textColor: Colors.white,
                  onPressed: () {},
                ),
              ),
            );
            
            // Show dialog with options after video is saved
            Future.delayed(const Duration(milliseconds: 500), () {
              if (mounted) {
                _showRecordingCompleteDialog(videoPath);
              }
            });
          }
        } catch (e) {
          debugPrint('❌ Erro ao salvar na galeria: $e');
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Text(
                      '⚠️ Erro ao salvar na galeria',
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 4),
                    Text('Erro: $e', style: const TextStyle(fontSize: 12)),
                    const SizedBox(height: 4),
                    Text('Arquivo temporário em: $videoPath', style: const TextStyle(fontSize: 10)),
                  ],
                ),
                duration: const Duration(seconds: 5),
                backgroundColor: Colors.red.shade700,
                action: SnackBarAction(
                  label: 'Tentar Novamente',
                  textColor: Colors.white,
                  onPressed: () async {
                    try {
                      await Gal.putVideo(videoPath);
                      if (mounted) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text('✅ Vídeo salvo com sucesso!'),
                            backgroundColor: Colors.green,
                          ),
                        );
                      }
                    } catch (e2) {
                      debugPrint('❌ Falha ao tentar novamente: $e2');
                    }
                  },
                ),
              ),
            );
            
            // Show dialog even if saving failed
            Future.delayed(const Duration(milliseconds: 500), () {
              if (mounted) {
                _showRecordingCompleteDialog(videoPath);
              }
            });
          }
        }
      } else {
        // START RECORDING
        debugPrint('🎬 Iniciando gravação...');
        
        await _cameraController!.startVideoRecording();
        setState(() {
          _isRecording = true;
          _recordingSeconds = 0;
        });
        
        _recordingTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
          setState(() {
            _recordingSeconds++;
          });
        });
        
        debugPrint('🎬 Gravação iniciada!');
        
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Row(
                children: [
                  Icon(Icons.fiber_manual_record, color: Colors.red, size: 20),
                  SizedBox(width: 10),
                  Text('🎬 Gravação iniciada!'),
                ],
              ),
              duration: Duration(seconds: 2),
              backgroundColor: Colors.black87,
            ),
          );
        }
      }
    } catch (e) {
      debugPrint('❌ Error recording: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Erro ao gravar: $e'),
            backgroundColor: Colors.red,
            duration: const Duration(seconds: 4),
          ),
        );
      }
    }
  }
  
  
  String _formatRecordingTime(int seconds) {
    final minutes = seconds ~/ 60;
    final secs = seconds % 60;
    return '${minutes.toString().padLeft(2, '0')}:${secs.toString().padLeft(2, '0')}';
  }
  
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: BlocConsumer<TeleprompterBloc, TeleprompterState>(
        listener: (context, state) {
          // Don't handle play/pause here - let the button do it
          // This prevents double initialization
        },
        builder: (context, state) {
          if (state is TeleprompterReady) {
            return BlocBuilder<SettingsBloc, SettingsState>(
              builder: (context, settingsState) {
                if (settingsState is! SettingsLoaded) {
                  return const Center(child: CircularProgressIndicator());
                }
                
                final settings = settingsState.settings;
                
                return Stack(
                  children: [
                    // CONTEÚDO PRINCIPAL - TELA CHEIA
                    Positioned.fill(
                      child: Container(
                        color: Colors.black,
                        child: Transform(
                          alignment: Alignment.center,
                          transform: Matrix4.identity()
                            ..scale(
                              settings.horizontalMirror ? -1.0 : 1.0,
                              settings.verticalMirror ? -1.0 : 1.0,
                              1.0,
                            ),
                          child: SingleChildScrollView(
                            controller: _scrollController,
                            padding: EdgeInsets.symmetric(
                              horizontal: settings.margin,
                              vertical: MediaQuery.of(context).size.height * 0.3,
                            ),
                            child: Text(
                              state.content,
                              style: TextStyle(
                                fontSize: settings.fontSize,
                                color: Colors.white,
                                height: 1.8,
                                fontFamily: settings.fontFamily,
                                fontWeight: FontWeight.w500,
                              ),
                              textAlign: TextAlign.center,
                            ),
                          ),
                        ),
                      ),
                    ),
                    
                    // Countdown overlay
                    if (_isCountingDown)
                      Positioned.fill(
                        child: Container(
                          color: Colors.black87,
                          child: Center(
                            child: Text(
                              _countdown.toString(),
                              style: const TextStyle(
                                fontSize: 120,
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                              ),
                            ),
                          ),
                        ),
                      ),
                    
                    // Camera preview
                    if (_showCamera && _isCameraInitialized && _cameraController != null && !_isCountingDown)
                      Positioned(
                        top: 80,
                        right: 20,
                        child: Container(
                          width: 140,
                          height: 180,
                          decoration: BoxDecoration(
                            border: Border.all(
                              color: _isRecording ? Colors.red : Colors.white,
                              width: _isRecording ? 3 : 2,
                            ),
                            borderRadius: BorderRadius.circular(12),
                            boxShadow: [
                              BoxShadow(
                                color: _isRecording 
                                  ? Colors.red.withValues(alpha: 0.5)
                                  : Colors.black.withValues(alpha: 0.5),
                                blurRadius: 10,
                                spreadRadius: 2,
                              ),
                            ],
                          ),
                          clipBehavior: Clip.antiAlias,
                          child: CameraPreview(_cameraController!),
                        ),
                      ),
                    
                    // Recording indicator
                    if (_isRecording && !_isCountingDown)
                      Positioned(
                        top: 30,
                        left: 0,
                        right: 0,
                        child: Center(
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 20,
                              vertical: 10,
                            ),
                            decoration: BoxDecoration(
                              color: Colors.red,
                              borderRadius: BorderRadius.circular(25),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.red.withValues(alpha: 0.5),
                                  blurRadius: 10,
                                  spreadRadius: 2,
                                ),
                              ],
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                const Icon(
                                  Icons.fiber_manual_record,
                                  color: Colors.white,
                                  size: 20,
                                ),
                                const SizedBox(width: 10),
                                Text(
                                  'REC ${_formatRecordingTime(_recordingSeconds)}',
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontWeight: FontWeight.bold,
                                    fontSize: 16,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    
                    // PAINEL DE CONTROLES LATERAL
                    if (_showControls && !_isCountingDown)
                      Positioned(
                        top: 0,
                        bottom: 0,
                        left: 0,
                        child: GestureDetector(
                          onTap: () {}, // Previne fechar ao clicar no painel
                          child: Container(
                            width: 280,
                            decoration: BoxDecoration(
                              color: Colors.black.withValues(alpha: 0.95),
                              border: const Border(
                                right: BorderSide(color: Colors.white24, width: 2),
                              ),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withValues(alpha: 0.5),
                                  blurRadius: 20,
                                  spreadRadius: 5,
                                ),
                              ],
                            ),
                            child: SafeArea(
                              child: SingleChildScrollView(
                                padding: const EdgeInsets.all(20),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    // Header
                                    Row(
                                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                      children: [
                                        const Text(
                                          '⚙️ CONTROLES',
                                          style: TextStyle(
                                            color: Colors.white,
                                            fontSize: 20,
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                        IconButton(
                                          icon: const Icon(Icons.close, color: Colors.white),
                                          onPressed: () {
                                            setState(() {
                                              _showControls = false;
                                            });
                                          },
                                        ),
                                      ],
                                    ),
                                    const Divider(color: Colors.white24, height: 30),
                                    
                                    // Velocidade
                                    _buildControlSection(
                                      icon: Icons.speed,
                                      title: 'VELOCIDADE',
                                      value: '${state.speed.toInt()} px/s',
                                      currentValue: state.speed,
                                      min: 10,
                                      max: 200,
                                      onChanged: (value) {
                                        _updateSpeed(value);
                                      },
                                      onIncrement: () {
                                        final newSpeed = (state.speed + 5).clamp(10.0, 200.0);
                                        _updateSpeed(newSpeed);
                                      },
                                      onDecrement: () {
                                        final newSpeed = (state.speed - 5).clamp(10.0, 200.0);
                                        _updateSpeed(newSpeed);
                                      },
                                    ),
                                    
                                    const Divider(color: Colors.white24, height: 30),
                                    
                                    // Tamanho da Fonte
                                    _buildControlSection(
                                      icon: Icons.text_fields,
                                      title: 'TAMANHO FONTE',
                                      value: '${settings.fontSize.toInt()}pt',
                                      currentValue: settings.fontSize,
                                      min: 12,
                                      max: 72,
                                      onChanged: (value) {
                                        context.read<SettingsBloc>().add(UpdateFontSize(value));
                                      },
                                      onIncrement: () {
                                        final newSize = (settings.fontSize + 2).clamp(12.0, 72.0);
                                        context.read<SettingsBloc>().add(UpdateFontSize(newSize));
                                      },
                                      onDecrement: () {
                                        final newSize = (settings.fontSize - 2).clamp(12.0, 72.0);
                                        context.read<SettingsBloc>().add(UpdateFontSize(newSize));
                                      },
                                    ),
                                    
                                    const Divider(color: Colors.white24, height: 30),
                                    
                                    // Margens
                                    _buildControlSection(
                                      icon: Icons.border_horizontal,
                                      title: 'MARGENS',
                                      value: '${settings.margin.toInt()}px',
                                      currentValue: settings.margin,
                                      min: 0,
                                      max: 100,
                                      onChanged: (value) {
                                        context.read<SettingsBloc>().add(UpdateMargin(value));
                                      },
                                      onIncrement: () {
                                        final newMargin = (settings.margin + 4).clamp(0.0, 100.0);
                                        context.read<SettingsBloc>().add(UpdateMargin(newMargin));
                                      },
                                      onDecrement: () {
                                        final newMargin = (settings.margin - 4).clamp(0.0, 100.0);
                                        context.read<SettingsBloc>().add(UpdateMargin(newMargin));
                                      },
                                    ),
                                    
                                    const Divider(color: Colors.white24, height: 30),
                                    
                                    // Espelhamento
                                    const Text(
                                      '🪞 ESPELHAMENTO',
                                      style: TextStyle(
                                        color: Colors.white,
                                        fontSize: 14,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                    const SizedBox(height: 10),
                                    
                                    SwitchListTile(
                                      title: const Text(
                                        'Horizontal',
                                        style: TextStyle(color: Colors.white70),
                                      ),
                                      value: settings.horizontalMirror,
                                      activeColor: Colors.teal,
                                      onChanged: (value) {
                                        context.read<SettingsBloc>().add(ToggleHorizontalMirror());
                                      },
                                    ),
                                    
                                    SwitchListTile(
                                      title: const Text(
                                        'Vertical',
                                        style: TextStyle(color: Colors.white70),
                                      ),
                                      value: settings.verticalMirror,
                                      activeColor: Colors.teal,
                                      onChanged: (value) {
                                        context.read<SettingsBloc>().add(ToggleVerticalMirror());
                                      },
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),
                        ),
                      ),
                    
                    // Botão para abrir controles
                    if (!_showControls && !_isCountingDown)
                      Positioned(
                        left: 0,
                        top: MediaQuery.of(context).size.height / 2 - 40,
                        child: GestureDetector(
                          onTap: () {
                            setState(() {
                              _showControls = true;
                            });
                          },
                          child: Container(
                            width: 40,
                            height: 80,
                            decoration: BoxDecoration(
                              color: Colors.white.withValues(alpha: 0.2),
                              borderRadius: const BorderRadius.only(
                                topRight: Radius.circular(20),
                                bottomRight: Radius.circular(20),
                              ),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withValues(alpha: 0.3),
                                  blurRadius: 10,
                                ),
                              ],
                            ),
                            child: const Icon(
                              Icons.tune,
                              color: Colors.white,
                              size: 24,
                            ),
                          ),
                        ),
                      ),
                    
                    // Control buttons - ALWAYS ON TOP - WRAP LAYOUT
                    if (!_isCountingDown)
                      Positioned(
                        bottom: 10,
                        left: 0,
                        right: 0,
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 10),
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              begin: Alignment.bottomCenter,
                              end: Alignment.topCenter,
                              colors: [
                                Colors.black.withValues(alpha: 0.95),
                                Colors.black.withValues(alpha: 0.0),
                              ],
                            ),
                          ),
                          child: Wrap(
                            alignment: WrapAlignment.center,
                            spacing: 8,
                            runSpacing: 8,
                            children: [
                              // Play/Pause - PRIMEIRO E MAIOR
                              _buildControlButton(
                                icon: state.isPlaying ? Icons.pause_circle_filled : Icons.play_circle_filled,
                                onPressed: _togglePlayPause,
                                size: 65,
                                color: state.isPlaying ? Colors.orange : Colors.green,
                                label: state.isPlaying ? 'PAUSE' : 'PLAY',
                              ),
                              
                              // Camera toggle
                              _buildControlButton(
                                icon: _showCamera ? Icons.videocam : Icons.videocam_off,
                                onPressed: _toggleCamera,
                                color: _showCamera ? Colors.blue : null,
                                label: 'CAM',
                                size: 55,
                              ),
                              
                              // Record button - COR VERMELHA VIBRANTE
                              if (_showCamera && _isCameraInitialized)
                                _buildControlButton(
                                  icon: _isRecording ? Icons.stop_circle : Icons.fiber_manual_record,
                                  onPressed: _toggleRecording,
                                  color: Colors.red,
                                  size: 65,
                                  label: _isRecording ? 'STOP' : 'REC',
                                ),
                              
                              // Reset
                              _buildControlButton(
                                icon: Icons.replay,
                                onPressed: () {
                                  context.read<TeleprompterBloc>().add(ResetTeleprompter());
                                  _scrollController.jumpTo(0);
                                },
                                label: 'RESET',
                                size: 55,
                              ),
                              
                              // Close
                              _buildControlButton(
                                icon: Icons.close_fullscreen,
                                onPressed: () => Navigator.pop(context),
                                color: Colors.redAccent,
                                label: 'SAIR',
                                size: 55,
                              ),
                            ],
                          ),
                        ),
                      ),
                  ],
                );
              },
            );
          }
          
          return const Center(child: CircularProgressIndicator());
        },
      ),
    );
  }
  
  Widget _buildControlSection({
    required IconData icon,
    required String title,
    required String value,
    required double currentValue,
    required double min,
    required double max,
    required Function(double) onChanged,
    required VoidCallback onIncrement,
    required VoidCallback onDecrement,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(icon, color: Colors.teal, size: 20),
            const SizedBox(width: 8),
            Text(
              title,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 14,
                fontWeight: FontWeight.bold,
              ),
            ),
            const Spacer(),
            Text(
              value,
              style: const TextStyle(
                color: Colors.tealAccent,
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
        const SizedBox(height: 10),
        
        // Botões +/-
        Row(
          children: [
            IconButton(
              icon: const Icon(Icons.remove_circle, color: Colors.red),
              onPressed: onDecrement,
            ),
            Expanded(
              child: Slider(
                value: currentValue,
                min: min,
                max: max,
                activeColor: Colors.teal,
                inactiveColor: Colors.white24,
                onChanged: onChanged,
              ),
            ),
            IconButton(
              icon: const Icon(Icons.add_circle, color: Colors.green),
              onPressed: onIncrement,
            ),
          ],
        ),
      ],
    );
  }
  
  Widget _buildControlButton({
    required IconData icon,
    required VoidCallback onPressed,
    double size = 55,
    Color? color,
    String? label,
  }) {
    return GestureDetector(
      onTap: () {
        debugPrint('🖱️ Button tapped: $label');
        onPressed();
      },
      child: Container(
        padding: const EdgeInsets.all(8), // Larger tap target area
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: size,
              height: size,
              decoration: BoxDecoration(
                color: color ?? Colors.white.withValues(alpha: 0.3),
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: (color ?? Colors.white).withValues(alpha: 0.4),
                    blurRadius: 12,
                    spreadRadius: 2,
                  ),
                ],
                border: Border.all(
                  color: Colors.white.withValues(alpha: 0.5),
                  width: 2,
                ),
              ),
              child: Center(
                child: Icon(
                  icon,
                  color: Colors.white,
                  size: size * 0.5,
                ),
              ),
            ),
            if (label != null) ...[
              const SizedBox(height: 6),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                decoration: BoxDecoration(
                  color: Colors.black.withValues(alpha: 0.6),
                  borderRadius: BorderRadius.circular(4),
                ),
                child: Text(
                  label,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 11,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 0.5,
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
