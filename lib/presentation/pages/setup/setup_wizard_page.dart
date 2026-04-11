import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../data/models/service_task.dart';
import '../../../domain/repositories/service_task_repository.dart' show TaskUpdatePayload;
import '../../providers/service_task_provider.dart';
import '../../providers/settings_provider.dart';
import '../../providers/vehicle_provider.dart';
import '../home/home_root_page.dart';

/// ============================================================
/// Setup Wizard Page — First-Run Onboarding
/// ============================================================
///
/// Guides the user through 3 steps in a single scrollable form:
///   1. Vehicle Info (make, model, year) — required.
///   2. Current Odometer — required.
///   3. Past Maintenance + editable intervals — optional.
///
/// A Skip button in the AppBar lets users bypass the wizard.
/// On Finish, all data is saved in sequence and the page closes.
/// ============================================================
class SetupWizardPage extends ConsumerStatefulWidget {
  /// When true, this is the first run — skip navigates to dashboard.
  /// When false (re-opened from settings), skip just pops back.
  final bool isFirstRun;

  const SetupWizardPage({super.key, this.isFirstRun = false});

  @override
  ConsumerState<SetupWizardPage> createState() => _SetupWizardPageState();
}

class _SetupWizardPageState extends ConsumerState<SetupWizardPage> {
  final _formKey = GlobalKey<FormState>();
  final _makeController = TextEditingController();
  final _modelController = TextEditingController();
  final _yearController = TextEditingController();
  final _odometerController = TextEditingController();

  /// Per-task controllers: baseline done_at_km.
  final Map<String, TextEditingController> _baselineControllers = {};
  /// Per-task controllers: intervalKm override.
  final Map<String, TextEditingController> _kmIntervalControllers = {};
  /// Per-task controllers: intervalMonths override.
  final Map<String, TextEditingController> _monthIntervalControllers = {};

  /// Set of taskKeys the user has toggled as "done previously".
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
    for (final c in _baselineControllers.values) c.dispose();
    for (final c in _kmIntervalControllers.values) c.dispose();
    for (final c in _monthIntervalControllers.values) c.dispose();
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

    // 3. Batch-update all task settings (intervals + baselines).
    final updates = <String, TaskUpdatePayload>{};
    final taskState = ref.read(serviceTaskProvider).valueOrNull;
    if (taskState != null) {
      for (final task in taskState.allTasks) {
        final kmInterval = int.tryParse(
          _kmIntervalControllers[task.taskKey]?.text.trim() ?? '',
        );
        final monthInterval = int.tryParse(
          _monthIntervalControllers[task.taskKey]?.text.trim() ?? '',
        );
        final lastDoneKm = _selectedBaselines.contains(task.taskKey)
            ? int.tryParse(
                _baselineControllers[task.taskKey]?.text.trim() ?? '',
              )
            : null;

        // Only include tasks where something changed.
        if (kmInterval != null || monthInterval != null || lastDoneKm != null) {
          updates[task.taskKey] = TaskUpdatePayload(
            intervalKm: kmInterval,
            intervalMonths: monthInterval,
            lastDoneKm: lastDoneKm,
          );
        }
      }
    }
    if (updates.isNotEmpty) {
      await ref.read(serviceTaskProvider.notifier).batchUpdateTaskSettings(updates);
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
            onPressed: () {
              if (widget.isFirstRun) {
                // First run: skip wizard → go to dashboard.
                Navigator.of(context).pushAndRemoveUntil(
                  MaterialPageRoute(builder: (_) => const HomeRootPage()),
                  (route) => false,
                );
              } else {
                Navigator.of(context).pop();
              }
            },
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
                      const SizedBox(height: 12),
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
                      const SizedBox(height: 10),
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
              const SizedBox(height: 10),

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
                      const SizedBox(height: 12),
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
              const SizedBox(height: 10),

              // — Card 3: Past Maintenance + Intervals —
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
                      const SizedBox(height: 10),
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
                              return _TaskSetupTile(
                                task: task,
                                t: t,
                                isSelected: _selectedBaselines.contains(task.taskKey),
                                baselineController: _baselineControllers.putIfAbsent(
                                  task.taskKey,
                                  () => TextEditingController(
                                    text: task.lastDoneKm?.toString() ?? '',
                                  ),
                                ),
                                kmIntervalController: _kmIntervalControllers.putIfAbsent(
                                  task.taskKey,
                                  () => TextEditingController(
                                    text: task.intervalKm?.toString() ?? '',
                                  ),
                                ),
                                monthIntervalController:
                                    _monthIntervalControllers.putIfAbsent(
                                  task.taskKey,
                                  () => TextEditingController(
                                    text: task.intervalMonths?.toString() ?? '',
                                  ),
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
              const SizedBox(height: 20),

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

/// A compact task tile showing editable intervals + optional baseline.
class _TaskSetupTile extends StatelessWidget {
  final ServiceTask task;
  final String Function(String) t;
  final bool isSelected;
  final TextEditingController baselineController;
  final TextEditingController kmIntervalController;
  final TextEditingController monthIntervalController;
  final ValueChanged<bool?> onToggle;

  const _TaskSetupTile({
    required this.task,
    required this.t,
    required this.isSelected,
    required this.baselineController,
    required this.kmIntervalController,
    required this.monthIntervalController,
    required this.onToggle,
  });

  @override
  Widget build(BuildContext context) {
    final hasKm = task.intervalKm != null;
    final hasMonths = task.intervalMonths != null;

    return Padding(
      padding: const EdgeInsets.only(bottom: 6),
      child: Column(
        children: [
          // Task name + switch
          Row(
            children: [
              Expanded(
                child: Text(
                  t(task.displayNameEn),
                  style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w500),
                ),
              ),
              SizedBox(
                height: 32,
                child: FittedBox(
                  fit: BoxFit.scaleDown,
                  child: Switch(
                    value: isSelected,
                    onChanged: onToggle,
                  ),
                ),
              ),
            ],
          ),

          // Editable interval fields (always visible)
          Padding(
            padding: const EdgeInsets.only(left: 4),
            child: Row(
              children: [
                if (hasKm) ...[
                  Expanded(
                    child: TextFormField(
                      controller: kmIntervalController,
                      keyboardType: TextInputType.number,
                      inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                      decoration: InputDecoration(
                        labelText: t('interval_km'),
                        border: const OutlineInputBorder(),
                        isDense: true,
                        suffixText: t('km'),
                        contentPadding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 8,
                        ),
                      ),
                    ),
                  ),
                ],
                if (hasKm && hasMonths) const SizedBox(width: 8),
                if (hasMonths) ...[
                  Expanded(
                    child: TextFormField(
                      controller: monthIntervalController,
                      keyboardType: TextInputType.number,
                      inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                      decoration: InputDecoration(
                        labelText: t('interval_months'),
                        border: const OutlineInputBorder(),
                        isDense: true,
                        suffixText: t('months'),
                        contentPadding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 8,
                        ),
                      ),
                    ),
                  ),
                ],
              ],
            ),
          ),

          // Baseline field (only when toggled on)
          if (isSelected)
            Padding(
              padding: const EdgeInsets.only(left: 4, top: 6),
              child: TextFormField(
                controller: baselineController,
                keyboardType: TextInputType.number,
                inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                decoration: InputDecoration(
                  labelText: t('done_at_km'),
                  border: const OutlineInputBorder(),
                  isDense: true,
                  prefixIcon: const Icon(Icons.check_circle_outline, size: 18),
                  suffixText: t('km'),
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 8,
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}
