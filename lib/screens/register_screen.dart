import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';

class RegisterScreen extends StatelessWidget {
  const RegisterScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Crear Cuenta"),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            const TextField(
              decoration: InputDecoration(
                labelText: "Nombre",
              ),
            ),
            const SizedBox(height: 10),
            const TextField(
              decoration: InputDecoration(
                labelText: "Correo",
              ),
            ),
            const SizedBox(height: 10),
            const TextField(
              decoration: InputDecoration(
                labelText: "Contraseña",
              ),
              obscureText: true,
            ),
            const SizedBox(height: 20),

            ElevatedButton(
              onPressed: () {},
              child: const Text("Registrarse"),
            ),
            ElevatedButton.icon(
            onPressed: () async {
              await signInWithGoogle();
            },
            icon: Image.network(
              'https://cdn-icons-png.flaticon.com/512/281/281764.png',
              height: 24,
            ),
            label: const Text("Continuar con Google"),
          ),
          ],
        ),
      ),
    );
  }
}
Future<UserCredential?> signInWithGoogle() async {
  try {
    final GoogleSignIn googleSignIn = GoogleSignIn();
    final GoogleSignInAccount? googleUser =
        await googleSignIn.signIn();

    if (googleUser == null) return null;

    final GoogleSignInAuthentication googleAuth =
        await googleUser.authentication;

    final credential = GoogleAuthProvider.credential(
      accessToken: googleAuth.accessToken,
      idToken: googleAuth.idToken,
    );

    return await FirebaseAuth.instance
        .signInWithCredential(credential);

  } on FirebaseAuthException catch (e) {

    if (e.code == 'account-exists-with-different-credential') {
      debugPrint("⚠️ Esta cuenta ya existe con otro método de login");
    } else {
      debugPrint("Error: ${e.message}");
    }

    return null;
  }
}