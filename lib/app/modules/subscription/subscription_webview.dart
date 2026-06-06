import 'package:flutter/material.dart';
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

  @override
  void initState() {
    super.initState();
    _controller = WebViewController()
      ..setJavaScriptMode(JavaScriptMode.unrestricted)
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
        ),
      )
      ..loadRequest(Uri.parse(widget.url));
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
      body: WebViewWidget(controller: _controller),
    );
  }
}
