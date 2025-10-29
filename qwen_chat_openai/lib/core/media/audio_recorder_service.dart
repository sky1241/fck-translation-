import 'dart:async';
import 'dart:io';
import 'package:record/record.dart';
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';

/// Service pour gérer l'enregistrement audio avec le plugin record
class AudioRecorderService {
  final AudioRecorder _recorder = AudioRecorder();
  
  bool _isRecording = false;
  String? _currentPath;
  Timer? _durationTimer;
  int _durationSeconds = 0;

  bool get isRecording => _isRecording;
  int get durationSeconds => _durationSeconds;
  String? get currentPath => _currentPath;

  /// Vérifier et demander la permission microphone
  Future<bool> checkPermission() async {
    final status = await Permission.microphone.request();
    return status.isGranted;
  }

  /// Démarrer l'enregistrement
  Future<bool> startRecording() async {
    if (_isRecording) {
      print('[AudioRecorder] ⚠️ Already recording');
      return false;
    }
    
    // Vérifier la permission
    if (!await checkPermission()) {
      print('[AudioRecorder] ❌ Microphone permission denied');
      return false;
    }

    try {
      // Vérifier que le recorder est disponible
      if (await _recorder.hasPermission() != true) {
        print('[AudioRecorder] ❌ No recording permission');
        return false;
      }

      // Créer un nom de fichier unique
      final tempDir = await getTemporaryDirectory();
      final timestamp = DateTime.now().millisecondsSinceEpoch;
      _currentPath = '${tempDir.path}/voice_$timestamp.m4a';
      
      // Démarrer l'enregistrement avec le plugin record (nouvelle API v6)
      await _recorder.start(
        const RecordConfig(
          encoder: AudioEncoder.aacLc,
          bitRate: 128000,
          sampleRate: 44100,
        ),
        path: _currentPath!,
      );
      
      _isRecording = true;
      _durationSeconds = 0;
      
      // Timer pour suivre la durée
      _durationTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
        _durationSeconds++;
        print('[AudioRecorder] 🎤 Recording: ${_durationSeconds}s');
      });
      
      print('[AudioRecorder] ✅ Started recording: $_currentPath');
      return true;
    } catch (e) {
      print('[AudioRecorder] ❌ Error starting recording: $e');
      return false;
    }
  }

  /// Arrêter l'enregistrement et retourner le chemin du fichier
  Future<String?> stopRecording() async {
    if (!_isRecording) {
      print('[AudioRecorder] ⚠️ Not recording');
      return null;
    }
    
    try {
      // Arrêter l'enregistrement avec le plugin record
      final path = await _recorder.stop();
      
      _isRecording = false;
      _durationTimer?.cancel();
      _durationTimer = null;
      
      print('[AudioRecorder] ✅ Stopped recording: $path (duration: ${_durationSeconds}s)');
      
      final finalPath = path ?? _currentPath;
      _durationSeconds = 0;
      _currentPath = null;
      
      return finalPath;
    } catch (e) {
      print('[AudioRecorder] ❌ Error stopping recording: $e');
      return null;
    }
  }

  /// Annuler l'enregistrement en cours
  Future<void> cancelRecording() async {
    if (_isRecording) {
      try {
        // Arrêter l'enregistrement
        final path = await _recorder.stop();
        _isRecording = false;
        _durationTimer?.cancel();
        _durationTimer = null;
        
        // Supprimer le fichier temporaire
        if (path != null || _currentPath != null) {
          try {
            final filePath = path ?? _currentPath;
            if (filePath != null) {
              final file = File(filePath);
              if (await file.exists()) {
                await file.delete();
                print('[AudioRecorder] 🗑️ Deleted temp file: $filePath');
              }
            }
          } catch (e) {
            print('[AudioRecorder] ⚠️ Error deleting temp file: $e');
          }
        }
        
        _currentPath = null;
        _durationSeconds = 0;
        print('[AudioRecorder] 📛 Recording canceled');
      } catch (e) {
        print('[AudioRecorder] Error canceling: $e');
        _isRecording = false;
        _durationTimer?.cancel();
        _durationTimer = null;
        _currentPath = null;
        _durationSeconds = 0;
      }
    }
  }

  /// Libérer les ressources
  Future<void> dispose() async {
    if (_isRecording) {
      await cancelRecording();
    }
    await _recorder.dispose();
  }
}
