import 'package:flutter/material.dart';
import 'package:mobile_app/protocol/form18_patient_info.dart';
import '../protocol/request/form21_request_patient_info.dart';
import '../services/tcp_service.dart';
import '../states/stm_state.dart';

class PatientInfoScreen extends StatefulWidget {
  final TcpService tcp;

  const PatientInfoScreen({super.key, required this.tcp});

  @override
  State<PatientInfoScreen> createState() => _PatientInfoScreenState();
}

class _PatientInfoScreenState extends State<PatientInfoScreen> {
  late final TextEditingController nameController;
  late final TextEditingController surnameController;
  late final TextEditingController patronymicController;
  late final TextEditingController patientIdController;

  late final FocusNode nameFocusNode;
  late final FocusNode surnameFocusNode;
  late final FocusNode patronymicFocusNode;
  late final FocusNode patientIdFocusNode;

  bool _initializedFromState = false;

  @override
  void initState() {
    super.initState();

    nameController = TextEditingController();
    surnameController = TextEditingController();
    patronymicController = TextEditingController();
    patientIdController = TextEditingController();

    nameFocusNode = FocusNode();
    surnameFocusNode = FocusNode();
    patronymicFocusNode = FocusNode();
    patientIdFocusNode = FocusNode();

    stmState.addListener(_syncFromState);
    _syncFromState();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      widget.tcp.sendForm(Form21RequestPatientInfo());
    });
  }

  bool get _hasPatientInfoFromState {
    return stmState.patientName.isNotEmpty ||
        stmState.patientSurname.isNotEmpty ||
        stmState.patientPatronymic.isNotEmpty ||
        stmState.patientId.isNotEmpty;
  }

  void _syncFromState() {
    if (_initializedFromState) return;
    if (!_hasPatientInfoFromState) return;

    nameController.text = stmState.patientName;
    surnameController.text = stmState.patientSurname;
    patronymicController.text = stmState.patientPatronymic;
    patientIdController.text = stmState.patientId;

    _initializedFromState = true;
  }

  void _save() {
    final name = nameController.text.trim();
    final surname = surnameController.text.trim();
    final patronymic = patronymicController.text.trim();
    final patientId = patientIdController.text.trim();

    widget.tcp.sendForm(
      Form18PatientInfo(
        name: name,
        surname: surname,
        patronymic: patronymic,
        patientId: patientId,
      ),
    );

    stmState.updateFromForm18(
      name: name,
      surname: surname,
      patronymic: patronymic,
      patientId: patientId,
    );

    Navigator.pop(context);
  }

  @override
  void dispose() {
    stmState.removeListener(_syncFromState);
    nameController.dispose();
    surnameController.dispose();
    patronymicController.dispose();
    patientIdController.dispose();
    nameFocusNode.dispose();
    surnameFocusNode.dispose();
    patronymicFocusNode.dispose();
    patientIdFocusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
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
                      'Данные пациента',
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
                'Имя пациента',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
              ),
              const SizedBox(height: 8),
              TextField(
                controller: nameController,
                focusNode: nameFocusNode,
                decoration: const InputDecoration(
                  border: OutlineInputBorder(),
                  hintText: 'Введите имя',
                ),
              ),
              const SizedBox(height: 32),
              const Text(
                'Фамилия пациента',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
              ),
              const SizedBox(height: 8),
              TextField(
                controller: surnameController,
                focusNode: surnameFocusNode,
                decoration: const InputDecoration(
                  border: OutlineInputBorder(),
                  hintText: 'Введите фамилию',
                ),
              ),
              const SizedBox(height: 32),
              const Text(
                'Отчетсво пациента',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
              ),
              const SizedBox(height: 8),
              TextField(
                controller: patronymicController,
                focusNode: patronymicFocusNode,
                decoration: const InputDecoration(
                  border: OutlineInputBorder(),
                  hintText: 'Введите отчество',
                ),
              ),
              const SizedBox(height: 24),
              const Text(
                'ID пациента',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
              ),
              const SizedBox(height: 8),
              TextField(
                controller: patientIdController,
                focusNode: patientIdFocusNode,
                decoration: const InputDecoration(
                  border: OutlineInputBorder(),
                  hintText: 'Введите ID',
                ),
              ),
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
    );
  }
}