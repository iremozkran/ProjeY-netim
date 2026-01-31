import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:proje_takip/helper/app_constants.dart';
import 'package:proje_takip/helper/validator.dart';
import 'package:proje_takip/models/employee.dart';
import 'package:proje_takip/models/task.dart';
import 'package:proje_takip/services/db_employee_service.dart';
import 'package:proje_takip/services/db_task_service.dart';
import 'package:proje_takip/utils/app_dialogs.dart';
import 'package:proje_takip/utils/custom_container.dart';
import 'package:proje_takip/utils/responsive.dart';

class AddTaskPage extends StatefulWidget {
  final int projectId;

  const AddTaskPage({super.key, required this.projectId});

  @override
  AddTaskPageState createState() => AddTaskPageState();
}

class AddTaskPageState extends State<AddTaskPage> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _manHourController = TextEditingController();
  DateTime? _startDate;
  DateTime? _endDate;
  Employee? _selectedEmployee;
  List<Employee>? employees;
  bool isLoading = true;

  @override
  void initState() {
    _fetchEmployees();
    super.initState();
  }

  @override
  void dispose() {
    _nameController.dispose();
    _manHourController.dispose();
    super.dispose();
  }

  Future<void> _fetchEmployees() async {
    employees = await DbEmployeeService().getAllEmployees();

    setState(() {
      isLoading = false;
    });
  }

  Future<void> _addTask() async {
    if (_formKey.currentState!.validate()) {
      if (_startDate == null) {
        AppDialogs.showErrorDialog(
            context, 'Lütfen başlangıç tarihini seçiniz.');
        return;
      }

      if (_endDate == null) {
        AppDialogs.showErrorDialog(context, 'Lütfen bitiş tarihini seçiniz.');
        return;
      }

      if (_startDate!.isAfter(_endDate!)) {
        AppDialogs.showErrorDialog(
            context, 'Başlangıç tarihi, bitiş tarihinden önce olmalıdır.');
        return;
      }

      late double manHour;
      try {
        manHour = double.parse(_manHourController.text);
      } catch (e) {
        AppDialogs.showErrorDialog(context, 'Yalnızca sayı giriniz');
        return;
      }
      int? taskId = await DbTaskService().addTask(
        widget.projectId,
        _selectedEmployee?.id,
        _nameController.text,
        manHour,
        DateFormat(appDateTimeFormat).format(_startDate!),
        DateFormat(appDateTimeFormat).format(_endDate!),
        taskStatusEnumToString(TaskStatus.tamamlanacak),
      );

      if (_selectedEmployee != null && taskId != null) {
        await DbEmployeeService().updateEmployee(
          id: _selectedEmployee!.id,
          name: _selectedEmployee!.name,
          password: _selectedEmployee!.password,
          activeProjectId: widget.projectId,
          activeTaskId: taskId,
        );
      }

      Navigator.pop(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Görev Ekle'),
        backgroundColor: Colors.indigo[900],
      ),
      body: Padding(
        padding: Responsive.pagePadding(context),
        child: CustomContainer(
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                TextFormField(
                  controller: _nameController,
                  decoration: InputDecoration(
                    labelText: 'Görev Adı',
                    border: OutlineInputBorder(),
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Lütfen görev adı girin';
                    }
                    return null;
                  },
                ),
                SizedBox(height: 16),
                TextFormField(
                  controller: _manHourController,
                  decoration: InputDecoration(
                    labelText: 'Adam Gün Değeri',
                    border: OutlineInputBorder(),
                  ),
                  keyboardType: TextInputType.number,
                  validator: (v) => onlyNumbersValidator(v),
                ),
                SizedBox(height: 16),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: FormField<DateTime>(
                        validator: (value) {
                          if (_startDate == null) {
                            return 'Başlangıç tarihi seçilmelidir';
                          }
                          return null;
                        },
                        builder: (formFieldState) {
                          return Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text('Başlangıç Tarihi',
                                  style: TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.w600)),
                              SizedBox(height: 8),
                              ElevatedButton(
                                onPressed: () async {
                                  _selectStartDate(context);
                                },
                                style: ElevatedButton.styleFrom(
                                  padding: EdgeInsets.symmetric(
                                      vertical: 16, horizontal: 22),
                                  backgroundColor: _startDate == null
                                      ? Colors.indigo[300]
                                      : Colors.indigo,
                                ),
                                child: Text(
                                  _startDate != null
                                      ? DateFormat(appDateTimeFormat)
                                          .format(_startDate!)
                                      : 'Tarih seçiniz',
                                ),
                              ),
                              if (formFieldState.hasError)
                                Padding(
                                  padding: const EdgeInsets.only(top: 8.0),
                                  child: Text(
                                    formFieldState.errorText!,
                                    style: TextStyle(color: Colors.red),
                                  ),
                                ),
                            ],
                          );
                        },
                      ),
                    ),
                    SizedBox(width: 32),
                    Expanded(
                      child: FormField<DateTime>(
                        validator: (value) {
                          if (_endDate == null) {
                            return 'Bitiş tarihi seçilmelidir';
                          }
                          if (_startDate != null &&
                              _endDate!.isBefore(_startDate!)) {
                            return 'Bitiş tarihi, başlangıç tarihinden sonra olmalıdır';
                          }
                          return null;
                        },
                        builder: (formFieldState) {
                          return Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text('Bitiş Tarihi',
                                  style: TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.w600)),
                              SizedBox(height: 8),
                              ElevatedButton(
                                onPressed: () async {
                                  _selectEndDate(context);
                                  setState(() {});
                                },
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: _endDate == null
                                      ? Colors.indigo[300]
                                      : Colors.indigo,
                                ),
                                child: Text(
                                  _endDate != null
                                      ? DateFormat(appDateTimeFormat)
                                          .format(_endDate!)
                                      : 'Tarih seçiniz',
                                ),
                              ),
                              if (formFieldState.hasError)
                                Padding(
                                  padding: const EdgeInsets.only(top: 8.0),
                                  child: Text(
                                    formFieldState.errorText!,
                                    style: TextStyle(color: Colors.red),
                                  ),
                                ),
                            ],
                          );
                        },
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 32),
                isLoading
                    ? Center(child: CircularProgressIndicator())
                    : DropdownButtonFormField<Employee?>(
                        value: _selectedEmployee,
                        onChanged: (Employee? newValue) {
                          setState(() {
                            _selectedEmployee = newValue;
                          });
                        },
                        decoration: InputDecoration(
                          fillColor: Colors.white70,
                          filled: true,
                          labelText: 'Çalışan Seç',
                          border: OutlineInputBorder(),
                        ),
                        items: [
                          DropdownMenuItem<Employee?>(
                            value: null,
                            child: Text('Seçim Yok'),
                          ),
                          ...employees!.map<DropdownMenuItem<Employee>>(
                              (Employee employee) {
                            return DropdownMenuItem<Employee>(
                              value: employee,
                              child: Text(employee.name),
                            );
                          }),
                        ],
                      ),
                SizedBox(height: 20),
                Center(
                  child: ElevatedButton(
                    onPressed: _addTask,
                    style: ElevatedButton.styleFrom(
                      padding:
                          EdgeInsets.symmetric(horizontal: 32, vertical: 16),
                      backgroundColor: Colors.indigo[700],
                    ),
                    child: Text(
                      'Görevi Ekle',
                      style:
                          TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _selectStartDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _startDate ?? DateTime.now(),
      firstDate: DateTime(2020),
      lastDate: DateTime(2101),
    );

    if (picked != null) {
      setState(() {
        _startDate = picked;
      });
    }
  }

  void _selectEndDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _endDate ?? (_startDate ?? DateTime.now()),
      firstDate: _startDate ?? DateTime.now(),
      lastDate: DateTime(2101),
    );

    if (picked != null) {
      setState(() {
        _endDate = picked;
      });
    }
  }
}
