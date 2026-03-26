import 'package:flutter/material.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  // Llave global para identificar y validar el formulario
  final _formKey = GlobalKey<FormState>();

  // Controladores para obtener el texto de los campos
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  // Función que se ejecuta al presionar el botón
  void _register() {
    // Valida si todos los campos cumplen las condiciones
    if (_formKey.currentState!.validate()) {
      // Si todo está bien, aquí iría la conexión con Firebase (HU01-T2)
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Procesando datos...')));
      print("Email: ${_emailController.text}");
      print("Password: ${_passwordController.text}");
    }
  }

  @override
  void dispose() {
    // Es importante limpiar los controladores al salir de la pantalla
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.blue.shade50, // Azulito muy suave y calmante
      appBar: AppBar(title: const Text('Crear Cuenta'), centerTitle: true),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Text(
                'Regístrate en CalmSpace',
                style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 50),

              // Campo de Email
              TextFormField(
                controller: _emailController,
                keyboardType: TextInputType.emailAddress,
                decoration: InputDecoration(
                  labelText: 'Correo Electrónico',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(15),
                    borderSide: BorderSide
                        .none, // Ocultamos el borde crudo para un look más limpio
                  ),
                  filled: true,
                  fillColor:
                      Colors.white, // Resalta impecable sobre el fondo azul
                  prefixIcon: const Icon(Icons.email),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'El correo es obligatorio'; // Criterio: Campos obligatorios
                  }
                  // Validación básica de formato de correo
                  if (!RegExp(r'^[^@]+@[^@]+\.[^@]+').hasMatch(value)) {
                    return 'Ingresa un correo válido'; // Criterio: Email válido
                  }
                  return null;
                },
              ),
              const SizedBox(height: 30),

              // Campo de Contraseña
              TextFormField(
                controller: _passwordController,
                obscureText: true, // Oculta el texto
                decoration: InputDecoration(
                  labelText: 'Contraseña',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(15),
                    borderSide: BorderSide.none,
                  ),
                  filled: true,
                  fillColor: Colors.white,
                  prefixIcon: const Icon(Icons.lock),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'La contraseña es obligatoria'; // Criterio: Campos obligatorios
                  }
                  if (value.length < 6) {
                    return 'Debe tener mínimo 6 caracteres'; // Criterio: Mínimo 6 caracteres
                  }
                  return null;
                },
              ),
              const SizedBox(height: 50),

              // Botón de Registro
              SizedBox(
                width: double.infinity,
                height: 50,
                child: ElevatedButton(
                  onPressed: _register,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.blueAccent,
                    shape: const StadiumBorder(),
                  ),
                  child: const Text(
                    'Registrarse',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
