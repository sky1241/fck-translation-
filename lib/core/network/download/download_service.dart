import 'dart:async';

class DownloadProgress {
  DownloadProgress({required this.percent, this.localPath});
  final double percent; // 0..100
  final String? localPath;
}

abstract class DownloadService {
  Stream<DownloadProgress> download(String url);
}


