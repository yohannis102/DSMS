import 'package:flutter/material.dart';
import 'payment_model.dart';
import 'payment_service.dart';

class PaymentController extends ChangeNotifier {
  final PaymentService _service = PaymentService();

  bool _isLoading = false;
  bool get isLoading => _isLoading;

  List<PaymentModel> _payments = [];
  List<PaymentModel> get payments => _payments;

  PaymentController() {
    loadPayments();
  }

  Future<void> loadPayments() async {
    _isLoading = true;
    notifyListeners();

    try {
      _payments = await _service.fetchPayments();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
}
