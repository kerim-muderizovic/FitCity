import 'package:flutter/material.dart';
import '../../theme/app_theme.dart';
import '../../widgets/common.dart';

class DesktopMembersScreen extends StatelessWidget {
  const DesktopMembersScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
          decoration: const BoxDecoration(
            border: Border(bottom: BorderSide(color: AppColors.slate, width: 1.2)),
          ),
          child: Row(
            children: [
              Text('FitCity App', style: Theme.of(context).textTheme.titleMedium),
              const SizedBox(width: 32),
              const Text('Dashboard'),
              const SizedBox(width: 18),
              const Text('Members', style: TextStyle(fontWeight: FontWeight.w700)),
              const SizedBox(width: 18),
              const Text('Trainers'),
              const Spacer(),
            ],
          ),
        ),
        Expanded(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                AccentButton(label: 'Scan QR Code', width: 160, onPressed: () {}),
                const SizedBox(width: 24),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text('Members', style: Theme.of(context).textTheme.titleMedium),
                          AccentButton(label: '+ Add member', onPressed: () {}),
                        ],
                      ),
                      const SizedBox(height: 16),
                      Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(14),
                        ),
                        child: DataTable(
                          headingRowColor: WidgetStateProperty.all(AppColors.slate),
                          columns: const [
                            DataColumn(label: Text('Name')),
                            DataColumn(label: Text('Email')),
                            DataColumn(label: Text('Membership')),
                          ],
                          rows: const [
                            DataRow(cells: [
                              DataCell(Text('John Doe 1')),
                              DataCell(Text('johndoe@gmail.com')),
                              DataCell(Text('Annual')),
                            ]),
                            DataRow(cells: [
                              DataCell(Text('John Doe 1')),
                              DataCell(Text('johndoe@gmail.com')),
                              DataCell(Text('Monthly')),
                            ]),
                            DataRow(cells: [
                              DataCell(Text('John Doe 1')),
                              DataCell(Text('johndoe@gmail.com')),
                              DataCell(Text('Annual')),
                            ]),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}
