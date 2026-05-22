import 'package:flutter/foundation.dart';

class StmState extends ChangeNotifier {
  DateTime? time;
  int? angle; // градусы, i16
  int? load; // кг, i16

  // Общие training/manual поля
  int? maxLoad; // кг
  int? speed; // %, training режимы
  int? manualSpeed; // %, ручной режим
  int? status; // u8

  // Общие training settings/status
  int? cycles;
  int? durationMin;
  bool stopByCycles = true;
  bool stopByTime = false;
  int? elapsedSeconds;
  int? doneCycles;

  // Общие углы для training режимов
  int? bendAngle;
  int? expAngle;

  // Active-specific
  int? activeBendAssistAngle;
  int? activeExpAssistAngle;
  int? activeBendLoad;
  int? activeExpLoad;

  void updateFromForm2({
    required int timestamp,
    required int angle,
    required int load,
    required int status,
  }) {
    time = DateTime.fromMillisecondsSinceEpoch(
      timestamp * 1000,
      isUtc: true,
    ).toLocal();
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
    this.elapsedSeconds = elapsedSeconds;
    this.doneCycles = doneCycles;
    this.status = status;
    notifyListeners();
  }

  void updateFromForm11({
    required int maxLoad,
    required int manualSpeed,
    required int status,
  }) {
    this.maxLoad = maxLoad;
    this.manualSpeed = manualSpeed;
    this.status = status;
    notifyListeners();
  }

  void updateFromForm12({
    required int cycles,
    required int durationMin,
    required bool stopByCycles,
    required bool stopByTime,
    required int speed,
    required int maxLoad,
    required int bendAngle,
    required int expAngle,
    required int status,
  }) {
    this.cycles = cycles;
    this.durationMin = durationMin;
    this.stopByCycles = stopByCycles;
    this.stopByTime = stopByTime;
    this.speed = speed;
    this.maxLoad = maxLoad;
    this.bendAngle = bendAngle;
    this.expAngle = expAngle;
    this.status = status;

    notifyListeners();
  }

  void updateFromForm17({
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
    required int status,
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

    this.status = status;
    notifyListeners();
  }

  void updateFromForm20({
    required int maxLoad,
    required int speed,
    required int cycles,
    required int durationMin,
    required bool stopByCycles,
    required bool stopByTime,
    required int bendAngle,
    required int expAngle,
    required int status,
  }) {
    this.maxLoad = maxLoad;
    this.speed = speed;
    this.manualSpeed = manualSpeed;

    this.cycles = cycles;
    this.durationMin = durationMin;
    this.stopByCycles = stopByCycles;
    this.stopByTime = stopByTime;

    this.bendAngle = bendAngle;
    this.expAngle = expAngle;

    this.activeBendAssistAngle = activeBendAssistAngle;
    this.activeExpAssistAngle = activeExpAssistAngle;
    this.activeBendLoad = activeBendLoad;
    this.activeExpLoad = activeExpLoad;

    this.status = status;
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
    elapsedSeconds = null;
    doneCycles = null;

    bendAngle = null;
    expAngle = null;

    activeBendAssistAngle = null;
    activeExpAssistAngle = null;
    activeBendLoad = null;
    activeExpLoad = null;
  }
}

final stmState = StmState();