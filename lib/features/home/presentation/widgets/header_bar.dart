import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:parent_5sur5/features/help/presentation/screens/help_screen.dart';
import 'package:parent_5sur5/features/logout/presentation/blocs/logout_bloc.dart';
import 'package:parent_5sur5/features/logout/presentation/blocs/logout_event.dart';
import 'package:parent_5sur5/features/home/domain/entities/sejour.dart';

class HeaderBar extends StatelessWidget implements PreferredSizeWidget {
  final Sejour? sejour; // Rendons sejour nullable

  const HeaderBar({
    super.key, 
    this.sejour,
  });

  @override
  Widget build(BuildContext context) {
    return AppBar(
      backgroundColor: Colors.white,
      title: Image.asset(
        "assets/logo.png",
        height: 50,
      ),
      actions: [
        IconButton(
          icon: const Icon(Icons.help_outline),
          color: Colors.teal,
          onPressed: () {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const HelpScreen()),
            );
          },
        ),
        IconButton(
          icon: const Icon(Icons.logout),
          color: Colors.teal,
          onPressed: () {
            context.read<LogoutBloc>().add(PerformLogout());
          },
        ),
        if (sejour != null) // Afficher seulement si sejour existe
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8.0),
            child: Center(
              child: Text(
              sejour?.nom ?? 'Non renseigné', // Gestion élégante du null
                style: const TextStyle(color: Colors.teal),
              ),
            ),
          ),
      ],
    );
  }

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);
}