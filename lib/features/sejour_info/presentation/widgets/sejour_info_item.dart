import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import 'package:parent_5sur5/features/home/domain/entities/sejour.dart';
import '../blocs/sejour_info_bloc.dart';

class SejourInfoItem extends StatelessWidget {
  const SejourInfoItem({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<SejourInfoBloc, SejourInfoState>(
      builder: (context, state) {
        return switch (state) {
          SejourInfoInitial(sejour: final sejour?) => _buildSejourInfoTab(sejour),
          SejourInfoInitial() => const Center(child: Text('Aucune information disponible')),
          SejourInfoLoading() => const Center(child: CircularProgressIndicator()),
          SejourInfoLoaded(sejour: final sejour) => _buildSejourInfoTab(sejour),
          SejourInfoError(message: final message) => Center(
              child: Text(
                message,
                style: const TextStyle(color: Colors.red),
              ),
            ),
        };
      },
    );
  }

  Widget _buildSejourInfoTab(Sejour sejour) {
    final _dateFormat = DateFormat('dd/MM/yyyy');
    
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 5),
          Text(
            "Nom du séjour : ${sejour.theme ?? 'Non renseigné'}", 
            style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 20),
          _buildInfoCard(sejour, _dateFormat),
        ],
      ),
    );
  }

  Widget _buildDeletedWarning() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.red[50],
        borderRadius: BorderRadius.circular(8),
      ),
      
    );
  }

  Widget _buildInfoCard(Sejour sejour, DateFormat dateFormat) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.grey[100],
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          
          ..._buildInfoRows(sejour, dateFormat),
        ],
      ),
    );
  }

  List<Widget> _buildInfoRows(Sejour sejour, DateFormat dateFormat) {
    return [
      _buildInfoRow("Ville:", sejour.localisation['ville']?.toString() ?? 'Non renseigné'),
      _buildInfoRow("Nombre d'enfants:", sejour.nbEnfant?.toString() ?? 'Non renseigné'),
      _buildInfoRow("Date de début:", _formatDate(sejour.dateDebut, dateFormat)),
      _buildInfoRow("Date de fin:", _formatDate(sejour.dateFin, dateFormat)),
      _buildInfoRow("Thème:", sejour.theme ?? 'Non renseigné'),
    ];
  }

  String _formatDate(String? dateString, DateFormat formatter) {
    if (dateString == null || dateString.isEmpty) return 'Non renseigné';
    try {
      return formatter.format(DateTime.parse(dateString));
    } catch (e) {
      return dateString;
    }
  }

  Widget _buildInfoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 150,
            child: Text(
              label,
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              value,
              overflow: TextOverflow.ellipsis,
              maxLines: 2,
            ),
          ),
        ],
      ),
    );
  }
}