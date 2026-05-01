import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../models/user_profile.dart';

class EditProfileScreen extends StatefulWidget {
  const EditProfileScreen({super.key});

  @override
  State<EditProfileScreen> createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends State<EditProfileScreen> {
  final _formKey = GlobalKey<FormState>();

  bool _isLoading = true;
  bool _isSaving = false;

  UserProfile? _userProfile;

  // Controladores comunes
  late TextEditingController _nameController;

  // Controladores Paciente
  late TextEditingController _phoneController;
  late TextEditingController _birthDateController;
  late TextEditingController _genderController;
  late TextEditingController _supportReasonController;

  // Controladores Psicólogo
  late TextEditingController _specialtyController;
  late TextEditingController _experienceYearsController;
  late TextEditingController _modalityController;
  late TextEditingController _descriptionController;
  late TextEditingController _contactPhoneController;

  @override
  void initState() {
    super.initState();
    _initControllers();
    _loadProfile();
  }

  void _initControllers() {
    _nameController = TextEditingController();
    _phoneController = TextEditingController();
    _birthDateController = TextEditingController();
    _genderController = TextEditingController();
    _supportReasonController = TextEditingController();

    _specialtyController = TextEditingController();
    _experienceYearsController = TextEditingController();
    _modalityController = TextEditingController();
    _descriptionController = TextEditingController();
    _contactPhoneController = TextEditingController();
  }

  @override
  void dispose() {
    _nameController.dispose();
    _phoneController.dispose();
    _birthDateController.dispose();
    _genderController.dispose();
    _supportReasonController.dispose();
    _specialtyController.dispose();
    _experienceYearsController.dispose();
    _modalityController.dispose();
    _descriptionController.dispose();
    _contactPhoneController.dispose();
    super.dispose();
  }

  Future<void> _loadProfile() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;

    try {
      final doc = await FirebaseFirestore.instance
          .collection('users')
          .doc(user.uid)
          .get();
      if (doc.exists) {
        final data = doc.data()!;
        _userProfile = UserProfile.fromMap(user.uid, data);

        _nameController.text = _userProfile?.fullName ?? '';

        if (_userProfile?.role == 'Paciente' || _userProfile?.role == 'User') {
          _phoneController.text = _userProfile?.phone ?? '';
          _birthDateController.text = _userProfile?.birthDate ?? '';
          _genderController.text = _userProfile?.gender ?? '';
          _supportReasonController.text = _userProfile?.supportReason ?? '';
        } else {
          _specialtyController.text = _userProfile?.specialty ?? '';
          _experienceYearsController.text =
              _userProfile?.experienceYears?.toString() ?? '';
          _modalityController.text = _userProfile?.modality ?? '';
          _descriptionController.text = _userProfile?.description ?? '';
          _contactPhoneController.text = _userProfile?.contactPhone ?? '';
        }
      }
    } catch (e) {
      debugPrint("Error loading profile: $e");
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  Future<void> _saveProfile() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isSaving = true);

    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;

    try {
      final isPatient =
          _userProfile?.role == 'Paciente' || _userProfile?.role == 'User';

      final updatedProfile = UserProfile(
        uid: user.uid,
        fullName: _nameController.text.trim(),
        role: _userProfile?.role ?? 'Paciente',
        photoUrl: _userProfile?.photoUrl,

        phone: isPatient ? _phoneController.text.trim() : null,
        birthDate: isPatient ? _birthDateController.text.trim() : null,
        gender: isPatient ? _genderController.text.trim() : null,
        supportReason: isPatient ? _supportReasonController.text.trim() : null,

        specialty: !isPatient ? _specialtyController.text.trim() : null,
        experienceYears: !isPatient
            ? int.tryParse(_experienceYearsController.text.trim())
            : null,
        modality: !isPatient ? _modalityController.text.trim() : null,
        description: !isPatient ? _descriptionController.text.trim() : null,
        contactPhone: !isPatient ? _contactPhoneController.text.trim() : null,
      );

      await FirebaseFirestore.instance
          .collection('users')
          .doc(user.uid)
          .set(updatedProfile.toMap(), SetOptions(merge: true));

      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Perfil actualizado con éxito'),
          backgroundColor: Colors.green,
        ),
      );
      Navigator.pop(context, true);
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error al guardar: $e'),
          backgroundColor: Colors.red,
        ),
      );
    } finally {
      if (mounted) setState(() => _isSaving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    final isPatient =
        _userProfile?.role == 'Paciente' || _userProfile?.role == 'User';

    return Scaffold(
      appBar: AppBar(title: const Text('Editar Perfil')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Common fields
              TextFormField(
                controller: _nameController,
                decoration: const InputDecoration(
                  labelText: 'Nombre completo',
                  border: OutlineInputBorder(),
                ),
                validator: (value) => value!.isEmpty ? 'Requerido' : null,
              ),
              const SizedBox(height: 16),

              if (isPatient) ...[
                TextFormField(
                  controller: _phoneController,
                  decoration: const InputDecoration(
                    labelText: 'Teléfono (Opcional)',
                    border: OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _birthDateController,
                  decoration: const InputDecoration(
                    labelText: 'Fecha de Nacimiento (Opcional)',
                    border: OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _genderController,
                  decoration: const InputDecoration(
                    labelText: 'Género (Opcional)',
                    border: OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _supportReasonController,
                  maxLength: 300,
                  maxLines: 3,
                  decoration: const InputDecoration(
                    labelText: '¿Por qué buscas apoyo? (Opcional)',
                    border: OutlineInputBorder(),
                  ),
                ),
              ] else ...[
                TextFormField(
                  controller: _specialtyController,
                  decoration: const InputDecoration(
                    labelText: 'Especialidad',
                    border: OutlineInputBorder(),
                  ),
                  validator: (value) => value!.isEmpty ? 'Requerido' : null,
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _experienceYearsController,
                  decoration: const InputDecoration(
                    labelText: 'Años de experiencia',
                    border: OutlineInputBorder(),
                  ),
                  keyboardType: TextInputType.number,
                  validator: (value) {
                    if (value!.isEmpty) return 'Requerido';
                    if (int.tryParse(value) == null)
                      return 'Debe ser un número';
                    return null;
                  },
                ),
                const SizedBox(height: 16),
                DropdownButtonFormField<String>(
                  initialValue: _modalityController.text.isEmpty
                      ? null
                      : _modalityController.text,
                  decoration: const InputDecoration(
                    labelText: 'Modalidad',
                    border: OutlineInputBorder(),
                  ),
                  items: const [
                    DropdownMenuItem(
                      value: 'Presencial',
                      child: Text('Presencial'),
                    ),
                    DropdownMenuItem(value: 'Virtual', child: Text('Virtual')),
                    DropdownMenuItem(value: 'Ambas', child: Text('Ambas')),
                  ],
                  onChanged: (val) {
                    if (val != null) _modalityController.text = val;
                  },
                  validator: (value) =>
                      value == null || value.isEmpty ? 'Requerido' : null,
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _descriptionController,
                  maxLength: 500,
                  maxLines: 4,
                  decoration: const InputDecoration(
                    labelText: 'Descripción profesional',
                    border: OutlineInputBorder(),
                  ),
                  validator: (value) => value!.isEmpty ? 'Requerido' : null,
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _contactPhoneController,
                  decoration: const InputDecoration(
                    labelText: 'Teléfono de contacto (Opcional)',
                    border: OutlineInputBorder(),
                  ),
                ),
              ],

              const SizedBox(height: 24),
              SizedBox(
                width: double.infinity,
                height: 50,
                child: ElevatedButton(
                  onPressed: _isSaving ? null : _saveProfile,
                  child: _isSaving
                      ? const CircularProgressIndicator(color: Colors.white)
                      : const Text(
                          'Guardar Perfil',
                          style: TextStyle(fontSize: 16),
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
