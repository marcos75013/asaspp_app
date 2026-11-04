import '../../../../core/data/association_repository.dart';
import '../../../connected/data/club_api.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../home/presentation/cubit/home_cubit.dart';
import 'package:flutter/material.dart';

class CreateEventForm extends StatelessWidget {
  const CreateEventForm({super.key, this.training = false});
  final bool training;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(training ? "Créer un entraînement" : "Créer un événement"),
      ),
      body: _CreateEventFormBody(training: training),
    );
  }
}

class _CreateEventFormBody extends StatefulWidget {
  const _CreateEventFormBody({required this.training});
  final bool training;

  @override
  State<_CreateEventFormBody> createState() => _CreateEventFormBodyState();
}

class _CreateEventFormBodyState extends State<_CreateEventFormBody> {
  bool _saving = false;
  Future<void> save(Future<void> Function() action) async {
    if (_saving) return;
    setState(() => _saving = true);
    try {
      await action();
      if (mounted) Navigator.pop(context, true);
    } catch (error) {
      if (mounted)
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text(readableError(error))));
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  DateTime? _start;
  Future<void> _pickDate() async {
    final day = await showDatePicker(
      context: context,
      initialDate: _start ?? DateTime.now(),
      firstDate: DateTime.now().subtract(const Duration(days: 1)),
      lastDate: DateTime.now().add(const Duration(days: 3650)),
    );
    if (day == null || !mounted) return;
    final time = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.fromDateTime(_start ?? DateTime.now()),
    );
    if (time != null && mounted)
      setState(
        () => _start = DateTime(
          day.year,
          day.month,
          day.day,
          time.hour,
          time.minute,
        ),
      );
  }

  void _submit() => save(() async {
    if (nameController.text.trim().isEmpty || _start == null)
      throw StateError('Renseignez le nom et la date.');
    final home = context.read<HomeCubit>();
    await (await repositoryOf(context).api()).request(
      '/api/events',
      method: 'POST',
      data: {
        'title': nameController.text.trim(),
        'location': locationController.text.trim(),
        'description': descriptionController.text.trim(),
        'category': widget.training ? 'Entraînement' : 'Sortie',
        'startDate': _start!.toIso8601String(),
        'published': true,
      },
    );
    await home.loadEvents();
  });
  @override
  void dispose() {
    nameController.dispose();
    locationController.dispose();
    descriptionController.dispose();
    super.dispose();
  }

  final _formKey = GlobalKey<FormState>();

  final nameController = TextEditingController();
  final locationController = TextEditingController();
  final descriptionController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(20),

      child: Form(
        key: _formKey,

        child: SingleChildScrollView(
          child: Column(
            children: [
              TextFormField(
                controller: nameController,
                decoration: const InputDecoration(
                  labelText: "Nom de l'événement",
                  border: OutlineInputBorder(),
                ),
              ),

              const SizedBox(height: 20),

              TextFormField(
                controller: locationController,
                decoration: const InputDecoration(
                  labelText: "Lieu",
                  border: OutlineInputBorder(),
                ),
              ),

              const SizedBox(height: 20),

              TextFormField(
                controller: descriptionController,
                decoration: const InputDecoration(
                  labelText: "Description",
                  border: OutlineInputBorder(),
                ),
                maxLines: 3,
              ),

              const SizedBox(height: 20),
              OutlinedButton(
                onPressed: _saving ? null : _pickDate,
                child: Text(
                  _start == null
                      ? 'Choisir la date et l’heure'
                      : '${_start!.day}/${_start!.month}/${_start!.year} à ${_start!.hour}:${_start!.minute.toString().padLeft(2, '0')}',
                ),
              ),
              const SizedBox(height: 30),

              ElevatedButton(
                onPressed: _saving ? null : _submit,
                child: const Text("Créer l'événement"),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
