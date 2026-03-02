import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import 'core/router/app_router.dart';
import 'core/theme/app_theme.dart';
import 'core/utils/simple_bloc_observer.dart';
import 'features/auth/bloc/auth_bloc.dart';
import 'features/inventory/bloc/inventory_bloc.dart';
import 'features/inventory/data/repositories/inventory_repository.dart';

import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);

  Bloc.observer = SimpleBlocObserver();

  runApp(const FancyShopAdminApp());
}

class FancyShopAdminApp extends StatelessWidget {
  const FancyShopAdminApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider<AuthBloc>(create: (_) => AuthBloc()),
        BlocProvider<InventoryBloc>(
          create: (_) => InventoryBloc(InventoryRepository()),
        ),
      ],
      child: const _AppView(),
    );
  }
}

class _AppView extends StatefulWidget {
  const _AppView();

  @override
  State<_AppView> createState() => _AppViewState();
}

class _AppViewState extends State<_AppView> {
  late final GoRouter _router;

  @override
  void initState() {
    super.initState();
    // Cache the router instance so it's not recreated on hot reload.
    // This prevents the app from resetting to the initial route.
    _router = AppRouter.router(context);
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      title: 'Fancy Shop Admin',
      debugShowCheckedModeBanner: false,

      // ── System-adaptive theme ─────────────────────────────────────────
      theme: AppTheme.lightTheme,
      darkTheme: AppTheme.darkTheme,
      themeMode: ThemeMode.system,

      routerConfig: _router,
    );
  }
}
