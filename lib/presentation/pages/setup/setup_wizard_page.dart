import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../data/models/service_task.dart';
import '../../providers/service_task_provider.dart';
import '../../providers/settings_provider.dart';
import '../../providers/vehicle_provider.dart';

/// ============================================================
/// Setup Wizard Page — First-Run Onboarding
/// ============================================================
///
/// Guides the user through 3 steps in a single scrollable form:
///   1. Vehicle Info (make, model, year) — required.
///   2. Current Odometer — required.
///   3. Past Maintenance baselines — optional.
///
/// A Skip button in the AppBar lets users bypass the wizard.
/// On Finish, all data is saved in sequence and the page closes.
/// ============================================================
class SetupWizardPage extends ConsumerStatefulWidget {
  const SetupWizardPage({super.key});

  @override
  ConsumerState<SetupWizardPage> createState() => _SetupWizardPageState();
}

class _SetupWizardPageState extends ConsumerState<SetupWizardPage> {
  final _formKey = GlobalKey<FormState>();
  final _makeController = TextEditingController();
  final _modelController = TextEditingController();
  final _yearController = TextEditingController();
  final _odometerController = TextEditingController();

  /// Maps taskKey -> doneAtKm for tasks the user marks as previously done.
  final Map<String, TextEditingController> _baselineControllers = {};

  /// Set of taskKeys the user has toggled on.
  final Set<String> _selectedBaselines = {};

  bool _isSaving = false;

  @override
  void initState() {
    super.initState();
    _preFillFromVehicle();
  }

  Future<void> _preFillFromVehicle() async {
    final vehicleState = await ref.read(vehicleProvider.future);
    final vehicle = vehicleState.activeVehicle;
    if (vehicle != null && mounted) {
      _makeController.text = vehicle.make;
      _modelController.text = vehicle.model;
      if (vehicle.year > 0) {
        _yearController.text = vehicle.year.toString();
      }
      _odometerController.text = vehicle.currentOdometerKm.toString();
    }
  }

  @override
  void dispose() {
    _makeController.dispose();
    _modelController.dispose();
    _yearController.dispose();
    _odometerController.dispose();
    for (final c in _baselineControllers.values) {
      c.dispose();
    }
    super.dispose();
  }

