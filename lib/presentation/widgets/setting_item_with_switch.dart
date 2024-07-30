import 'package:flutter/material.dart';
import 'custom_switch.dart';

class SettingsItemWithSwitch extends StatelessWidget {
  final IconData icon;
  final String text;
  final bool switchValue;
  final ValueChanged<bool> onSwitchChanged;

  SettingsItemWithSwitch({
    required this.icon,
    required this.text,
    required this.switchValue,
    required this.onSwitchChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        ListTile(
          leading: Icon(icon),
          contentPadding: EdgeInsets.symmetric(horizontal: 16),
          title: Text(
            text,
            style: TextStyle(fontWeight: FontWeight.w400),
          ),
          trailing: CustomSwitch(
            value: switchValue,
            onChanged: onSwitchChanged,
          ),
        ),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0),
          child: Divider(
            height: 0.0,
            thickness: 0.5,
            color: Colors.grey,
          ),
        ),
      ],
    );
  }
}
