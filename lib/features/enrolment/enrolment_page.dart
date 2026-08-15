import 'package:flutter/material.dart';
import '../../core/widgets/scrollable_table_wrapper.dart';
import 'enrolment_controller.dart';

class EnrolmentPage extends StatefulWidget {
  const EnrolmentPage({super.key});

  @override
  State<EnrolmentPage> createState() => _EnrolmentPageState();
}

class _EnrolmentPageState extends State<EnrolmentPage> {
  late final EnrolmentController _controller;

  @override
  void initState() {
    super.initState();
    _controller = EnrolmentController();
    _controller.addListener(_onUpdate);
  }

  void _onUpdate() {
    if (mounted) setState(() {});
  }

  @override
  void dispose() {
    _controller.removeListener(_onUpdate);
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF4F6F9),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: const [
                Text(
                  'Enrolments Management',
                  style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Color(0xFF1E293B)),
                ),
                Text('Home / Enrolment', style: TextStyle(color: Color(0xFF64748B))),
              ],
            ),
            const SizedBox(height: 20),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(8),
                boxShadow: const [BoxShadow(color: Colors.black12, blurRadius: 4)],
              ),
              child: _controller.isLoading
                  ? const Center(child: CircularProgressIndicator())
                  : ScrollableTableWrapper(
                      child: DataTable(
                        columns: const [
                          DataColumn(label: Text('Enrolment ID')),
                          DataColumn(label: Text('Student Name')),
                          DataColumn(label: Text('Package')),
                          DataColumn(label: Text('Date')),
                          DataColumn(label: Text('Payment Status')),
                        ],
                        rows: _controller.enrolments
                            .map(
                              (e) => DataRow(cells: [
                                DataCell(Text(e.enrolmentId)),
                                DataCell(Text(e.studentName)),
                                DataCell(Text(e.packageName)),
                                DataCell(Text(e.enrolmentDate)),
                                DataCell(Text(e.paymentStatus)),
                              ]),
                            )
                            .toList(),
                      ),
                    ),
            ),
          ],
        ),
      ),
    );
  }
}
