import 'package:flutter/material.dart';
import 'package:connectivity_plus/connectivity_plus.dart';

class NetworkTestScreen extends StatefulWidget {
  const NetworkTestScreen({super.key});

  @override
  State<NetworkTestScreen> createState() => _NetworkTestScreenState();
}

class _NetworkTestScreenState extends State<NetworkTestScreen> {
  String _connectionStatus = 'Vérification en cours...';
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _checkConnectivity();
  }

  Future<void> _checkConnectivity() async {
    setState(() {
      _isLoading = true;
    });

    try {
      final connectivityResults = await Connectivity().checkConnectivity();
      final connectivityResult =
          connectivityResults.firstOrNull ?? ConnectivityResult.none;

      if (connectivityResult == ConnectivityResult.none) {
        setState(() {
          _connectionStatus = 'Aucune connexion réseau détectée';
        });
      } else {
        String connectionType = connectivityResult.toString().split('.').last;

        setState(() {
          _connectionStatus = 'Connecté via: $connectionType';
        });
      }
    } catch (e) {
      setState(() {
        _connectionStatus = 'Erreur lors de la vérification: $e';
      });
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Test de Connectivité'),
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.network_check, size: 64, color: Colors.blue),
            const SizedBox(height: 24),
            const Text(
              'État de la connexion réseau',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            if (_isLoading)
              const CircularProgressIndicator()
            else
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Text(
                    _connectionStatus,
                    style: const TextStyle(fontSize: 16),
                    textAlign: TextAlign.center,
                  ),
                ),
              ),
            const SizedBox(height: 32),
            ElevatedButton(
              onPressed: _isLoading ? null : _checkConnectivity,
              child: const Text('Vérifier à nouveau'),
            ),
            const SizedBox(height: 16),
            const Text(
              'Si vous voyez "Aucune connexion réseau", vérifiez que l\'émulateur a accès à Internet.',
              style: TextStyle(fontSize: 12, color: Colors.grey),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}
