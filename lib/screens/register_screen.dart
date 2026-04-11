import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:google_sign_in/google_sign_in.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  bool _isLoading = false;

  feature/HU-03-login
  Future<void> _register() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    try {
      final authInstance = widget.auth ?? FirebaseAuth.instance;
      final firestoreInstance = widget.firestore ?? FirebaseFirestore.instance;

      // 1. Crear usuario en Firebase Auth
      UserCredential userCredential = await authInstance.createUserWithEmailAndPassword(
        email: _emailController.text.trim(),
        password: _passwordController.text.trim(),
      );

      // 2. Guardar nombre en Authentication
      await userCredential.user!.updateDisplayName(_nameController.text.trim());

      // 3. Guardar datos adicionales en Firestore
      await firestoreInstance.collection('users').doc(userCredential.user!.uid).set({
        'name': _nameController.text.trim(),
        'email': userCredential.user!.email,
        'role': 'User',
        'createdAt': FieldValue.serverTimestamp(),
      });

      // CORRECCIÓN: verificar mounted antes de usar context tras awaits
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('¡Cuenta creada con éxito! Bienvenido a CalmSpace'),
          backgroundColor: Colors.green,
        ),
      );

      // CORRECCIÓN: navegar a home explícitamente como respaldo,
      // en caso de que authStateChanges no dispare la redirección a tiempo.
      Navigator.pushReplacementNamed(context, '/home');

    } on FirebaseAuthException catch (e) {
      String errorMsg = 'Ocurrió un error inesperado';

      if (e.code == 'weak-password') {
        errorMsg = 'La contraseña es muy débil.';
      } else if (e.code == 'email-already-in-use') {
        errorMsg = 'Ya existe una cuenta con este correo.';
      } else if (e.code == 'invalid-email') {
        errorMsg = 'El formato del correo no es válido.';
      } else if (e.code == 'too-many-requests') {
        errorMsg = 'Demasiados intentos. Intenta más tarde.';

  // REGISTRO CON EMAIL Y PASSWORD
  Future<void> _register() async {
    if (_formKey.currentState!.validate()) {
      setState(() => _isLoading = true);

      try {
        // Crear usuario
        UserCredential userCredential =
            await FirebaseAuth.instance.createUserWithEmailAndPassword(
          email: _emailController.text.trim(),
          password: _passwordController.text.trim(),
        );

        // Guardar nombre en Auth
        await userCredential.user!
            .updateDisplayName(_nameController.text.trim());

        // Guardar en Firestore
        await FirebaseFirestore.instance
            .collection('users')
            .doc(userCredential.user!.uid)
            .set({
          'name': _nameController.text.trim(),
          'email': userCredential.user!.email,
          'role': 'User',
          'createdAt': FieldValue.serverTimestamp(),
        });

        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('¡Cuenta creada con éxito!'),
              backgroundColor: Colors.green,
            ),
          );
        }
      } on FirebaseAuthException catch (e) {
        String msg = 'Error inesperado';

        if (e.code == 'weak-password') {
          msg = 'La contraseña es muy débil';
        } else if (e.code == 'email-already-in-use') {
          msg = 'Este correo ya está registrado';
        } else if (e.code == 'invalid-email') {
          msg = 'Correo inválido';
        }

        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(msg), backgroundColor: Colors.red),
          );
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context)
              .showSnackBar(SnackBar(content: Text(e.toString())));
        }
      } finally {
        if (mounted) {
          setState(() => _isLoading = false);
        }
      main
      }

      // CORRECCIÓN: verificar mounted antes de usar context
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(errorMsg), backgroundColor: Colors.red),
      );

    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(e.toString())),
      );

    } finally {
      // ✅ CORRECCIÓN: usar finally para garantizar que _isLoading se resetea siempre
      if (mounted) setState(() => _isLoading = false);
    }
  }

  // GOOGLE SIGN-IN
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
      debugPrint("Error: ${e.message}");
      return null;
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.blue.shade50,
      appBar: AppBar(
        title: const Text('Crear Cuenta'),
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: SingleChildScrollView(
            child: Column(
              children: [
                const SizedBox(height: 40),
                const Text(
                  'Regístrate en CalmSpace',
                  style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 40),

 feature/HU-03-login
                // Campo Nombre

                // NOMBRE
 main
                TextFormField(
                  controller: _nameController,
                  decoration: const InputDecoration(
                    labelText: 'Nombre',
                    prefixIcon: Icon(Icons.person),
                  ),
                  validator: (value) =>
                      value!.isEmpty ? 'Ingresa tu nombre' : null,
                ),

 feature/HU-03-login
                // Campo Email

                const SizedBox(height: 20),

                // EMAIL

                TextFormField(
                  controller: _emailController,
                  decoration: const InputDecoration(
                    labelText: 'Correo',
                    prefixIcon: Icon(Icons.email),
                  ),
                  validator: (value) =>
                      value!.isEmpty ? 'Ingresa tu correo' : null,
                ),

            feature/HU-03-login
                // Campo Contraseña

                const SizedBox(height: 20),

                // PASSWORD
             main
                TextFormField(
                  controller: _passwordController,
                  obscureText: true,
                  decoration: const InputDecoration(
                    labelText: 'Contraseña',
                    prefixIcon: Icon(Icons.lock),
                  ),
                  validator: (value) =>
                      value!.length < 6 ? 'Mínimo 6 caracteres' : null,
                ),

         feature/HU-03-login
                // Botón Registrarse

                const SizedBox(height: 30),

                // BOTÓN REGISTRO
           main
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: _isLoading ? null : _register,
        feature/HU-03-login
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.blueAccent,
                      shape: const StadiumBorder(),
                    ),
                    child: _isLoading
                        ? const CircularProgressIndicator(color: Colors.white)
                        : const Text(
                            'Registrarse',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                          ),
                  ),
                ),
                const SizedBox(height: 20),

                // NUEVO: enlace a login
                TextButton(
                  onPressed: () => Navigator.pushReplacementNamed(context, '/login'),
                  child: const Text('¿Ya tienes cuenta? Inicia sesión'),

                    child: _isLoading
                        ? const CircularProgressIndicator(color: Colors.white)
                        : const Text('Registrarse'),
                  ),
                ),

                const SizedBox(height: 20),

                // GOOGLE SIGN-IN
                ElevatedButton.icon(
                  onPressed: () async {
                    await signInWithGoogle();
                  },
                  icon: Image.network(
                    'https://cdn-icons-png.flaticon.com/512/281/281764.png',
                    height: 24,
                  ),
                  label: const Text("Continuar con Google"),
          main
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}