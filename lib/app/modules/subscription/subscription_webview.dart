import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:webview_flutter/webview_flutter.dart';

class SubscriptionWebView extends StatefulWidget {
  final String url;
  final VoidCallback? onComplete;

  const SubscriptionWebView({
    super.key,
    required this.url,
    this.onComplete,
  });

  @override
  State<SubscriptionWebView> createState() => _SubscriptionWebViewState();
}

class _SubscriptionWebViewState extends State<SubscriptionWebView> {
  late final WebViewController _controller;
  bool _completed = false;
  bool _browserOpened = false;

  @override
  void initState() {
    super.initState();
    _controller = WebViewController()
      ..setJavaScriptMode(JavaScriptMode.unrestricted)
      ..setUserAgent(
        'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/120.0.0.0 Safari/537.36',
      )
      ..setNavigationDelegate(
        NavigationDelegate(
          onPageStarted: (url) {
            if (_completed) return;
            final lower = url.toLowerCase();
            if (lower.contains('success') ||
                lower.contains('callback') ||
                lower.contains('return') ||
                lower.contains('thank')) {
              _completed = true;
              widget.onComplete?.call();
            }
          },
          onWebResourceError: (error) {
            // If WebView fails, try opening in external browser
            if (!_browserOpened && error.errorCode == -2) {
              _browserOpened = true;
              _openInBrowser();
            }
          },
        ),
      )
      ..loadRequest(Uri.parse(widget.url));

    // Also try opening in browser after a short delay (handles blank/black screen)
    Future.delayed(const Duration(seconds: 2), () {
      if (!_completed && !_browserOpened && mounted) {
        _browserOpened = true;
        _openInBrowser();
        Navigator.of(context).pop();
      }
    });
  }

  Future<void> _openInBrowser() async {
    final uri = Uri.parse(widget.url);
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Payment'),
        leading: IconButton(
          icon: const Icon(Icons.close),
          onPressed: () => Navigator.of(context).pop(),
        ),
      ),
      body: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const CircularProgressIndicator(),
            const SizedBox(height: 16),
            Text(
              'Opening payment page...'.tr,
              style: const TextStyle(fontSize: 16),
            ),
          ],
        ),
      ),
    );
  }
}
