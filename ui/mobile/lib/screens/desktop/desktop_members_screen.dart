import 'package:flutter/material.dart';
import '../../l10n/l10n.dart';
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
              Text(context.l10n.desktopAppName, style: Theme.of(context).textTheme.titleMedium),
              const SizedBox(width: 32),
              Text(context.l10n.commonDashboard),
              const SizedBox(width: 18),
              Text(context.l10n.commonMembers, style: const TextStyle(fontWeight: FontWeight.w700)),
              const SizedBox(width: 18),
              Text(context.l10n.commonTrainers),
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
                AccentButton(label: context.l10n.adminScanQrCode, width: 160, onPressed: () {}),
                const SizedBox(width: 24),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(context.l10n.commonMembers, style: Theme.of(context).textTheme.titleMedium),
                          AccentButton(label: context.l10n.adminAddMemberPlus, onPressed: () {}),
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
                          columns: [
                            DataColumn(label: Text(context.l10n.commonName)),
                            DataColumn(label: Text(context.l10n.commonEmail)),
                            DataColumn(label: Text(context.l10n.commonMembership)),
                          ],
                          rows: [
                            DataRow(cells: [
                              DataCell(Text(context.l10n.sampleMemberName)),
                              DataCell(Text(context.l10n.sampleMemberEmail)),
                              DataCell(Text(context.l10n.membershipAnnual)),
                            ]),
                            DataRow(cells: [
                              DataCell(Text(context.l10n.sampleMemberName)),
                              DataCell(Text(context.l10n.sampleMemberEmail)),
                              DataCell(Text(context.l10n.membershipMonthly)),
                            ]),
                            DataRow(cells: [
                              DataCell(Text(context.l10n.sampleMemberName)),
                              DataCell(Text(context.l10n.sampleMemberEmail)),
                              DataCell(Text(context.l10n.membershipAnnual)),
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
