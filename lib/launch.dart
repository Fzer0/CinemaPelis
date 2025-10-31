import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  Future<void> _launchURL(String urlString) async {
    final Uri url = Uri.parse(urlString);
    if (await canLaunchUrl(url)) {
      await launchUrl(url);
    } else {
      throw 'No se pudo lanzar la URL: $urlString';
    }
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        appBar: AppBar(title: const Text('Lanzar URL')),
        body: Center(
          child: ElevatedButton(
            onPressed: () {
              _launchURL('https://www.cinemap.com');
            },
            child: const Text('Abrir Ejemplo'),
          ),
        ),
      ),
    );
  }
}
