
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import '../core/services/api_client.dart';
import '../features/leagues/services/leagues_repository.dart';
import '../features/players/services/players_repository.dart';

class ProvidersSetup extends StatelessWidget {
  final Widget child;
  const ProvidersSetup({super.key, required this.child});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        Provider<ApiClient>(create: (_) => ApiClient(apiKey: dotenv.env['API_KEY']!)),
        ProxyProvider<ApiClient, LeaguesRepository>(
          update: (_, api, __) => LeaguesRepository(api),
        ),
        ProxyProvider<ApiClient, PlayersRepository>(
          update: (_, api, __) => PlayersRepository(api),
        ),
      ],
      child: child,
    );
  }
}
