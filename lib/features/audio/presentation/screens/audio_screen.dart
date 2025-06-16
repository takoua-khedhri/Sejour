import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:parent_5sur5/features/audio/presentation/widgets/audio_item.dart';
import 'package:parent_5sur5/features/audio/presentation/bloc/audio_bloc.dart';
import 'package:parent_5sur5/features/audio/domain/entities/audio.dart';

class AudioScreen extends StatelessWidget {
  final String codeSejour;
  final String token;

  const AudioScreen({
    required this.codeSejour,
    required this.token,
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    context.read<AudioBloc>().add(LoadAudiosEvent(
          codeSejour: codeSejour,
          type: 'audio',
          date: DateTime.now().toString(),
          token: token,
        ));

    return Scaffold(
     
      body: BlocBuilder<AudioBloc, AudioState>(
        builder: (context, state) {
          switch (state.status) {
            case AudioStatus.initial:
              return const SizedBox();
            case AudioStatus.loading:
              return const Center(child: CircularProgressIndicator());
            case AudioStatus.success:
              if (state.audios.isEmpty) {
                return const Center(
                  child: Text(
                    'Aucun enregistrement audio disponible',
                    style: TextStyle(fontSize: 16),
                  ),
                );
              }
              return ListView.builder(
                physics: const BouncingScrollPhysics(),
                padding: const EdgeInsets.symmetric(vertical: 8.0),
                itemCount: state.audios.length,
                itemBuilder: (context, index) {
                  return Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12.0,
                      vertical: 6.0,
                    ),
                    child: AudioItem(
                      audio: state.audios[index],
                      token: token,
                    ),
                  );
                },
              );
            case AudioStatus.failure:
              return Center(
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Text(
                    state.errorMessage ?? 'Erreur de chargement',
                    style: const TextStyle(fontSize: 16),
                  ),
                ),
              );
          }
        },
      ),
    );
  }
}