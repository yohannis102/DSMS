import 'package:flutter/material.dart';
import 'package:toastification/toastification.dart';

class AppToast {
  AppToast._();

  static const Duration _defaultDuration = Duration(milliseconds: 2500);

  static void showSuccess({
    required BuildContext context,
    required String title,
    String? description,
  }) {
    toastification.show(
      context: context,
      type: ToastificationType.success,
      style: ToastificationStyle.simple,
      title: Text(
        title,
        style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 13),
      ),
      description: description != null
          ? Text(
              description,
              style: const TextStyle(fontSize: 12),
            )
          : null,
      alignment: Alignment.topCenter,
      autoCloseDuration: _defaultDuration,
      showProgressBar: false,
      borderRadius: BorderRadius.circular(10),
      boxShadow: const [
        BoxShadow(
          color: Color(0x0D000000),
          blurRadius: 10,
          offset: Offset(0, 2),
        ),
      ],
    );
  }

  static void showError({
    required BuildContext context,
    required String title,
    String? description,
  }) {
    toastification.show(
      context: context,
      type: ToastificationType.error,
      style: ToastificationStyle.simple,
      title: Text(
        title,
        style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 13),
      ),
      description: description != null
          ? Text(
              description,
              style: const TextStyle(fontSize: 12),
            )
          : null,
      alignment: Alignment.topCenter,
      autoCloseDuration: const Duration(seconds: 3),
      showProgressBar: false,
      borderRadius: BorderRadius.circular(10),
      boxShadow: const [
        BoxShadow(
          color: Color(0x0D000000),
          blurRadius: 10,
          offset: Offset(0, 2),
        ),
      ],
    );
  }

  static void showWarning({
    required BuildContext context,
    required String title,
    String? description,
  }) {
    toastification.show(
      context: context,
      type: ToastificationType.warning,
      style: ToastificationStyle.simple,
      title: Text(
        title,
        style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 13),
      ),
      description: description != null
          ? Text(
              description,
              style: const TextStyle(fontSize: 12),
            )
          : null,
      alignment: Alignment.topCenter,
      autoCloseDuration: _defaultDuration,
      showProgressBar: false,
      borderRadius: BorderRadius.circular(10),
      boxShadow: const [
        BoxShadow(
          color: Color(0x0D000000),
          blurRadius: 10,
          offset: Offset(0, 2),
        ),
      ],
    );
  }

  static void showInfo({
    required BuildContext context,
    required String title,
    String? description,
  }) {
    toastification.show(
      context: context,
      type: ToastificationType.info,
      style: ToastificationStyle.simple,
      title: Text(
        title,
        style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 13),
      ),
      description: description != null
          ? Text(
              description,
              style: const TextStyle(fontSize: 12),
            )
          : null,
      alignment: Alignment.topCenter,
      autoCloseDuration: const Duration(seconds: 2),
      showProgressBar: false,
      borderRadius: BorderRadius.circular(10),
      boxShadow: const [
        BoxShadow(
          color: Color(0x0D000000),
          blurRadius: 10,
          offset: Offset(0, 2),
        ),
      ],
    );
  }
}

