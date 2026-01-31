import 'package:flutter/material.dart';
import 'package:proje_takip/models/employee.dart';
import 'package:proje_takip/screen/admin_page/add_employee.dart';
import 'package:proje_takip/screen/admin_page/employee_details_page.dart';
import 'package:proje_takip/services/db_employee_service.dart';
import 'package:proje_takip/utils/custom_container.dart';
import 'package:proje_takip/utils/responsive.dart';

class EmployeeListPage extends StatefulWidget {
  const EmployeeListPage({super.key});

  @override
  State<EmployeeListPage> createState() => _EmployeeListPageState();
}

class _EmployeeListPageState extends State<EmployeeListPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Çalışanlar'),
      ),
      body: Padding(
        padding: Responsive.pagePadding(context),
        child: CustomContainer(
          child: Column(
            children: [
              Expanded(
                child: FutureBuilder<List<Employee>>(
                  future: DbEmployeeService().getAllEmployees(),
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return Center(child: CircularProgressIndicator());
                    } else if (snapshot.hasError) {
                      return Center(child: Text('Hata: ${snapshot.error}'));
                    } else if (snapshot.hasData) {
                      final employees = snapshot.data!;
                      if (employees.isEmpty) {
                        return Center(child: Text('Henüz çalışan eklenmedi.'));
                      }
                      return ListView.builder(
                        itemCount: employees.length,
                        itemBuilder: (context, index) {
                          final employee = employees[index];
                          return Card(
                            elevation: 5,
                            margin: EdgeInsets.symmetric(vertical: 8.0),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: ListTile(
                              contentPadding: EdgeInsets.all(16),
                              title: Text(
                                employee.name,
                                style: TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              subtitle: Text('ID: ${employee.id}'),
                              trailing: Icon(Icons.arrow_forward),
                              onTap: () {
                                Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                        builder: (context) =>
                                            EmployeeDetailsPage(
                                                employee:
                                                    employee))).then((value) =>
                                    (value ?? false) ? setState(() {}) : null);
                              },
                            ),
                          );
                        },
                      );
                    } else {
                      return Center(child: Text('Henüz çalışan eklenmedi.'));
                    }
                  },
                ),
              ),
              SizedBox(height: 16),
              ElevatedButton(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => AddEmployeePage()),
                  ).then(
                    (value) => setState(() {}),
                  );
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.indigo[600],
                  padding: EdgeInsets.symmetric(horizontal: 20, vertical: 20),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(30),
                  ),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.add),
                    SizedBox(width: 8),
                    Text('Yeni Çalışan Ekle', style: TextStyle(fontSize: 16)),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
