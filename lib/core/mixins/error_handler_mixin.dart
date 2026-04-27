import 'package:flutter/material.dart';
import 'package:cargoind/core/exceptions/api_exception.dart';

mixin ErrorHandlerMixin {
  void handleError(BuildContext context, dynamic error, {VoidCallback? onAuthError}) {
    String errorMessage = 'Terjadi kesalahan';
    
    if (error is ApiException) {
      if (error.isAuthError) {
        _showAuthErrorDialog(context, onAuthError);
        return;
      }
      errorMessage = error.message;
    } else {
      errorMessage = error.toString();
    }
    
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(errorMessage),
        backgroundColor: Colors.red,
      ),
    );
  }

  void _showAuthErrorDialog(BuildContext context, VoidCallback? onAuthError) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        title: const Text('Sesi Berakhir'),
        content: const Text('Sesi Anda telah berakhir. Silakan login ulang.'),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
              if (onAuthError != null) {
                onAuthError();
              } else {
                Navigator.pushReplacementNamed(context, '/login');
              }
            },
            child: const Text('Login Ulang'),
          ),
        ],
      ),
    );
  }

  void showSuccessMessage(BuildContext context, String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.green,
      ),
    );
  }
}