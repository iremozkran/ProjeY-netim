import 'package:flutter/material.dart';
import 'package:proje_takip/helper/app_constants.dart';
import 'package:proje_takip/models/project.dart';
import 'package:proje_takip/screen/admin_page/project_details_page.dart';
import 'package:proje_takip/services/db_project_service.dart';
import 'package:intl/intl.dart';
import 'package:proje_takip/utils/custom_container.dart';
import 'package:proje_takip/utils/responsive.dart';

class AddProjectPage extends StatefulWidget {
  const AddProjectPage({super.key});

  @override
  AddProjectPageState createState() => AddProjectPageState();
}

class AddProjectPageState extends State<AddProjectPage> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  DateTime? _startDate;
  DateTime? _endDate;

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

  void _saveProject() async {
    if (_formKey.currentState!.validate()) {
      if (_startDate == null || _endDate == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
              content: Text('Lütfen başlangıç ve bitiş tarihlerini seçiniz.')),
        );
        return;
      }

      int newProjectId = await DbProjectService().addProject(
        _nameController.text,
        DateFormat(appDateTimeFormat).format(_startDate!),
        DateFormat(appDateTimeFormat).format(_endDate!),
      );

      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (context) => ProjectDetailsPage(
            project: Project(
              id: newProjectId,
              name: _nameController.text,
              startDate: DateFormat(appDateTimeFormat).format(_startDate!),
              targetEndDate: DateFormat(appDateTimeFormat).format(_endDate!),
            ),
          ),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Yeni Proje Ekle'),
      ),
      body: Padding(
        padding: Responsive.pagePadding(context),
        child: CustomContainer(
          child: Form(
            key: _formKey,
            child: ListView(
              children: [
                TextFormField(
                  controller: _nameController,
                  decoration: InputDecoration(
                    labelText: 'Proje Adı',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Proje adı giriniz.';
                    }
                    return null;
                  },
                ),
                SizedBox(height: 16),
                GestureDetector(
                  onTap: () => _selectStartDate(context),
                  child: AbsorbPointer(
                    child: TextFormField(
                      controller: TextEditingController(
                          text: _startDate != null
                              ? DateFormat(appDateTimeFormat)
                                  .format(_startDate!)
                              : ''),
                      decoration: InputDecoration(
                        labelText: 'Başlama Tarihi',
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                      validator: (value) {
                        if (_startDate == null) {
                          return 'Başlama tarihi seçiniz.';
                        }
                        return null;
                      },
                    ),
                  ),
                ),
                SizedBox(height: 16),
                GestureDetector(
                  onTap: () => _selectEndDate(context),
                  child: AbsorbPointer(
                    child: TextFormField(
                      controller: TextEditingController(
                          text: _endDate != null
                              ? DateFormat(appDateTimeFormat).format(_endDate!)
                              : ''),
                      decoration: InputDecoration(
                        labelText: 'Bitiş Tarihi',
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                      validator: (value) {
                        if (_endDate == null) {
                          return 'Bitiş tarihi seçiniz.';
                        }
                        return null;
                      },
                    ),
                  ),
                ),
                SizedBox(height: 24),
                Align(
                  alignment: Alignment.center,
                  child: ElevatedButton.icon(
                    onPressed: _saveProject,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.indigo,
                      padding:
                          EdgeInsets.symmetric(horizontal: 24, vertical: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    icon: Icon(Icons.save, color: Colors.white),
                    label: Text(
                      'Kaydet',
                      style: TextStyle(fontSize: 16, color: Colors.white),
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
}
