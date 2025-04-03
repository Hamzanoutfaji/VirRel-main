import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  bool _notificationsEnabled = true;

  void _contactSupport() async {
    final Uri emailLaunchUri = Uri(
      scheme: 'mailto',
      path: 'support@virtualrelief.com',
      query: Uri.encodeFull('subject=Support Needed&body=Hello, I need help with...'),
    );
    if (await canLaunchUrl(emailLaunchUri)) {
      await launchUrl(emailLaunchUri);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Could not open email client")),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Settings")),
      body: ListView(
        children: [
          SwitchListTile(
            value: _notificationsEnabled,
            onChanged: (val) {
              setState(() => _notificationsEnabled = val);
            },
            title: const Text("Enable Notifications"),
          ),
          ListTile(
            leading: Icon(Icons.mail_outline),
            title: Text("Contact Support"),
            onTap: _contactSupport,
          ),
          ListTile(
            leading: Icon(Icons.info_outline),
            title: Text("About"),
            subtitle: Text("Version 1.0.0"),
          ),
        ],
      ),
    );
  }
}
