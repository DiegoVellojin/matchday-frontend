import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/di/injection_container.dart';
import '../bloc/matches_bloc.dart';
import '../../domain/entities/match_entity.dart';
import 'package:intl/intl.dart';

class CreateMatchPage extends StatefulWidget {
  const CreateMatchPage({super.key});

  @override
  State<CreateMatchPage> createState() => _CreateMatchPageState();
}

class _CreateMatchPageState extends State<CreateMatchPage> {
  int selectedSportId = 1;
  DateTime selectedDate = DateTime.now();
  TimeOfDay startTime = const TimeOfDay(hour: 8, minute: 0);
  TimeOfDay endTime = const TimeOfDay(hour: 10, minute: 0);
  final TextEditingController _locationController = TextEditingController();

  final _dateController = TextEditingController();
  final _startController = TextEditingController();
  final _endController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _dateController.text = DateFormat('yyyy-MM-dd').format(selectedDate);
    _startController.text = startTime.format(context);
    _endController.text = endTime.format(context);
  }

  void _showSimilarMatchesModal(List<MatchEntity> similar) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) {
        final isDark = Theme.of(context).brightness == Brightness.dark;
        return Container(
          height: MediaQuery.of(context).size.height * 0.7,
          decoration: BoxDecoration(
            color: isDark ? const Color(0xFF1E1E1E) : Colors.white,
            borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
          ),
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text('¡Partidos similares encontrados!',
                      style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold)),
                  IconButton(icon: const Icon(Icons.close, color: Colors.white), onPressed: () => Navigator.pop(context)),
                ],
              ),
              const SizedBox(height: 20),
              if (similar.isEmpty)
                const Center(child: Text('No hay partidos parecidos, puedes publicar el tuyo.', style: TextStyle(color: Colors.grey)))
              else
                Expanded(
                  child: ListView.separated(
                    itemCount: similar.length,
                    separatorBuilder: (context, index) => const SizedBox(height: 12),
                    itemBuilder: (context, index) {
                      final match = similar[index];
                      return _buildSimilarMatchCard(match, isDark);
                    },
                  ),
                ),
              const SizedBox(height: 20),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () {
                    Navigator.pop(context);
                    _submitCreate();
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.transparent,
                    side: const BorderSide(color: AppColors.primary),
                    padding: const EdgeInsets.symmetric(vertical: 16),
                  ),
                  child: const Text('Publicar el mío de todas formas', style: TextStyle(color: AppColors.primary)),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildSimilarMatchCard(MatchEntity match, bool isDark) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF252525) : Colors.grey[100],
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFF2A2A2A)),
      ),
      child: Column(
        children: [
          Row(
            children: [
              const CircleAvatar(child: Text('⚽')),
              const SizedBox(width: 12),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Partido #${match.id}', style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                  const Text('Fútbol', style: TextStyle(color: AppColors.primary, fontSize: 12)),
                ],
              ),
            ],
          ),
          const SizedBox(height: 12),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              context.push('/match-details');
            },
            style: ElevatedButton.styleFrom(backgroundColor: AppColors.primary, foregroundColor: Colors.black),
            child: const Text('Unirme a este partido'),
          ),
        ],
      ),
    );
  }

  void _submitCreate() {
    final startDateTime = DateTime(
      selectedDate.year,
      selectedDate.month,
      selectedDate.day,
      startTime.hour,
      startTime.minute,
    );
    final endDateTime = DateTime(
      selectedDate.year,
      selectedDate.month,
      selectedDate.day,
      endTime.hour,
      endTime.minute,
    );

    final newMatch = MatchEntity(
      id: 0,
      fechaInicioEstimada: startDateTime,
      fechaFinEstimada: endDateTime,
      costoTotal: 0.0,
      estatus: 'publicada',
      idUsuarioOrg: 0, // El backend lo asigna
      idDeporte: selectedSportId,
      idCancha: 1, // Por ahora fijo o seleccionable
    );

    context.read<MatchesBloc>().add(CreateMatchEvent(newMatch));
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return BlocProvider(
      create: (context) => sl<MatchesBloc>(),
      child: BlocListener<MatchesBloc, MatchesState>(
        listener: (context, state) {
          if (state is SimilarMatchesFound) {
            _showSimilarMatchesModal(state.similarMatches);
          } else if (state is MatchCreated) {
            ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Partido creado exitosamente')));
            context.pop();
          } else if (state is MatchesError) {
            ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(state.message)));
          }
        },
        child: Builder(builder: (context) {
          return Scaffold(
            backgroundColor: Theme.of(context).scaffoldBackgroundColor,
            appBar: AppBar(
              backgroundColor: isDark ? const Color(0xFF1E1E1E) : Colors.white,
              title: const Text('Create Match', style: TextStyle(fontWeight: FontWeight.bold)),
              leading: IconButton(
                icon: const Icon(Icons.arrow_back),
                onPressed: () => context.pop(),
              ),
            ),
            body: SingleChildScrollView(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildLabel('Select Sport'),
                  _buildDropdown(['Fútbol', 'Baloncesto', 'Tenis', 'Voleibol'], isDark),
                  const SizedBox(height: 20),
                  _buildLabel('Date'),
                  _buildTextField(Icons.calendar_today, 'YYYY-MM-DD', isDark, controller: _dateController, onTap: () async {
                    final date = await showDatePicker(
                      context: context,
                      initialDate: selectedDate,
                      firstDate: DateTime.now(),
                      lastDate: DateTime.now().add(const Duration(days: 30)),
                    );
                    if (date != null) {
                      setState(() {
                        selectedDate = date;
                        _dateController.text = DateFormat('yyyy-MM-dd').format(date);
                      });
                    }
                  }),
                  const SizedBox(height: 20),
                  Row(
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            _buildLabel('Start Time'),
                            _buildTextField(Icons.access_time, '00:00', isDark, controller: _startController, onTap: () async {
                              final time = await showTimePicker(context: context, initialTime: startTime);
                              if (time != null) {
                                setState(() {
                                  startTime = time;
                                  _startController.text = time.format(context);
                                });
                              }
                            }),
                          ],
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            _buildLabel('End Time'),
                            _buildTextField(Icons.access_time, '00:00', isDark, controller: _endController, onTap: () async {
                              final time = await showTimePicker(context: context, initialTime: endTime);
                              if (time != null) {
                                setState(() {
                                  endTime = time;
                                  _endController.text = time.format(context);
                                });
                              }
                            }),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),
                  _buildLabel('Location'),
                  _buildTextField(Icons.location_on, 'Enter court or field name', isDark, controller: _locationController),
                ],
              ),
            ),
            bottomNavigationBar: Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: isDark ? const Color(0xFF1E1E1E) : Colors.white,
                border: Border(top: BorderSide(color: isDark ? const Color(0xFF2A2A2A) : Colors.grey[200]!)),
              ),
              child: ElevatedButton(
                onPressed: () {
                  context.read<MatchesBloc>().add(SearchSimilarMatchesEvent(
                    sportId: selectedSportId,
                    date: selectedDate,
                  ));
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  foregroundColor: Colors.black,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                ),
                child: const Text('Find or Create', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
              ),
            ),
          );
        }),
      ),
    );
  }

  Widget _buildLabel(String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8.0),
      child: Text(
        text,
        style: const TextStyle(color: Color(0xFF9CA3AF), fontWeight: FontWeight.w500),
      ),
    );
  }

  Widget _buildTextField(IconData icon, String hint, bool isDark, {TextEditingController? controller, VoidCallback? onTap}) {
    return Container(
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF1E1E1E) : Colors.grey[100],
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: isDark ? const Color(0xFF2A2A2A) : Colors.grey[300]!),
      ),
      child: TextField(
        controller: controller,
        readOnly: onTap != null,
        onTap: onTap,
        decoration: InputDecoration(
          hintText: hint,
          hintStyle: const TextStyle(color: Color(0xFF4A4A4A)),
          prefixIcon: Icon(icon, color: const Color(0xFF9CA3AF)),
          border: InputBorder.none,
          contentPadding: const EdgeInsets.symmetric(vertical: 14),
        ),
        style: TextStyle(color: isDark ? Colors.white : Colors.black),
      ),
    );
  }

  Widget _buildDropdown(List<String> items, bool isDark) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF1E1E1E) : Colors.grey[100],
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: isDark ? const Color(0xFF2A2A2A) : Colors.grey[300]!),
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<String>(
          value: items[selectedSportId - 1],
          isExpanded: true,
          dropdownColor: isDark ? const Color(0xFF1E1E1E) : Colors.white,
          style: TextStyle(color: isDark ? Colors.white : Colors.black),
          items: items.map((String value) {
            return DropdownMenuItem<String>(
              value: value,
              child: Text(value),
            );
          }).toList(),
          onChanged: (val) {
            if (val != null) {
              setState(() => selectedSportId = items.indexOf(val) + 1);
            }
          },
        ),
      ),
    );
  }
}
