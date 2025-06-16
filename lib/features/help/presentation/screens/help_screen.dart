import 'package:flutter/material.dart';

class HelpScreen extends StatelessWidget {
  const HelpScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.teal,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
      ),

      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Center(
              child: Text(
                '5sur5 Séjour',
                style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                  color: Colors.teal,
                ),
              ),
            ),
            const SizedBox(height: 16),
            const Text(
              "5sur5sejour est la plateforme sécurisée dédiée aux séjours scolaires, colonies, camps de vacances ou séjours à l'étranger.",
            ),
            const SizedBox(height: 12),
            const Text(
              "Notre plateforme 5sur5sejour.com vous permettra de déposer vos photos et vidéos, vos messages audio, et de localiser vos activités sur une carte. "
                  "Les parents pourront suivre le séjour de leurs enfants grâce au code séjour que vous leur aurez transmis. "
                  "Pour vous, un outil simple, intuitif et sécurisé. "
                  "Pour les parents, un outil de création facile à utiliser pour des tirages de qualité.",
            ),
            const SizedBox(height: 24),
            const Text(
              "Contact",
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Colors.teal,
              ),
            ),
            const SizedBox(height: 12),
            const Row(
              children: [
                Icon(Icons.location_city, color: Colors.teal),
                SizedBox(width: 8),
                Expanded(
                  child: Text(
                    "Trust Conseils\n199 Avenue Francis de Pressensé\n69200 Vénissieux",
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            const Row(
              children: [
                Icon(Icons.phone, color: Colors.teal),
                SizedBox(width: 8),
                Text("05 36 28 29 30"),
              ],
            ),
            const SizedBox(height: 12),
            const Row(
              children: [
                Icon(Icons.email, color: Colors.teal),
                SizedBox(width: 8),
                Text("contact@5sur5sejour.com"),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
