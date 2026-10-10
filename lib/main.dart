import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:provider/provider.dart';
import 'providers/auth_provider.dart';
import 'screens/main_shell.dart';
import 'screens/auth/login_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Supabase.initialize(
    url: 'https://fkibdgbqgjlgzkznsqwx.supabase.co',
    anonKey: 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6ImZraWJkZ2JxZ2psZ3prem5zcXd4Iiwicm9sZSI6ImFub24iLCJpYXQiOjE3OTE2NjQxNzUsImV4cCI6MjEwNzI0MDE3NX0.n5PDU4b3K8I64S62c0qMf_BT-wq_9vrFwlyPjoUnB64',
  );
  runApp(const CloUPBIApp());
}

class CloUPBIApp extends StatelessWidget {
  const CloUPBIApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => AuthProvider(),
      child: MaterialApp(
        title: 'CloUP BI',
        debugShowCheckedModeBanner: false,
        theme: ThemeData(
          useMaterial3: true,
          colorScheme: ColorScheme.fromSeed(
            seedColor: const Color(0xFFE1306C),
            brightness: Brightness.light,
          ),
          scaffoldBackgroundColor: Colors.white,
          appBarTheme: const AppBarTheme(
            backgroundColor: Colors.white,
            foregroundColor: Colors.black,
            elevation: 0,
          ),
        ),
        home: Consumer<AuthProvider>(
          builder: (context, auth, _) {
            if (auth.isLoggedIn) {
              return const MainShell();
            }
            return const LoginScreen();
          },
        ),
      ),
    );
  }
}
