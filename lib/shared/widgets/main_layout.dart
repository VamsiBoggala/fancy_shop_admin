import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'admin_sidebar.dart';

class MainLayout extends StatelessWidget {
  final Widget child;

  const MainLayout({super.key, required this.child});

  @override
  Widget build(BuildContext context) {
    // Get the current location to pass to the sidebar for active state
    final String location = GoRouterState.of(context).matchedLocation;

    return Scaffold(
      body: Row(
        children: [
          AdminSidebar(currentRoute: location),
          Expanded(child: child),
        ],
      ),
    );
  }
}
