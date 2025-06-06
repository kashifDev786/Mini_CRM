import 'package:flutter/material.dart';
import 'package:mini_crm/utils/helper.dart';
import 'package:provider/provider.dart';
import 'package:hive/hive.dart';
import 'package:package_info_plus/package_info_plus.dart';

import '../bloc_files/dashboard_bloc/dashboard_bloc.dart';
import '../bloc_files/contacts_bloc/contact_bloc.dart';
import '../bloc_files/contacts_bloc/contacts_event.dart';
import '../bloc_files/leads_bloc/leads_bloc.dart';
import '../utils/helper.dart';
import '../utils/theme_provider.dart';

class DashboardAppBar extends StatefulWidget implements PreferredSizeWidget {
  const DashboardAppBar({super.key});

  @override
  State<DashboardAppBar> createState() => _DashboardAppBarState();

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);
}

class _DashboardAppBarState extends State<DashboardAppBar> {
  String appVersion = '';

  @override
  void initState() {
    super.initState();
    _getAppVersion();
  }

  Future<void> _getAppVersion() async {
    final info = await PackageInfo.fromPlatform();
    setState(() {
      appVersion = info.version;
    });
  }


  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);
    final isDark = themeProvider.themeMode == ThemeMode.dark;

    return AppBar(
      title: const Text("Dashboard",style: TextStyle(color: Colors.white),),
      backgroundColor: Colors.deepPurple,

      actions: [
        PopupMenuButton<String>(
          iconColor: Colors.white,
          onSelected: (value) async{
            switch (value) {
              case 'toggle_theme':
                themeProvider.toggleTheme(!isDark);
                break;
              case 'clear_cache':
                final confirm = await Helper().showConfirmationDialog(
                  context: context,
                  title: 'Clear Cache',
                  message: 'Are you sure you want to delete all leads, contacts, and activity history?',
                  confirmText: 'Clear',
                );
                if (confirm) {
                  await Helper().clearAllCache(context);
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Cache cleared')),
                  );
                  context.read<LeadsBloc>().add(LoadLeads());
                  context.read<ContactsBloc>().add(LoadContacts());
                  context.read<DashboardBloc>().add(LoadDashboardData());
                }

                break;
              case 'show_version':
                showDialog(
                  context: context,
                  builder: (_) => AlertDialog(
                    title: const Text('App Version'),
                    content: Text(appVersion),
                    actions: [
                      TextButton(
                        child: const Text("OK"),
                        onPressed: () => Navigator.pop(context),
                      )
                    ],
                  ),
                );
                break;
            }
          },
          itemBuilder: (context) => [
            PopupMenuItem(
              value: 'toggle_theme',
              child: Row(
                children: [
                  Icon(isDark ? Icons.light_mode : Icons.dark_mode),
                  const SizedBox(width: 8),
                  Text(isDark ? 'Switch to Light' : 'Switch to Dark'),
                ],
              ),
            ),
            const PopupMenuItem(
              value: 'clear_cache',
              child: Row(
                children: [
                  Icon(Icons.delete),
                  SizedBox(width: 8),
                  Text('Clear Cache'),
                ],
              ),
            ),
            const PopupMenuItem(
              value: 'show_version',
              child: Row(
                children: [
                  Icon(Icons.info_outline),
                  SizedBox(width: 8),
                  Text('App Version'),
                ],
              ),
            ),
          ],
        ),
      ],
    );
  }
}
