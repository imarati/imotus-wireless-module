import 'dart:developer' as developer;

import 'package:flutter/foundation.dart';

class StmState extends ChangeNotifier {
  DateTime? time;
  int? angle;
  int? load;

  int? maxLoad;
  int? speed;
  int? manualSpeed;
  int? status;

  int? cycles;
  int? durationMin;
  bool stopByCycles = true;
  bool stopByTime = false;

  int? passiveElapsedSeconds;
  int? passiveDoneCycles;

  int? activeElapsedSeconds;
  int? activeDoneCycles;

  int? bendAngle;
  int? expAngle;

  int? activeBendAssistAngle;
  int? activeExpAssistAngle;
  int? activeBendLoad;
  int? activeExpLoad;

  int? bendPauseSec;
  int? expPauseSec;
  bool pauseOnBend = false;
  bool pauseOnExp = false;

  int? bendMaxLoad;
  int? expMaxLoad;

  bool reverseOnLoad = false;
  bool stopOnLoad = false;

  String patientSurname = '';
  String patientName = '';
  String patientPatronymic = '';
  String patientId = '';

  DateTime? sessionDate;
  TimeOfDayData? sessionTime;

  bool activeWarmupEnabled = false;
  int activeWarmupStep = 1;

  bool activeCooldownEnabled = false;
  int activeCooldownStep = 1;

  bool activeComfortEnabled = false;
  int activeComfortStep = 1;
  int activeComfortBendDeviation = 5;
  int activeComfortExpDeviation = 5;

  bool passiveWarmupEnabled = false;
  int passiveWarmupStep = 1;

  bool passiveCooldownEnabled = false;
  int passiveCooldownStep = 1;

  bool passiveComfortEnabled = false;
  int passiveComfortStep = 1;
  int passiveComfortBendDeviation = 5;
  int passiveComfortExpDeviation = 5;

  bool passiveExtendBendEnabled = false;
  bool passiveExtendExpEnabled = false;
  int passiveExtendRepeats = 1;

  bool activeWarmupSettingsEnabled = false;
  bool activeCooldownSettingsEnabled = false;
  bool activeComfortSettingsEnabled = false;

  bool passiveWarmupSettingsEnabled = false;
  bool passiveCooldownSettingsEnabled = false;
  bool passiveComfortSettingsEnabled = false;

  void updateFromForm2({
    required DateTime dateTime,
    required int angle,
    required int load,
    required int status,
  }) {
    final fixed = DateTime(
      dateTime.year < 100 ? 2000 + dateTime.year : dateTime.year,
      dateTime.month,
      dateTime.day,
      dateTime.hour,
      dateTime.minute,
      dateTime.second,
    );
    // developer.log('Form2 time: $fixed'); // <-- добавь
    time = fixed;
    this.angle = angle;
    this.load = load;
    this.status = status;
    notifyListeners();
  }

  void updateFromForm3({
    required int status,
  }) {
    this.status = status;
    notifyListeners();
  }

  void updateFromForm10({
    required int elapsedSeconds,
    required int doneCycles,
    required int status,
  }) {
    passiveElapsedSeconds = elapsedSeconds;
    passiveDoneCycles = doneCycles;
    this.status = status;
    notifyListeners();
  }

  void updateFromForm20({
    required int elapsedSeconds,
    required int doneCycles,
    required int status,
  }) {
    activeElapsedSeconds = elapsedSeconds;
    activeDoneCycles = doneCycles;
    this.status = status;
    notifyListeners();
  }

  void updateFromForm6({
    required int maxLoad,
    required int manualSpeed,
  }) {
    this.maxLoad = maxLoad;
    this.manualSpeed = manualSpeed;
    notifyListeners();
  }

  void updateFromForm8({
    required int cycles,
    required int durationMin,
    required bool stopByCycles,
    required bool stopByTime,
    required int speed,
    required int maxLoad,
    required int bendAngle,
    required int expAngle,
  }) {
    this.cycles = cycles;
    this.durationMin = durationMin;
    this.stopByCycles = stopByCycles;
    this.stopByTime = stopByTime;
    this.speed = speed;
    this.maxLoad = maxLoad;
    this.bendAngle = bendAngle;
    this.expAngle = expAngle;
    notifyListeners();
  }

  void updateFromForm13({
    required int cycles,
    required int durationMin,
    required bool stopByCycles,
    required bool stopByTime,
    required int speed,
    required int maxLoad,
    required int bendAngle,
    required int expAngle,
    required int bendAssistAngle,
    required int expAssistAngle,
    required int bendLoad,
    required int expLoad,
  }) {
    this.cycles = cycles;
    this.durationMin = durationMin;
    this.stopByCycles = stopByCycles;
    this.stopByTime = stopByTime;
    this.speed = speed;
    this.maxLoad = maxLoad;
    this.bendAngle = bendAngle;
    this.expAngle = expAngle;
    activeBendAssistAngle = bendAssistAngle;
    activeExpAssistAngle = expAssistAngle;
    activeBendLoad = bendLoad;
    activeExpLoad = expLoad;
    notifyListeners();
  }