  Future<void> _onFinish() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isSaving = true);

    final newMake = _makeController.text.trim();
    final newModel = _modelController.text.trim();
    final newYear = int.tryParse(_yearController.text.trim());
    final newOdometer = int.tryParse(_odometerController.text.trim()) ?? 0;

    // 1. Update vehicle info.
    final vehicleState = await ref.read(vehicleProvider.future);
    final vehicle = vehicleState.activeVehicle;
    if (vehicle != null) {
      await ref.read(vehicleProvider.notifier).updateVehicle(
            vehicleId: vehicle.id,
            make: newMake,
            model: newModel,
            name: '$newMake $newModel',
            year: newYear,
          );

      // 2. Update odometer.
      await ref.read(vehicleProvider.notifier).updateOdometer(newOdometer);
    }

    // 3. Batch-update baselines for selected tasks.
    final baselines = <String, int>{};
    for (final taskKey in _selectedBaselines) {
      final kmText = _baselineControllers[taskKey]?.text.trim() ?? '';
      final km = int.tryParse(kmText);
      if (km != null) {
        baselines[taskKey] = km;
      }
    }
    if (baselines.isNotEmpty) {
      await ref.read(serviceTaskProvider.notifier).batchUpdateBaselines(baselines);
    }

    if (mounted) Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    final settings = ref.watch(settingsProvider);
    final t = settings.t;
    final tasksAsync = ref.watch(serviceTaskProvider);

    return Scaffold(
      appBar: AppBar(
        title: Text(t('setup_wizard')),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: Text(
              t('skip_for_now'),
              style: TextStyle(
                color: Theme.of(context).colorScheme.onSurfaceVariant,
              ),
            ),
          ),
        ],
      ),
      body: Form(
        key: _formKey,
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // — Card 1: Vehicle Info —
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Icon(Icons.directions_car,
                              color: Theme.of(context).colorScheme.primary),
                          const SizedBox(width: 8),
                          Text(
                            t('vehicle_info'),
                            style: Theme.of(context)
                                .textTheme
                                .titleMedium
                                ?.copyWith(fontWeight: FontWeight.w600),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      Row(
                        children: [
                          Expanded(
                            child: TextFormField(
                              controller: _makeController,
                              textCapitalization: TextCapitalization.words,
                              decoration: InputDecoration(
                                labelText: t('make'),
                                border: const OutlineInputBorder(),
                                isDense: true,
                              ),
                              validator: (v) =>
                                  (v == null || v.trim().isEmpty) ? t('make') : null,
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: TextFormField(
                              controller: _modelController,
                              textCapitalization: TextCapitalization.words,
                              decoration: InputDecoration(
                                labelText: t('model'),
                                border: const OutlineInputBorder(),
                                isDense: true,
                              ),
                              validator: (v) =>
                                  (v == null || v.trim().isEmpty) ? t('model') : null,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      TextFormField(
                        controller: _yearController,
                        keyboardType: TextInputType.number,
                        inputFormatters: [
                          FilteringTextInputFormatter.digitsOnly,
                          LengthLimitingTextInputFormatter(4),
                        ],
                        decoration: InputDecoration(
                          labelText: t('year'),
                          border: const OutlineInputBorder(),
                          isDense: true,
                          prefixIcon: const Icon(Icons.calendar_today_outlined, size: 18),
                        ),
                        validator: (v) {
                          if (v == null || v.trim().isEmpty) return t('year');
                          final parsed = int.tryParse(v.trim());
                          if (parsed == null || parsed < 1900 || parsed > 2100) {
                            return 'Invalid year';
                          }
                          return null;
                        },
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 12),

              // — Card 2: Current Odometer —
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Icon(Icons.speed,
                              color: Theme.of(context).colorScheme.primary),
                          const SizedBox(width: 8),
                          Text(
                            t('current_state'),
                            style: Theme.of(context)
                                .textTheme
                                .titleMedium
                                ?.copyWith(fontWeight: FontWeight.w600),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      TextFormField(
                        controller: _odometerController,
                        keyboardType: TextInputType.number,
                        inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                        decoration: InputDecoration(
                          labelText: t('odometer'),
                          border: const OutlineInputBorder(),
                          isDense: true,
                          prefixIcon: const Icon(Icons.speed_outlined, size: 18),
                          suffixText: t('km'),
                        ),
                        validator: (v) {
                          if (v == null || v.trim().isEmpty) return t('odometer');
                          if (int.tryParse(v.trim()) == null) return 'Invalid number';
                          return null;
                        },
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 12),

              // — Card 3: Past Maintenance —
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Icon(Icons.history,
                              color: Theme.of(context).colorScheme.primary),
                          const SizedBox(width: 8),
                          Text(
                            t('past_maintenance'),
                            style: Theme.of(context)
                                .textTheme
                                .titleMedium
                                ?.copyWith(fontWeight: FontWeight.w600),
                          ),
                        ],
                      ),
                      const SizedBox(height: 4),
                      Text(
                        t('mark_as_done'),
                        style: TextStyle(
                          fontSize: 12,
                          color: Theme.of(context).colorScheme.onSurfaceVariant,
                        ),
                      ),
                      const SizedBox(height: 12),
                      tasksAsync.when(
                        data: (state) {
                          final tasks = state.allTasks;
                          if (tasks.isEmpty) {
                            return Padding(
                              padding: const EdgeInsets.all(12),
                              child: Text(t('no_tasks_loaded')),
                            );
                          }
                          return Column(
                            children: tasks.map((task) {
                              return _TaskBaselineTile(
                                task: task,
                                t: t,
                                isSelected: _selectedBaselines.contains(task.taskKey),
                                controller: _baselineControllers.putIfAbsent(
                                  task.taskKey,
                                  () => TextEditingController(),
                                ),
                                onToggle: (checked) {
                                  setState(() {
                                    if (checked == true) {
                                      _selectedBaselines.add(task.taskKey);
                                    } else {
                                      _selectedBaselines.remove(task.taskKey);
                                    }
                                  });
                                },
                              );
                            }).toList(),
                          );
                        },
                        loading: () => const Center(
                          child: Padding(
                            padding: EdgeInsets.all(16),
                            child: CircularProgressIndicator(strokeWidth: 2),
                          ),
                        ),
                        error: (e, _) => Padding(
                          padding: const EdgeInsets.all(12),
                          child: Text('Error: $e'),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 24),

              // — Finish Button —
              SizedBox(
                height: 48,
                child: FilledButton.icon(
                  onPressed: _isSaving ? null : _onFinish,
                  icon: _isSaving
                      ? const SizedBox(
                          width: 18,
                          height: 18,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            color: Colors.white,
                          ),
                        )
                      : const Icon(Icons.check),
                  label: Text(t('finish_setup')),
                ),
              ),
              const SizedBox(height: 24),
            ],
          ),
        ),
      ),
    );
  }
}

/// A single task row in the Past Maintenance checklist.
class _TaskBaselineTile extends StatelessWidget {
  final ServiceTask task;
  final String Function(String) t;
  final bool isSelected;
  final TextEditingController controller;
  final ValueChanged<bool?> onToggle;

  const _TaskBaselineTile({
    required this.task,
    required this.t,
    required this.isSelected,
    required this.controller,
    required this.onToggle,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Column(
        children: [
          SwitchListTile(
            title: Text(
              t(task.displayNameEn),
              style: const TextStyle(fontSize: 14),
            ),
            subtitle: task.intervalKm != null
                ? Text(
                    '${t('every_km')} ${task.intervalKm} ${t('km')}',
                    style: const TextStyle(fontSize: 12),
                  )
                : null,
            value: isSelected,
            onChanged: onToggle,
            dense: true,
            contentPadding: EdgeInsets.zero,
          ),
          if (isSelected)
            Padding(
              padding: const EdgeInsets.only(left: 16, bottom: 4),
              child: TextFormField(
                controller: controller,
                keyboardType: TextInputType.number,
                inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                decoration: InputDecoration(
                  labelText: t('done_at_km'),
                  border: const OutlineInputBorder(),
                  isDense: true,
                  suffixText: t('km'),
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 10,
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}
