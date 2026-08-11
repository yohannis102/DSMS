import 'package:flutter/material.dart';
import 'onboarding_model.dart';
import 'onboarding_service.dart';

class OnboardingController extends ChangeNotifier {
  final OnboardingService _service = OnboardingService();
  final PageController pageController = PageController();

  int _currentIndex = 0;
  int get currentIndex => _currentIndex;

  final List<OnboardingModel> items = const [
    OnboardingModel(
      title: "Schedule Driving Lessons Easily",
      description:
          "Book practical driving sessions with certified instructors, manage your timetable, and choose convenient time slots.",
      assetPath: "assets/images/driving_car.json",
    ),
    OnboardingModel(
      title: "Track Progress & Practice Tests",
      description:
          "Monitor your practical driving hours, complete theory mock exams, and master road safety rules.",
      assetPath: "assets/images/traffic_light.json",
    ),
    OnboardingModel(
      title: "Get Licensed & Hit the Road",
      description:
          "Pass your final driving test with confidence, track your certification status, and get ready to drive safely.",
      assetPath: "assets/images/driver_license.json",
    ),
  ];

  bool get isLastPage => _currentIndex == items.length - 1;

  void onPageChanged(int index) {
    _currentIndex = index;
    notifyListeners();
  }

  void nextPage() {
    if (!isLastPage) {
      pageController.nextPage(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    }
  }

  void skipToLast() {
    pageController.jumpToPage(items.length - 1);
  }

  Future<void> completeOnboarding(VoidCallback onComplete) async {
    await _service.setOnboardingCompleted();
    onComplete();
  }

  @override
  void dispose() {
    pageController.dispose();
    super.dispose();
  }
}
