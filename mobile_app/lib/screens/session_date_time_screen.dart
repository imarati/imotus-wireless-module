import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:mobile_app/protocol/form19_session_datetime.dart';

import '../protocol/request/form1_sync_time.dart';
import '../protocol/request/form22_request_session_date_time.dart';
import '../services/tcp_service.dart';
import '../states/stm_state.dart';

class SessionDateTimeScreen extends StatefulWidget {
  final TcpService tcp;

  const SessionDateTimeScreen({super.key, required this.tcp});

  @override
  State<SessionDateTimeScreen> createState() => _SessionDateTimeScreenState();
}

class _SessionDateTimeScreenState extends State<SessionDateTimeScreen> {
  DateTime? selectedDate;
  DateTime? lastSystemTimeSent;
  Timer? _timer;

  late final TextEditingController _hourController;
  late final TextEditingController _minuteController;
  late final TextEditingController _secondController;

  bool _initializedFromState = false;
  bool _dateEditedByUser = false;
  bool _timeEditedByUser = false;

  static final _firstDate = DateTime(2020);
  static final _lastDate = DateTime(2100);

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      widget.tcp.sendForm(Form22RequestSessionDateTime());
    });

    _hourController = TextEditingController();
    _minuteController = TextEditingController();
    _secondController = TextEditingController();

    stmState.addListener(_syncFromState);
    _syncFromState();
  }

  int _fixYear(int year) {
    if (year < 100) return 2000 + year;
    return year;
  }

  void _syncFromState() {
    if (!mounted) return;

    final stateDate = stmState.sessionDate;
    final stateTime = stmState.sessionTime;

    setState(() {
      if (!_initializedFromState) {
        if (stateDate != null) {
          final d = DateTime(
            _fixYear(stateDate.year),
            stateDate.month,
            stateDate.day,
          );
          if (!d.isBefore(_firstDate) && !d.isAfter(_lastDate)) {
            selectedDate = d;
          }
        }

        if (stateTime != null) {
          _hourController.text = stateTime.hour.toString().padLeft(2, '0');
          _minuteController.text = stateTime.minute.toString().padLeft(2, '0');
          _secondController.text = stateTime.second.toString().padLeft(2, '0');
        }

        _initializedFromState = true;
        return;
      }

      if (!_dateEditedByUser && stateDate != null) {
        final d = DateTime(
          _fixYear(stateDate.year),
          stateDate.month,
          stateDate.day,
        );
        if (!d.isBefore(_firstDate) && !d.isAfter(_lastDate)) {
          selectedDate = d;
        } else {
          selectedDate = null;
        }
      }

      if (!_timeEditedByUser && stateTime != null) {
        final newHour = stateTime.hour.toString().padLeft(2, '0');
        final newMinute = stateTime.minute.toString().padLeft(2, '0');
        final newSecond = stateTime.second.toString().padLeft(2, '0');

        if (_hourController.text != newHour) _hourController.text = newHour;
        if (_minuteController.text != newMinute) _minuteController.text = newMinute;
        if (_secondController.text != newSecond) _secondController.text = newSecond;
      }
    });
  }

  @override
  void dispose() {
    stmState.removeListener(_syncFromState);
    _timer?.cancel();
    _hourController.dispose();
    _minuteController.dispose();
    _secondController.dispose();
    super.dispose();
  }

  Future<void> _pickDate() async {
    final now = DateTime.now();

    DateTime? safeInitial;
    if (selectedDate != null &&
        !selectedDate!.isBefore(_firstDate) &&
        !selectedDate!.isAfter(_lastDate)) {
      safeInitial = selectedDate;
    }

    final picked = await showDatePicker(
      context: context,
      initialDate: safeInitial ?? now,
      firstDate: _firstDate,
      lastDate: _lastDate,
    );

    if (picked != null) {
      setState(() {
        selectedDate = DateTime(picked.year, picked.month, picked.day);
        _dateEditedByUser = true;
      });
    }
  }

  void _syncTime() {
    final now = DateTime.now();
    final nowSeconds = now.millisecondsSinceEpoch ~/ 1000;

    setState(() {
      selectedDate = DateTime(now.year, now.month, now.day);
      _hourController.text = now.hour.toString().padLeft(2, '0');
      _minuteController.text = now.minute.toString().padLeft(2, '0');
      _secondController.text = now.second.toString().padLeft(2, '0');
      _dateEditedByUser = true;
      _timeEditedByUser = true;
      lastSystemTimeSent = now;
    });

    widget.tcp.sendForm(Form1SyncTime(nowSeconds));

    widget.tcp.sendForm(
      Form19SessionDateTime(
        sessionDate: DateTime(now.year, now.month, now.day),
        hour: now.hour,
        minute: now.minute,
        second: now.second,
      ),
    );

    stmState.updateFromForm19(
      sessionDate: DateTime(now.year, now.month, now.day),
      sessionTime: TimeOfDayData(
        hour: now.hour,
        minute: now.minute,
        second: now.second,
      ),
    );
  }

  String _formatDate(DateTime? dt) {
    if (dt == null) return 'Не выбрана';
    return '${dt.day.toString().padLeft(2, '0')}.'
        '${dt.month.toString().padLeft(2, '0')}.'
        '${dt.year}';
  }

  String _formatDt(DateTime? dt) {
    if (dt == null) return '—';
    return '${dt.day.toString().padLeft(2, '0')}.'
        '${dt.month.toString().padLeft(2, '0')}.'
        '${dt.year} '
        '${dt.hour.toString().padLeft(2, '0')}:'
        '${dt.minute.toString().padLeft(2, '0')}:'
        '${dt.second.toString().padLeft(2, '0')}';
  }

  ({int hour, int minute, int second})? _parseTime() {
    final hour = int.tryParse(_hourController.text.trim());
    final minute = int.tryParse(_minuteController.text.trim());
    final second = int.tryParse(_secondController.text.trim());

    if (hour == null || minute == null || second == null) return null;
    if (hour < 0 || hour > 23) return null;
    if (minute < 0 || minute > 59) return null;
    if (second < 0 || second > 59) return null;

    return (hour: hour, minute: minute, second: second);
  }

  void _save() {
    final date = selectedDate;
    final parsedTime = _parseTime();

    if (date == null || parsedTime == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Введите корректную дату и время'),
        ),
      );
      return;
    }

    widget.tcp.sendForm(
      Form19SessionDateTime(
        sessionDate: date,
        hour: parsedTime.hour,
        minute: parsedTime.minute,
        second: parsedTime.second,
      ),
    );

    stmState.updateFromForm19(
      sessionDate: DateTime(date.year, date.month, date.day),
      sessionTime: TimeOfDayData(
        hour: parsedTime.hour,
        minute: parsedTime.minute,
        second: parsedTime.second,
      ),
    );

    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => FocusScope.of(context).unfocus(),
      child: Scaffold(
        backgroundColor: const Color(0xFFF5F6FA),
        body: SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    IconButton(
                      icon: const Icon(Icons.arrow_back, color: Colors.black),
                      onPressed: () => Navigator.pop(context),
                    ),
                    const SizedBox(width: 8),
                    const Expanded(
                      child: Text(
                        'Дата и время',
                        style: TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 32),

                const Text(
                  'Дата',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
                ),
                const SizedBox(height: 8),
                SizedBox(
                  width: double.infinity,
                  child: OutlinedButton(
                    onPressed: _pickDate,
                    child: Text(_formatDate(selectedDate)),
                  ),
                ),
                const SizedBox(height: 24),

                const Text(
                  'Время',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    _TimeField(
                      controller: _hourController,
                      label: 'ЧЧ',
                      max: 23,
                      onChanged: (_) =>
                          setState(() => _timeEditedByUser = true),
                      onNext: () => FocusScope.of(context).nextFocus(),
                    ),
                    const Padding(
                      padding: EdgeInsets.symmetric(horizontal: 8),
                      child: Text(
                        ':',
                        style: TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    _TimeField(
                      controller: _minuteController,
                      label: 'ММ',
                      max: 59,
                      onChanged: (_) =>
                          setState(() => _timeEditedByUser = true),
                      onNext: () => FocusScope.of(context).nextFocus(),
                    ),
                    const Padding(
                      padding: EdgeInsets.symmetric(horizontal: 8),
                      child: Text(
                        ':',
                        style: TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    _TimeField(
                      controller: _secondController,
                      label: 'СС',
                      max: 59,
                      isLast: true,
                      onChanged: (_) =>
                          setState(() => _timeEditedByUser = true),
                      onNext: () => FocusScope.of(context).unfocus(),
                    ),
                  ],
                ),
                const SizedBox(height: 32),

                ListenableBuilder(
                  listenable: stmState,
                  builder: (context, _) => Text(
                    _formatDt(stmState.time),
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
                const SizedBox(height: 16),

                SizedBox(
                  width: double.infinity,
                  height: 48,
                  child: ElevatedButton.icon(
                    onPressed: _syncTime,
                    icon: const Icon(Icons.sync),
                    label: const Text('Синхронизировать время'),
                  ),
                ),
                if (lastSystemTimeSent != null) ...[
                  const SizedBox(height: 12),
                  Text(
                    'Последняя синхронизация: ${_formatDt(lastSystemTimeSent)}',
                    style: const TextStyle(fontSize: 12, color: Colors.grey),
                  ),
                ],
                const Spacer(),

                SizedBox(
                  width: double.infinity,
                  height: 48,
                  child: ElevatedButton(
                    onPressed: _save,
                    child: const Text('Сохранить'),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _TimeField extends StatelessWidget {
  final TextEditingController controller;
  final String label;
  final int max;
  final bool isLast;
  final ValueChanged<String>? onChanged;
  final VoidCallback? onNext;

  const _TimeField({
    required this.controller,
    required this.label,
    required this.max,
    this.isLast = false,
    this.onChanged,
    this.onNext,
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: TextField(
        controller: controller,
        textAlign: TextAlign.center,
        keyboardType: TextInputType.number,
        maxLength: 2,
        textInputAction:
        isLast ? TextInputAction.done : TextInputAction.next,
        inputFormatters: [FilteringTextInputFormatter.digitsOnly],
        decoration: InputDecoration(
          labelText: label,
          border: const OutlineInputBorder(),
          counterText: '',
        ),
        onChanged: (val) {
          onChanged?.call(val);
          if (val.length == 2) onNext?.call();
        },
        onEditingComplete: () {
          final v = int.tryParse(controller.text) ?? 0;
          if (v > max) {
            controller.text = max.toString().padLeft(2, '0');
          } else {
            controller.text = v.toString().padLeft(2, '0');
          }
          onNext?.call();
        },
        onSubmitted: (_) => onNext?.call(),
      ),
    );
  }
}