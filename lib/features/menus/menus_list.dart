import 'package:flutter/material.dart';
import '../../core/api/dio_client.dart';

class MenusTestScreen extends StatefulWidget {
  const MenusTestScreen({super.key});

  @override
  State<MenusTestScreen> createState() => _MenusTestScreenState();
}

class _MenusTestScreenState extends State<MenusTestScreen> {
  String _status = "Loading...";
  DioClient? _dioClient;

  @override
  void initState() {
    super.initState();
    _initDio();
  }

  Future<void> _initDio() async {
    try {
      _dioClient = await DioClient.create();
      _load();
    } catch (e) {
      setState(() => _status = "ERROR initializing Dio ❌ $e");
    }
  }

  Future<void> _load() async {
    if (_dioClient == null) return;

    try {
      final res = await _dioClient!.dio.get("/menus");
      debugPrint("API Response: ${res.data}");
      debugPrint("Response type: ${res.data.runtimeType}");

      // Gestion de différents formats de réponse
      if (res.data is List) {
        final list = res.data as List;
        setState(() => _status = "OK ✅ ${list.length} menus (direct list)");
      } else if (res.data is Map<String, dynamic>) {
        final map = res.data as Map<String, dynamic>;
        // Essaie différentes clés possibles
        if (map.containsKey('data')) {
          final list = map['data'] as List;
          setState(() => _status = "OK ✅ ${list.length} menus (from data)");
        } else if (map.containsKey('menus')) {
          final list = map['menus'] as List;
          setState(() => _status = "OK ✅ ${list.length} menus (from menus)");
        } else if (map.containsKey('items')) {
          final list = map['items'] as List;
          setState(() => _status = "OK ✅ ${list.length} menus (from items)");
        } else {
          setState(
            () =>
                _status =
                    "API returns object with keys: ${map.keys.join(', ')}",
          );
        }
      } else {
        setState(
          () => _status = "Unexpected data type: ${res.data.runtimeType}",
        );
      }
    } catch (e) {
      setState(() => _status = "ERROR ❌ $e");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("API Test")),
      body: Center(child: Text(_status, textAlign: TextAlign.center)),
    );
  }
}
