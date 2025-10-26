import 'package:record/record.dart';
import 'package:path_provider/path_provider.dart';
import 'dart:io';
import '../../features/chat/data/models/attachment.dart';

class AudioRecorderService {
  final AudioRecorder _recorder = AudioRecorder();
  bool _isRecording = false;
  String? _currentPath;

  bool get isRecording => _isRecording;

  /// Démarrer l'enregistrement audio
  Future<bool> startRecording() async {
    try {
      // Vérifier la permission
      if (await _recorder.hasPermission() == false) {
        print('[AudioRecorder] ❌ Permission denied');
        return false;
      }

      // Créer un fichier temporaire
      final Directory tempDir = await getTemporaryDirectory();
      final String timestamp = DateTime.now().microsecondsSinceEpoch.toString();
      _currentPath = '${tempDir.path}/audio_$timestamp.m4a';

      // Démarrer l'enregistrement
      await _recorder.start(
        const RecordConfig(
          encoder: AudioEncoder.aacLc,
          bitRate: 128000,
          sampleRate: 44100,
        ),
        path: _currentPath!,
      );

      _isRecording = true;
      print('[AudioRecorder] ✅ Recording started: $_currentPath');
      return true;
    } catch (e) {
      print('[AudioRecorder] ❌ Error starting recording: $e');
      _isRecording = false;
      return false;
    }
  }

  /// Arrêter l'enregistrement et retourner le fichier
  Future<AttachmentDraft?> stopRecording() async {
    if (!_isRecording) {
      print('[AudioRecorder] ⚠️ Not recording');
      return null;
    }

    try {
      final String? path = await _recorder.stop();
      _isRecording = false;

      if (path == null || path.isEmpty) {
        print('[AudioRecorder] ❌ No recording path');
        return null;
      }

      // Vérifier que le fichier existe
      final File file = File(path);
      if (!await file.exists()) {
        print('[AudioRecorder] ❌ Recording file not found: $path');
        return null;
      }

      // Obtenir la taille
      final int size = await file.length();
      
      print('[AudioRecorder] ✅ Recording stopped: $path ($size bytes)');

      return AttachmentDraft(
        kind: AttachmentKind.audio,
        sourcePath: path,
        mimeType: 'audio/m4a',
        estimatedBytes: size,
      );
    } catch (e) {
      print('[AudioRecorder] ❌ Error stopping recording: $e');
      _isRecording = false;
      return null;
    }
  }

  /// Annuler l'enregistrement en cours
  Future<void> cancelRecording() async {
    if (_isRecording) {
      try {
        await _recorder.stop();
        _isRecording = false;
        
        // Supprimer le fichier temporaire
        if (_currentPath != null) {
          final File file = File(_currentPath!);
          if (await file.exists()) {
            await file.delete();
          }
        }
        
        print('[AudioRecorder] 🗑️ Recording canceled');
      } catch (e) {
        print('[AudioRecorder] ❌ Error canceling: $e');
      }
    }
  }

  /// Libérer les ressources
  Future<void> dispose() async {
    await _recorder.dispose();
  }
}

