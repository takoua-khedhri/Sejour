import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import 'package:parent_5sur5/features/home/presentation/blocs/home_bloc.dart';
import 'package:parent_5sur5/features/home/presentation/widgets/publicationBatchLoader.dart';
import 'package:parent_5sur5/features/home/presentation/blocs/home_event.dart';
import 'package:parent_5sur5/features/home/presentation/blocs/home_state.dart';
import 'package:parent_5sur5/features/home/domain/entities/sejour.dart';
import 'package:parent_5sur5/features/home/presentation/widgets/publication_item.dart';
import 'package:parent_5sur5/features/home/presentation/widgets/header_bar.dart';
import 'package:parent_5sur5/features/home/presentation/widgets/bottom_nav_bar.dart';
import 'package:parent_5sur5/features/favorites/presentation/screens/favorites_screen.dart';
import 'package:parent_5sur5/features/audio/presentation/screens/audio_screen.dart';
import 'package:parent_5sur5/features/sejour_info/presentation/screens/sejour_info_screen.dart';

class HomeScreen extends StatefulWidget {
  final String codeSejour;
  final String token;
  final Sejour? sejour;

  const HomeScreen({
    Key? key,
    required this.codeSejour,
    required this.token,
    this.sejour,
  }) : super(key: key);

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _currentIndex = 0;
  late DateTime _selectedDate;
  final DateFormat _dateFormat = DateFormat('dd-MM-yyyy');
  final DateFormat _dayFormat = DateFormat('EEEE', 'fr_FR');
  final DateFormat _apiDateFormat = DateFormat('yyyy-MM-dd');

  @override
  void initState() {
    super.initState();
    _selectedDate = DateTime.now();
    _loadData();
  }

  bool _isDateInSejourRange(DateTime date, Sejour sejour) {
    try {
      final startDate = DateTime.parse(sejour.dateDebut ?? '');
      final endDate = DateTime.parse(sejour.dateFin ?? '');
      return date.isAfter(startDate.subtract(const Duration(days: 1))) && 
             date.isBefore(endDate.add(const Duration(days: 1)));
    } catch (e) {
      return false;
    }
  }

  List<DateTime> _generateDateRange(DateTime startDate, DateTime endDate) {
    List<DateTime> days = [];
    try {
      for (DateTime d = startDate; 
           d.isBefore(endDate.add(const Duration(days: 1))); 
           d = d.add(const Duration(days: 1))) {
        days.add(d);
      }
    } catch (e) {
      debugPrint('Error generating date range: $e');
    }
    return days;
  }

  void _onDateSelected(DateTime date, BuildContext context) {
    setState(() {
      _selectedDate = date;
    });
    _loadData();
  }

  void _onTabTapped(int index) {
    setState(() {
      _currentIndex = index;
    });
    if (index == 0) {
      _loadData();
    }
  }

  void _loadData() {
    context.read<HomeBloc>().add(LoadHomeEvent(
      codeSejour: widget.codeSejour,
      date: _apiDateFormat.format(_selectedDate),
      type: 'image,video',
      token: widget.token,
    ));
  }

 Widget _buildHomeContent(BuildContext context, HomeLoaded state) {
  final sejour = state.sejour!;
  final description = state.description;
  final publications = state.publications;
  
  DateTime? startDate;
  DateTime? endDate;
  try {
    startDate = DateTime.parse(sejour.dateDebut ?? '');
    endDate = DateTime.parse(sejour.dateFin ?? '');
  } catch (e) {
    debugPrint('Error parsing dates: $e');
    return const Center(child: Text('Dates du séjour invalides'));
  }

  if (startDate == null || endDate == null) {
    return const Center(child: Text('Dates du séjour manquantes'));
  }

  final dateRange = _generateDateRange(startDate, endDate);
  final isSelectedDateInRange = _isDateInSejourRange(_selectedDate, sejour);

  return SingleChildScrollView(
    child: Column(
      children: [
        if (dateRange.isNotEmpty)
          Container(
            height: 70,
            color: Colors.blue[50],
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              itemCount: dateRange.length,
              itemBuilder: (context, index) {
                final date = dateRange[index];
                final isSelected = _selectedDate.year == date.year &&
                    _selectedDate.month == date.month &&
                    _selectedDate.day == date.day;
                
                return GestureDetector(
                  onTap: () => _onDateSelected(date, context),
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12),
                    margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 4),
                    decoration: BoxDecoration(
                      color: isSelected ? Colors.blue : Colors.white,
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(
                        color: Colors.blue,
                        width: 1,
                      ),
                    ),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          _dayFormat.format(date),
                          style: TextStyle(
                            color: isSelected ? Colors.white : Colors.blue,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        Text(
                          _dateFormat.format(date),
                          style: TextStyle(
                            color: isSelected ? Colors.white : Colors.blue,
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),

        Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [      
              const SizedBox(height: 10),
              
              if (!isSelectedDateInRange)
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.grey[100],
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Center(
                    child: Text(
                      "Aucun séjour prévu pour le ${_dayFormat.format(_selectedDate)} ${_dateFormat.format(_selectedDate)}",
                      style: const TextStyle(color: Colors.grey),
                    ),
                  ),
                )
              else
                Column(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: Colors.grey[100],
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            " ${_dayFormat.format(_selectedDate)} ${_dateFormat.format(_selectedDate)}:",
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: Colors.blue[800],
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            description.description.isNotEmpty 
                                ? description.description
                                : "Pas de description disponible",
                            style: const TextStyle(fontSize: 16),
                          ),
                        ],
                      ),
                    ),
                    
                    const SizedBox(height: 20),
                    
                  
                    if (publications.isNotEmpty)
                      PublicationBatchLoader(
                        publications: publications,
                        token: widget.token,
                        batchSize: 5,
                      )
                    else
                      Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: Colors.grey[100],
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: const Text(
                          "Aucune publication pour cette date",
                          style: TextStyle(color: Colors.grey),
                        ),
                      ),
                  ],
                ),
            ],
          ),
        ),
      ],
    ),
  );
}

  @override
  Widget build(BuildContext context) {
    final _screens = [
      BlocBuilder<HomeBloc, HomeState>(
        builder: (context, state) {
          if (state is HomeLoading) {
            return const Center(child: CircularProgressIndicator());
          } else if (state is HomeLoaded) {
            if (state.sejour == null) {
              return const Center(child: Text('Aucun séjour disponible'));
            }
            return _buildHomeContent(context, state);
          } else if (state is HomeError) {
            return Center(child: Text(state.message));
          }
          return const Center(child: Text('État inconnu'));
        },
      ),
      FavoritesScreen(codeSejour: widget.codeSejour, token: widget.token),
      AudioScreen(codeSejour: widget.codeSejour, token: widget.token),
      SejourInfoScreen(
        codeSejour: widget.codeSejour,
        token: widget.token,
        initialSejour: widget.sejour,
      ),
    ];

    return Scaffold(
      appBar: HeaderBar(sejour: widget.sejour),
      body: _screens[_currentIndex],
      bottomNavigationBar: BottomNavBar(
        currentIndex: _currentIndex,
        onTap: _onTabTapped,
      ),
    );
  }
}