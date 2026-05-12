import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'firebase_options.dart';

import 'screens/auth/register_screen.dart';
import 'screens/auth/login_screen.dart';
import 'screens/auth/pending_approval_screen.dart';
import 'screens/availability/manage_availability_screen.dart';
import 'screens/home/home_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  bool firestoreReady = false;
  try {
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );
    firestoreReady = true;
  } catch (_) {}
  runApp(CalmSpaceApp(firestoreReady: firestoreReady));
}

class CalmSpaceApp extends StatelessWidget {
  const CalmSpaceApp({super.key, required this.firestoreReady});
  final bool firestoreReady;

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'CalmSpace',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFF356859),
          brightness: Brightness.light,
        ),
        scaffoldBackgroundColor: const Color(0xFFF5F7F2),
        useMaterial3: true,
      ),
      routes: {
        '/login':        (context) => const LoginScreen(),
        '/register':     (context) => const RegisterScreen(),
        '/pending':      (context) => const PendingApprovalScreen(),
        ManageAvailabilityScreen.routeName: (context) =>
            ManageAvailabilityScreen(firestoreReady: firestoreReady),
      },
      home: StreamBuilder<User?>(
        stream: FirebaseAuth.instance.authStateChanges(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Scaffold(
              backgroundColor: Color(0xFFF5F7F2),
              body: Center(child: CircularProgressIndicator(
                  color: Color(0xFF356859))),
            );
          }

          // Sin sesión → Login
          if (!snapshot.hasData) return const LoginScreen();

          // Con sesión → verificar rol y status en Firestore
          return FutureBuilder<DocumentSnapshot>(
            future: FirebaseFirestore.instance
                .collection('users')
                .doc(snapshot.data!.uid)
                .get(),
            builder: (context, userSnap) {
              if (userSnap.connectionState == ConnectionState.waiting) {
                return const Scaffold(
                  backgroundColor: Color(0xFFF5F7F2),
                  body: Center(child: CircularProgressIndicator(
                      color: Color(0xFF356859))),
                );
              }

              if (userSnap.hasData && userSnap.data!.exists) {
                final data = userSnap.data!.data() as Map<String, dynamic>;
                final role   = data['role']   ?? 'Paciente';
                final status = data['status'] ?? 'activo';

                if (role == 'Psicólogo' && status == 'pendiente') {
                  return const PendingApprovalScreen();
                }
                if (role == 'Psicólogo' && status == 'rechazado') {
                  return const PendingApprovalScreen();
                }
              }

              return const HomeScreen();
            },
          );
        },
      ),
    );
  }
}