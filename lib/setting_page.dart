import 'package:flutter/material.dart';

class SettingsPage extends StatefulWidget {
  final String currentIp;
  final double linearScale;
  final double angularScale;

  const SettingsPage({
    super.key,
    required this.currentIp,
    required this.linearScale,
    required this.angularScale,
  });

  @override
  State<SettingsPage> createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {
  late TextEditingController ipController;
  late TextEditingController linearController;
  late TextEditingController angularController;

  @override
  void initState() {
    super.initState();
    ipController = TextEditingController(text: widget.currentIp);
    linearController = TextEditingController(text: widget.linearScale.toString());
    angularController = TextEditingController(text: widget.angularScale.toString());
  }

  void saveAndExit() {
    Navigator.pop(context, {
      "ip": ipController.text,
      "linear": double.tryParse(linearController.text) ?? 1.0,
      "angular": double.tryParse(angularController.text) ?? 1.0,
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Center(
          child: Column(
            children: [
              const Text("Settings", style: TextStyle(fontSize: 24)),

              const SizedBox(height: 20),

              SizedBox(
                width: 250,
                child: TextField(
                  controller: ipController,
                  decoration: const InputDecoration(
                    labelText: "Server IP",
                    border: OutlineInputBorder(),
                  ),
                ),
              ),

              const SizedBox(height: 20),

              /// Linear Velocity Scale
              SizedBox(
                width: 250,
                child: TextField(
                  controller: linearController,
                  keyboardType: TextInputType.number,
                  decoration: const InputDecoration(
                    labelText: "Linear Velocity Scale",
                    border: OutlineInputBorder(),
                  ),
                ),
              ),

              const SizedBox(height: 20),

              /// Angular Velocity Scale
              SizedBox(
                width: 250,
                child: TextField(
                  controller: angularController,
                  keyboardType: TextInputType.number,
                  decoration: const InputDecoration(
                    labelText: "Angular Velocity Scale",
                    border: OutlineInputBorder(),
                  ),
                ),
              ),

              ElevatedButton(onPressed: saveAndExit, child: const Text("Save")),
            ],
          ),
        )
        ),
    );
  }
}
