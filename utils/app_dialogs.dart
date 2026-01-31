import 'dart:async';
import 'package:flutter/material.dart';

class AppDialogs {
  AppDialogs._();

  static Future<bool?> showConfirmDialog(
    BuildContext context, {
    String title = 'Emin misiniz?',
    String content = 'Bu işlemi yapmak istediğinizden emin misiniz?',
    String confirmText = 'Evet',
    String cancelText = 'Hayır',
  }) {
    return showDialog<bool>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text(title),
          content: Text(content),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(false),
              child: Text(cancelText),
            ),
            ElevatedButton(
              onPressed: () => Navigator.of(context).pop(true),
              child: Text(confirmText),
            ),
          ],
        );
      },
    );
  }

  static void showErrorDialog(BuildContext context, String errorMessage) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text(
            'Başarısız',
            style: TextStyle(color: Colors.red),
          ),
          content: Text(errorMessage),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: const Text('Tamam'),
            ),
          ],
        );
      },
    );
  }

  static showSuccedDialog(BuildContext context,
      {String title = 'İşlem başarılı', bool autoClose = true}) {
    late Timer timer;
    showModalBottomSheet(
      elevation: 0,
      context: context,
      barrierColor: Colors.transparent,
      backgroundColor: const Color.fromARGB(255, 146, 209, 137),
      builder: (BuildContext builderContext) {
        if (autoClose) {
          timer = Timer(const Duration(milliseconds: 1000), () {
            if (builderContext.mounted &&
                Navigator.of(builderContext).canPop()) {
              Navigator.of(builderContext).pop();
            }
          });
        }

        return Container(
          alignment: Alignment.center,
          height: 60,
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Text(
            "$title!",
            style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
          ),
        );
      },
    ).then((val) {
      if (autoClose && timer.isActive) {
        timer.cancel();
      }
    });
  }
}
