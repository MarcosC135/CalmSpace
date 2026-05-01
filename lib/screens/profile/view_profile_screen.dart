import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../models/user_profile.dart';
import 'edit_profile_screen.dart';

class ViewProfileScreen extends StatefulWidget {
  final String uid;
  final bool isOwnProfile;

  const ViewProfileScreen({
    super.key, 
    required this.uid, 
    required this.isOwnProfile
  });

  @override
  State<ViewProfileScreen> createState() => _ViewProfileScreenState();
}

class _ViewProfileScreenState extends State<ViewProfileScreen> {
  UserProfile? _userProfile;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadProfile();
  }

  Future<void> _loadProfile() async {
    setState(() => _isLoading = true);
    try {
      final doc = await FirebaseFirestore.instance.collection('users').doc(widget.uid).get();
      if (doc.exists) {
        setState(() {
          _userProfile = UserProfile.fromMap(widget.uid, doc.data()!);
        });
      }
    } catch (e) {
      debugPrint("Error loading profile: $e");
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    if (_userProfile == null) {
      return Scaffold(
        appBar: AppBar(title: const Text('Perfil')),
        body: const Center(child: Text('Perfil no encontrado')),
      );
    }

    final String inicial = _userProfile!.fullName.isNotEmpty 
        ? _userProfile!.fullName[0].toUpperCase() 
        : 'U';
    
    final isPatient = _userProfile?.role == 'Paciente' || _userProfile?.role == 'User';

    return Scaffold(
      appBar: AppBar(
        title: const Text('Perfil'),
        actions: [
          if (widget.isOwnProfile)
            IconButton(
              icon: const Icon(Icons.edit),
              onPressed: () async {
                final result = await Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const EditProfileScreen()),
                );
                if (result == true) {
                  _loadProfile();
                }
              },
            ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            const SizedBox(height: 20),
            CircleAvatar(
              radius: 50,
              backgroundColor: const Color(0xFF6BAE8E),
              child: Text(
                inicial,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 40,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            const SizedBox(height: 20),
            Text(
              _userProfile!.fullName,
              style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 4),
            Text(
              _userProfile!.role,
              style: const TextStyle(fontSize: 16, color: Colors.grey),
            ),
            const SizedBox(height: 30),
            
            // Info fields
            if (isPatient) ...[
              _buildInfoRow('Teléfono', _userProfile!.phone ?? 'No especificado'),
              _buildInfoRow('Fecha de Nac.', _userProfile!.birthDate ?? 'No especificada'),
              _buildInfoRow('Género', _userProfile!.gender ?? 'No especificado'),
              const SizedBox(height: 10),
              _buildInfoBox('¿Por qué buscas apoyo?', _userProfile!.supportReason ?? 'No especificado'),
            ] else ...[
              _buildInfoRow('Especialidad', _userProfile!.specialty ?? 'No especificada'),
              _buildInfoRow('Experiencia', '${_userProfile!.experienceYears ?? 0} años'),
              _buildInfoRow('Modalidad', _userProfile!.modality ?? 'No especificada'),
              _buildInfoRow('Teléfono de Contacto', _userProfile!.contactPhone ?? 'No especificado'),
              const SizedBox(height: 10),
              _buildInfoBox('Descripción profesional', _userProfile!.description ?? 'No especificada'),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            flex: 2,
            child: Text(
              label,
              style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.grey),
            ),
          ),
          Expanded(
            flex: 3,
            child: Text(
              value,
              style: const TextStyle(fontSize: 16),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoBox(String title, String content) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.grey.shade100,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.shade300),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.grey),
          ),
          const SizedBox(height: 8),
          Text(
            content,
            style: const TextStyle(fontSize: 15),
          ),
        ],
      ),
    );
  }
}
