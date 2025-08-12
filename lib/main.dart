import 'package:flutter/material.dart';
import 'package:flutter_stripe/flutter_stripe.dart';
import 'package:shop/route/route_constants.dart';
import 'package:shop/route/router.dart' as router;
import 'package:shop/theme/app_theme.dart';
import 'package:shop/services/network.dart';
import 'package:shop/theme/theme_service.dart';
import 'package:provider/provider.dart';
import 'package:app_links/app_links.dart';
import 'dart:async';

// Ajoute une clé globale pour la navigation
final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  Stripe.publishableKey = 'pk_test_51RYMZeFRMHKEhCilAjCr5LlXKdlKyO11Gh4Q14y2oez4qk5Zqs4taQRBZIH2kR3MdAByFV1gdLMlQak2Gblk1CZ700slcMjQWp';

  await initializeNetwork();
  await Stripe.instance.applySettings();

  runApp(
    ChangeNotifierProvider(
      create: (context) => ThemeService(),
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  StreamSubscription<Uri>? _sub;
  final AppLinks _appLinks = AppLinks();

  @override
  void initState() {
    super.initState();
    _initDeepLinks();
  }

  void _initDeepLinks() {
    // Subscribe to all events (initial link and further)
    _sub = _appLinks.uriLinkStream.listen((Uri uri) {
      _handleDeepLink(uri);
    }, onError: (err) {
      debugPrint('Erreur deep link: $err');
    });
  }

  void _handleDeepLink(Uri uri) {
    // Handle the deep link
    if (uri.scheme == 'technoshop' && uri.host == 'reset-password') {
      final token = uri.pathSegments.isNotEmpty ? uri.pathSegments[0] : null;
      if (token != null) {
        // Use a slight delay to ensure the navigator is ready
        WidgetsBinding.instance.addPostFrameCallback((_) {
          navigatorKey.currentState?.pushNamed(
            resetPasswordScreenRoute,
            arguments: token,
          );
        });
      }
      return;
    }

    // Handle web links
    final segments = uri.pathSegments;
    if (segments.length == 2 && segments[0] == 'reset-password') {
      final token = segments[1];
      WidgetsBinding.instance.addPostFrameCallback((_) {
        navigatorKey.currentState?.pushNamed(
          resetPasswordScreenRoute,
          arguments: token,
        );
      });
    }
  }

  @override
  void dispose() {
    _sub?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<ThemeService>(
      builder: (context, themeService, child) {
        return MaterialApp(
          navigatorKey: navigatorKey,
          debugShowCheckedModeBanner: false,
          title: 'Achetez vos produits dès maintenant !',
          theme: AppTheme.lightTheme(context).copyWith(
            canvasColor: Colors.white,
            dialogBackgroundColor: Colors.white,
          ),
          darkTheme: AppTheme.darkTheme(context).copyWith(
            canvasColor: Colors.white,
            dialogBackgroundColor: Colors.white,
          ),
          themeMode: themeService.themeMode,
          onGenerateRoute: router.generateRoute,
          initialRoute: logInScreenRoute,
        );
      },
    );
  }
}