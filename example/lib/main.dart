import 'package:flutter/material.dart';

// The spec defines its own ConnectionState enum; hide it in favor of Flutter's.
import 'generated/resource_scheduler.api.dart' hide ConnectionState;

void main() {
  runApp(const ExampleApp());
}

class ExampleApp extends StatelessWidget {
  const ExampleApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Swagger Generator Example',
      theme: ThemeData(
        colorScheme: .fromSeed(seedColor: Colors.deepPurple),
      ),
      home: const AssetListPage(),
    );
  }
}

class AssetListPage extends StatefulWidget {
  const AssetListPage({super.key});

  @override
  State<AssetListPage> createState() => _AssetListPageState();
}

class _AssetListPageState extends State<AssetListPage> {
  // Point this at a real backend to get data; against the placeholder URL
  // the request fails and the error state is shown.
  final ResourceSchedulerApi _api = ResourceSchedulerApi(
    baseUrl: Uri.parse('https://api.example.com'),
  );

  late Future<List<Asset>> _assets = _loadAssets();

  Future<List<Asset>> _loadAssets() async {
    final response = await _api.listAssets(accountId: 1);
    if (!response.isSuccessful) {
      throw Exception('Request failed with status ${response.statusCode}');
    }
    return response.body ?? const [];
  }

  void _reload() {
    setState(() {
      _assets = _loadAssets();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Assets')),
      body: FutureBuilder<List<Asset>>(
        future: _assets,
        builder: (context, snapshot) {
          if (snapshot.connectionState != ConnectionState.done) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            return Center(
              child: Column(
                mainAxisAlignment: .center,
                children: [
                  Text('Failed to load assets: ${snapshot.error}'),
                  TextButton(
                    onPressed: _reload,
                    child: const Text('Retry'),
                  ),
                ],
              ),
            );
          }
          final assets = snapshot.data ?? const [];
          if (assets.isEmpty) {
            return const Center(child: Text('No assets'));
          }
          return ListView.builder(
            itemCount: assets.length,
            itemBuilder: (context, index) {
              final asset = assets[index];
              return ListTile(
                title: Text(asset.assetId),
                subtitle: Text('Last seen: ${asset.lastSeen}'),
              );
            },
          );
        },
      ),
    );
  }
}
