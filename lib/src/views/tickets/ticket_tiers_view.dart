import 'package:flutter/material.dart';
// import 'package:url_launcher/url_launcher.dart';
import 'package:webview_flutter/webview_flutter.dart';

class TicketTiers extends StatelessWidget {
  const TicketTiers({super.key});

  // final controller = WebViewController()
  //   ..setJavaScriptMode(JavaScriptMode.unrestricted)
  //   ..setBackgroundColor(const Color(0x00000000))
  //   ..setNavigationDelegate(
  //     NavigationDelegate(
  //       onProgress: (int progress) {
  //         // Update loading bar.
  //       },
  //       onPageStarted: (String url) {},
  //       onPageFinished: (String url) {},
  //       onWebResourceError: (WebResourceError error) {},
  //       onNavigationRequest: (NavigationRequest request) {
  //         if (request.url.startsWith('https://www.youtube.com/')) {
  //           return NavigationDecision.prevent;
  //         }
  //         return NavigationDecision.navigate;
  //       },
  //     ),
  //   )
  //   ..loadRequest(Uri.parse('https://flutter.dev'));

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.close),
          onPressed: () {
            Navigator.of(context).pop(); // Go back to previous screen
          },
        ),
        backgroundColor: Colors.black, // Adjust the color as needed
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          //mainAxisSize: MainAxisSize.min,
          children: [
            
            const Spacer(flex: 1),
            ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 300),
              child: ElevatedButton(
                onPressed: _launchURL,
                style: ElevatedButton.styleFrom(
                  minimumSize: const Size.fromHeight(130),
                ),
                child: const Padding(
                  padding: EdgeInsets.symmetric(horizontal: 48, vertical: 16),
                  child: Text(
                    'Tier 1',
                    style: TextStyle(fontSize: 18),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 24),
            ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 300),
              child: OutlinedButton(
                onPressed: () {},
                style: OutlinedButton.styleFrom(
                  minimumSize: const Size.fromHeight(130),
                ),
                child: const Padding(
                  padding: EdgeInsets.symmetric(horizontal: 48, vertical: 16),
                  child: Text(
                    'Tier 2',
                    style: TextStyle(fontSize: 18),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 24),
            ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 300),
              child: OutlinedButton(
                onPressed: _launchURL,
                style: OutlinedButton.styleFrom(
                  minimumSize: const Size.fromHeight(130),
                ),
                child: const Padding(
                  padding: EdgeInsets.symmetric(horizontal: 48, vertical: 16),
                  child: Text(
                    'Tier 3',
                    style: TextStyle(fontSize: 18),
                  ),
                ),
              ),
            ),
            const Spacer(),
          ],
        ),
      ),
    );
  }

  Future<void> _launchURL() async {
    final Uri url =
        Uri.parse('https://arcadia-example-app.bubbleapps.io/version-test');
    // if (await canLaunchUrl(url)) {
    //   await launchUrl(url, mode: LaunchMode.externalApplication);
    // } else {
    //   throw 'Could not launch $url';
    // }
  }
}
