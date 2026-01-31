import 'package:flutter/material.dart';
import 'package:proje_takip/models/project.dart';
import 'package:proje_takip/screen/admin_page/add_project.dart';
import 'package:proje_takip/screen/admin_page/list_employee_page.dart';
import 'package:proje_takip/screen/admin_page/project_details_page.dart';
import 'package:proje_takip/screen/login_page.dart';
import 'package:proje_takip/services/db_project_service.dart';
import 'package:proje_takip/utils/app_dialogs.dart';
import 'package:proje_takip/utils/app_elevated_button.dart';
import 'package:proje_takip/utils/custom_container.dart';
import 'package:proje_takip/utils/responsive.dart';

class AdminHomePage extends StatefulWidget {
  const AdminHomePage({super.key});

  @override
  State<AdminHomePage> createState() => _AdminHomePageState();
}

class _AdminHomePageState extends State<AdminHomePage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Yönetici Paneli',
            style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
        centerTitle: true,
        actions: [
          IconButton(
            icon: Icon(Icons.logout),
            onPressed: () {
              AppDialogs.showConfirmDialog(context,
                      content: 'Çıkış yapak istediğinden emin misin?')
                  .then(
                (value) => (value ?? false)
                    ? Navigator.pushReplacement(context,
                        MaterialPageRoute(builder: (context) => LoginPage()))
                    : null,
              );
            },
          )
        ],
      ),
      body: Padding(
        padding: Responsive.pagePadding(context),
        child: CustomContainer(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: Text(
                  'Hoş Geldiniz! Yönetici Paneline Erişiminiz Var.',
                  style: TextStyle(fontSize: 20, color: Colors.indigo[800]),
                  textAlign: TextAlign.center,
                ),
              ),
              SizedBox(height: 20),
              Text(
                'Projeler:',
                style: TextStyle(fontSize: 18, color: Colors.indigo[600]),
              ),
              Expanded(
                child: FutureBuilder<List<Project>>(
                  future: DbProjectService().getAllProjects(),
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return Center(child: CircularProgressIndicator());
                    } else if (snapshot.hasError) {
                      return Center(child: Text('Hata: ${snapshot.error}'));
                    } else if (snapshot.hasData) {
                      final projects = snapshot.data!;
                      if (projects.isEmpty) {
                        return Center(child: Text('Henüz proje yok.'));
                      }
                      return ListView.builder(
                        itemCount: projects.length,
                        itemBuilder: (context, index) {
                          final project = projects[index];
                          return Card(
                            elevation: 5,
                            margin: EdgeInsets.symmetric(vertical: 8.0),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(15),
                            ),
                            child: ListTile(
                              contentPadding: EdgeInsets.all(16),
                              title: Text(
                                project.name,
                                style: TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.indigo[700],
                                ),
                              ),
                              subtitle: Text(
                                'Başlama: ${project.startDate}, Bitiş: ${project.targetEndDate}',
                                style: TextStyle(color: Colors.grey[700]),
                              ),
                              trailing: Icon(Icons.arrow_forward_ios,
                                  color: Colors.indigo[800]),
                              onTap: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => ProjectDetailsPage(
                                      project: project,
                                    ),
                                  ),
                                );
                              },
                            ),
                          );
                        },
                      );
                    } else {
                      return Center(child: Text('Henüz proje yok.'));
                    }
                  },
                ),
              ),
              SizedBox(height: 20),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  AppElevatedButton(
                      title: 'Yeni Proje Ekle',
                      icon: Icons.add,
                      onPressed: () => Navigator.push(
                              context,
                              MaterialPageRoute(
                                  builder: (context) => AddProjectPage())).then(
                            (value) => setState(() {}),
                          )),
                  AppElevatedButton(
                    title: 'Çalışanlar',
                    icon: Icons.people,
                    onPressed: () => Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (context) => EmployeeListPage()),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
