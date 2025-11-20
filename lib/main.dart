import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'providers/sales_provider.dart';
import 'providers/auth_provider.dart';
import 'screens/home_screen_new.dart';
import 'screens/login_screen.dart';
import 'screens/username_setup_screen.dart';
import 'theme/app_theme.dart';
import 'theme/theme_provider.dart';
import 'app_config.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  await Supabase.initialize(
    url: AppConfig.supabaseUrl,
    anonKey: AppConfig.supabaseAnonKey,
  );
  
  runApp(const BazarSalesApp());
}

class BazarSalesApp extends StatelessWidget {
  const BazarSalesApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => ThemeProvider(initialMode: ThemeMode.dark)),
        ChangeNotifierProvider(create: (_) => AuthProvider()),
        ChangeNotifierProvider(create: (_) => SalesProvider()),
      ],
      child: Consumer<ThemeProvider>(
        builder: (context, themeProvider, _) {
          return MaterialApp(
            title: 'Bazar Sales',
            debugShowCheckedModeBanner: false,
            theme: AppTheme.lightTheme,
            darkTheme: AppTheme.darkTheme,
            themeMode: themeProvider.themeMode,
            home: const AuthWrapper(),
          );
        },
      ),
    );
  }
}

class AuthWrapper extends StatelessWidget {
  const AuthWrapper({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<AuthProvider>(
      builder: (context, authProvider, _) {
        if (!authProvider.isAuthenticated) {
          return const LoginScreen();
        }
        
        // Wait for profile to load before checking username setup
        if (authProvider.isLoadingProfile) {
          return Scaffold(
            body: Center(
              child: CircularProgressIndicator(
                color: Theme.of(context).colorScheme.primary,
              ),
            ),
          );
        }
        
        // Check if user needs to set up username
        if (authProvider.needsUsernameSetup) {
          return const UsernameSetupScreen();
        }
        
        return const HomeScreenNew();
      },
    );
  }
}

