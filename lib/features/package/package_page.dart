import 'package:flutter/material.dart';
import 'package_controller.dart';

class PackagePage extends StatefulWidget {
  const PackagePage({super.key});

  @override
  State<PackagePage> createState() => _PackagePageState();
}

class _PackagePageState extends State<PackagePage> {
  late final PackageController _controller;

  @override
  void initState() {
    super.initState();
    _controller = PackageController();
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
                  'Training Packages',
                  style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Color(0xFF1E293B)),
                ),
                Text('Home / Package', style: TextStyle(color: Color(0xFF64748B))),
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
                  : SingleChildScrollView(
                      scrollDirection: Axis.horizontal,
                      child: DataTable(
                        columns: const [
                          DataColumn(label: Text('Package ID')),
                          DataColumn(label: Text('Package Name')),
                          DataColumn(label: Text('Price')),
                          DataColumn(label: Text('Duration')),
                          DataColumn(label: Text('Description')),
                        ],
                        rows: _controller.packages
                            .map(
                              (pkg) => DataRow(cells: [
                                DataCell(Text(pkg.id)),
                                DataCell(Text(pkg.packageName)),
                                DataCell(Text('${pkg.price.toStringAsFixed(0)} ETB')),
                                DataCell(Text(pkg.duration)),
                                DataCell(Text(pkg.description)),
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
