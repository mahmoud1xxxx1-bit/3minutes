import 'dart:convert';
import 'dart:math' as math;

import 'package:archive/archive.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:webview_flutter/webview_flutter.dart';

import '../domain/mini_game_contract.dart';

class FindDifferencesHtmlGame extends StatefulWidget {
  const FindDifferencesHtmlGame({
    super.key,
    required this.config,
    required this.onComplete,
  });

  final MiniGameConfig config;
  final ValueChanged<MiniGameResult> onComplete;

  @override
  State<FindDifferencesHtmlGame> createState() => _FindDifferencesHtmlGameState();
}

class _FindDifferencesHtmlGameState extends State<FindDifferencesHtmlGame> {
  static const int _puzzleCount = 30;
  static const int _targetDifferences = 5;
  static const List<String> _archiveParts = [
    'assets/find_differences/archive_b64/part_01.txt',
    'assets/find_differences/archive_b64/part_02.txt',
    'assets/find_differences/archive_b64/part_03.txt',
    'assets/find_differences/archive_b64/part_04.txt',
    'assets/find_differences/archive_b64/part_05.txt',
    'assets/find_differences/archive_b64/part_06.txt',
    'assets/find_differences/archive_b64/part_07.txt',
    'assets/find_differences/archive_b64/part_08.txt',
  ];

  late final WebViewController _controller;
  late final Stopwatch _measurement;
  bool _done = false;
  Object? _loadError;

  int get _puzzleIndex => (widget.config.seed & 0x7fffffff) % _puzzleCount + 1;
  String get _puzzleName => 'puzzle_${_puzzleIndex.toString().padLeft(2, '0')}.html';

  @override
  void initState() {
    super.initState();
    _measurement = Stopwatch()..start();
    _controller = WebViewController()
      ..setJavaScriptMode(JavaScriptMode.unrestricted)
      ..setBackgroundColor(const Color(0xFF050914))
      ..addJavaScriptChannel(
        'FindDifferencesBridge',
        onMessageReceived: _handleBridgeMessage,
      )
      ..setNavigationDelegate(
        NavigationDelegate(
          onNavigationRequest: (request) {
            final uri = Uri.tryParse(request.url);
            if (uri == null) return NavigationDecision.prevent;
            if (uri.scheme == 'about' || uri.scheme == 'data') {
              return NavigationDecision.navigate;
            }
            return NavigationDecision.prevent;
          },
          onPageFinished: (_) => _installResultObserver(),
          onWebResourceError: (error) {
            if (!mounted || error.isForMainFrame != true) return;
            setState(() => _loadError = error.description);
          },
        ),
      );
    _loadPuzzle();
  }

  Future<void> _loadPuzzle() async {
    try {
      final encoded = StringBuffer();
      for (final part in _archiveParts) {
        encoded.write(await rootBundle.loadString(part));
      }
      final zipBytes = base64Decode(encoded.toString());
      final archive = ZipDecoder().decodeBytes(zipBytes, verify: true);
      final entry = archive.files.where((file) => file.name == _puzzleName).firstOrNull;
      if (entry == null || !entry.isFile) {
        throw StateError('Missing $_puzzleName');
      }
      final data = entry.content;
      if (data is! List<int>) {
        throw StateError('Invalid $_puzzleName content');
      }
      final original = utf8.decode(data);
      if (!mounted) return;

      // Runtime-only compatibility shim. It does not modify the stored puzzle
      // archive. puzzle_01/02 expect a #play element that is not present.
      const bootstrap = r'''
<script>
(function(){
  const realGet = document.getElementById.bind(document);
  let legacyStarted = false;
  document.getElementById = function(id){
    const element = realGet(id);
    if (element) return element;
    if (id === 'play') {
      return {
        set onclick(fn) {
          if (legacyStarted || typeof fn !== 'function') return;
          legacyStarted = true;
          setTimeout(fn, 0);
        }
      };
    }
    return null;
  };
})();
</script>
''';
      final runtimeHtml = original.contains('<head>')
          ? original.replaceFirst('<head>', '<head>$bootstrap')
          : '$bootstrap$original';
      await _controller.loadHtmlString(runtimeHtml);
    } catch (error) {
      if (!mounted) return;
      setState(() => _loadError = error);
    }
  }

  Future<void> _installResultObserver() async {
    const script = r'''
(function(){
  if (window.__threeMinutesBridgeInstalled) return;
  window.__threeMinutesBridgeInstalled = true;
  const found = document.getElementById('found');
  const mistakes = document.getElementById('mistakes');
  if (!found || !mistakes) return;
  let sent = false;
  const publishIfComplete = function(){
    if (sent) return;
    if (String(found.textContent || '').trim() !== '5/5') return;
    sent = true;
    const parsed = parseInt(String(mistakes.textContent || '0'), 10);
    FindDifferencesBridge.postMessage(JSON.stringify({
      found: 5,
      mistakes: Number.isFinite(parsed) ? parsed : 0
    }));
  };
  new MutationObserver(publishIfComplete).observe(found, {
    childList: true,
    subtree: true,
    characterData: true
  });
  publishIfComplete();
})();
''';
    try {
      await _controller.runJavaScript(script);
    } catch (_) {}
  }

  void _handleBridgeMessage(JavaScriptMessage message) {
    if (_done) return;
    try {
      final decoded = jsonDecode(message.message);
      if (decoded is! Map<String, dynamic>) return;
      if (decoded['found'] != _targetDifferences) return;
      final value = decoded['mistakes'];
      final mistakes = value is num ? math.max(0, value.toInt()) : 0;
      _finish(mistakes);
    } catch (_) {}
  }

  void _finish(int mistakes) {
    if (_done) return;
    _done = true;
    _measurement.stop();
    final attempts = _targetDifferences + mistakes;
    widget.onComplete(
      MiniGameResult(
        completed: true,
        score: math.max(0, 100 - mistakes * 4),
        accuracy: _targetDifferences / attempts,
        mistakes: mistakes,
        duration: _measurement.elapsed,
      ),
    );
  }

  @override
  void dispose() {
    _measurement.stop();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (_loadError != null) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Text(
            'Find the Differences content could not be loaded.',
            textAlign: TextAlign.center,
            style: Theme.of(context).textTheme.titleMedium,
          ),
        ),
      );
    }
    return WebViewWidget(controller: _controller);
  }
}
