import 'package:flutter/material.dart';
import 'package:parent_5sur5/features/home/data/models/day_description_model.dart';

class DayDescription extends StatelessWidget {
  final DayDescriptionModel descriptionModel;

  const DayDescription({required this.descriptionModel, super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Description pour le ${descriptionModel.date}',
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Colors.black87,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            descriptionModel.description,
            style: const TextStyle(
              fontSize: 16,
              color: Colors.black87,
            ),
          ),
        ],
      ),
    );
  }
}