  void updateFromForm17({
    required int speed,
    required int bendPauseSec,
    required int expPauseSec,
    required bool pauseOnBend,
    required bool pauseOnExp,
    required int cycles,
    required int durationMin,
    required bool stopByCycles,
    required bool stopByTime,
    required int maxLoad,
    required int bendMaxLoad,
    required int expMaxLoad,
    required bool reverseOnLoad,
    required bool stopOnLoad,
  }) {
    this.speed = speed;
    this.bendPauseSec = bendPauseSec;
    this.expPauseSec = expPauseSec;
    this.pauseOnBend = pauseOnBend;
    this.pauseOnExp = pauseOnExp;
    this.cycles = cycles;
    this.durationMin = durationMin;
    this.stopByCycles = stopByCycles;
    this.stopByTime = stopByTime;
    this.maxLoad = maxLoad;
    this.bendMaxLoad = bendMaxLoad;
    this.expMaxLoad = expMaxLoad;
    this.reverseOnLoad = reverseOnLoad;
    this.stopOnLoad = stopOnLoad;
    notifyListeners();
  }

  void updateFromForm18({
    required String surname,
    required String name,
    required String patronymic,
    required String patientId,
  }) {
    patientSurname = surname;
    patientName = name;
    patientPatronymic = patronymic;
    this.patientId = patientId;
    notifyListeners();
  }

  void updateFromForm19({
    required DateTime sessionDate,
    required TimeOfDayData sessionTime,
  }) {
    this.sessionDate = sessionDate;
    this.sessionTime = sessionTime;
    notifyListeners();
  }

  void updateFromForm23({
    required bool warmupEnabled,
    required bool cooldownEnabled,
    required bool comfortEnabled,
  }) {
    activeWarmupEnabled = warmupEnabled;
    activeCooldownEnabled = cooldownEnabled;
    activeComfortEnabled = comfortEnabled;
    notifyListeners();
  }

  void updateFromForm24({
    required int warmupStep,
  }) {
    activeWarmupStep = warmupStep;
    notifyListeners();
  }

  void updateFromForm27({
    required int cooldownStep,
  }) {
    activeCooldownStep = cooldownStep;
    notifyListeners();
  }

  void updateFromForm30({
    required bool warmupEnabled,
    required bool cooldownEnabled,
    required bool comfortEnabled,
  }) {
    passiveWarmupEnabled = warmupEnabled;
    passiveCooldownEnabled = cooldownEnabled;
    passiveComfortEnabled = comfortEnabled;
    notifyListeners();
  }

  void updateFromForm32({
    required int warmupStep,
  }) {
    passiveWarmupStep = warmupStep;
    notifyListeners();
  }

  void updateFromForm34({
    required int cooldownStep,
  }) {
    passiveCooldownStep = cooldownStep;
    notifyListeners();
  }

  void updateFromForm36({
    required int comfortStep,
    required int comfortBendDeviation,
    required int comfortExpDeviation,
  }) {
    passiveComfortStep = comfortStep;
    passiveComfortBendDeviation = comfortBendDeviation;
    passiveComfortExpDeviation = comfortExpDeviation;
    notifyListeners();
  }

  void updateFromForm38({
    required int comfortStep,
    required int comfortBendDeviation,
    required int comfortExpDeviation,
  }) {
    activeComfortStep = comfortStep;
    activeComfortBendDeviation = comfortBendDeviation;
    activeComfortExpDeviation = comfortExpDeviation;
    notifyListeners();
  }

  void updatePassiveFunctions({
    required bool extendBendEnabled,
    required bool extendExpEnabled,
    required int extendRepeats,
  }) {
    passiveExtendBendEnabled = extendBendEnabled;
    passiveExtendExpEnabled = extendExpEnabled;
    passiveExtendRepeats = extendRepeats;
    notifyListeners();
  }

  void resetForConnect() {
    time = null;
    angle = null;
    load = null;

    maxLoad = null;
    speed = null;
    manualSpeed = null;
    status = null;

    cycles = null;
    durationMin = null;
    stopByCycles = true;
    stopByTime = false;

    passiveElapsedSeconds = null;
    passiveDoneCycles = null;

    activeElapsedSeconds = null;
    activeDoneCycles = null;

    bendAngle = null;
    expAngle = null;

    activeBendAssistAngle = null;
    activeExpAssistAngle = null;
    activeBendLoad = null;
    activeExpLoad = null;

    bendPauseSec = null;
    expPauseSec = null;
    pauseOnBend = false;
    pauseOnExp = false;

    bendMaxLoad = null;
    expMaxLoad = null;

    reverseOnLoad = false;
    stopOnLoad = false;

    patientSurname = '';
    patientName = '';
    patientPatronymic = '';
    patientId = '';

    sessionDate = null;
    sessionTime = null;

    activeWarmupEnabled = false;
    activeWarmupStep = 1;
    activeCooldownEnabled = false;
    activeCooldownStep = 1;
    activeComfortEnabled = false;
    activeComfortStep = 1;
    activeComfortBendDeviation = 5;
    activeComfortExpDeviation = 5;

    passiveWarmupEnabled = false;
    passiveWarmupStep = 1;
    passiveCooldownEnabled = false;
    passiveCooldownStep = 1;
    passiveComfortEnabled = false;
    passiveComfortStep = 1;
    passiveComfortBendDeviation = 5;
    passiveComfortExpDeviation = 5;

    passiveExtendBendEnabled = false;
    passiveExtendExpEnabled = false;
    passiveExtendRepeats = 1;

    notifyListeners();
  }
}

class TimeOfDayData {
  final int hour;
  final int minute;
  final int second;

  const TimeOfDayData({
    required this.hour,
    required this.minute,
    required this.second,
  });
}

final stmState = StmState();