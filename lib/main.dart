import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:mobile_joystick/turn_button.dart';
import 'package:mobile_joystick/joystick.dart';
import 'dart:async';
import 'dart:convert';
import 'package:mobile_joystick/tcp_client.dart';
import 'package:mobile_joystick/setting_page.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await SystemChrome.setPreferredOrientations([
    DeviceOrientation.landscapeLeft,
    DeviceOrientation.landscapeRight,
  ]);

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});
  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      home: JoystickScreen(),
      debugShowCheckedModeBanner: false,
    );
  }
}

class JoystickScreen extends StatefulWidget {
  const JoystickScreen({super.key});

  @override
  State<JoystickScreen> createState() => _JoystickScreenState();
}

class _JoystickScreenState extends State<JoystickScreen> {
  String serverIp = "10.0.2.2";
  double linearVelocitySetting = 0.2;
  double angularVelocitySetting = 0.1;
  final TcpClient tcp = TcpClient();
  bool connected = false;

  bool joyStickHold = false;
  bool turnHold = false;
  double linearVelX = 0.0;
  double linearVelY = 0.0;
  double angularVel = 0.0;
  bool isSending = false;
  Timer? sendTimer;

  @override
  void initState() {
    super.initState();
    tcp.setIP(serverIp);
  }

  void sendData(double vx, double vy, double vth) {
    String frame = jsonEncode({
      "vx": linearVelX,
      "vy": linearVelY,
      "wz": angularVel,
      "ts": DateTime.now().millisecondsSinceEpoch,
    });

    tcp.send(frame + "\r\n");
  }

  void startSending() {
    if (isSending && (joyStickHold || turnHold)) return;

    isSending = true;

    sendTimer = Timer.periodic(const Duration(milliseconds: 200), (_) {
      // TODO send UDP / WebSocket / ROS later
      debugPrint("data: $linearVelX, $linearVelY $angularVel");

      sendData(linearVelX, linearVelY, angularVel);
    });
  }

  void stopSending() {
    if (joyStickHold == false && turnHold == false) {
      sendTimer?.cancel();
      isSending = false;

      // Send zero once (VERY IMPORTANT for robot)
      debugPrint("data: $linearVelX, $linearVelY $angularVel");

      sendData(linearVelX, linearVelY, angularVel);
    }
  }

  void showStatus(String message, Color color) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: color,
        duration: const Duration(seconds: 2),
      ),
    );
  }

  Future<void> openSettings() async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => SettingsPage(
        currentIp: serverIp,
        linearScale: linearVelocitySetting,
        angularScale: angularVelocitySetting)
      ),
    );

    if (result != null) {
      setState(() {
        serverIp = result["ip"];
        linearVelocitySetting = result["linear"];
        angularVelocitySetting = result["angular"];
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            Row(
              children: [
                FloatingActionButton.small(
                  onPressed: openSettings,
                  child: const Icon(Icons.settings),
                ),

                /// ===== TOP CONNECT BUTTON =====
                Padding(
                  padding: const EdgeInsets.all(16),
                  child: ElevatedButton(
                    onPressed: () async {
                      if (connected) {
                        tcp.disconnectTCP();
                        setState(() {
                          connected = false;
                        });
                        showStatus("TCP DIsconnected ${tcp.getIP()}", Colors.red);
                      } else {
                        tcp.setIP(serverIp);
                        bool ok = await tcp.connectTCP();
                        if (ok) {
                          setState(() {
                            connected = true;
                          });
                          showStatus("TCP Connected ${tcp.getIP()}", Colors.green);
                        } else {
                          showStatus("TCP Connected Fail ${tcp.getIP()}", Colors.red);
                        }
                      }
                    },
                    child: Text(connected ? "DISCONNECT TCP" : "CONNECT TCP"),
                  ),
                ),
              ],
            ),
            Expanded(
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  /// LEFT SIDE → JOYSTICK
                  Padding(
                    padding: const EdgeInsets.all(20),
                    child: Joystick(
                      size: 150,
                      linearVelocity: linearVelocitySetting,
                      onChanged: (offset) {
                        setState(() {
                          linearVelX = -offset.dy * linearVelocitySetting;
                          linearVelY = -offset.dx * linearVelocitySetting;
                        });
                      },
                      onHoldStart: () {
                        joyStickHold = true;
                        startSending();
                      },
                      onHoldEnd: () {
                        joyStickHold = false;
                        linearVelX = 0;
                        linearVelY = 0;
                        stopSending();
                      },
                    ),
                  ),

                  /// RIGHT SIDE → EXPANDS (EMPTY SPACE)
                  Expanded(
                    child: Align(
                      alignment: Alignment.centerRight,
                      child: Padding(
                        padding: const EdgeInsetsGeometry.all(40),
                        child: TurnButtons(
                          angularVelocity: angularVelocitySetting,
                          onLeft: () {
                            turnHold = true;
                            angularVel = angularVelocitySetting;
                            startSending();
                          },
                          onLeftEnd: () {
                            turnHold = false;
                            angularVel = 0.0;
                            stopSending();
                          },
                          onRight: () {
                            turnHold = true;
                            angularVel = -angularVelocitySetting;
                            startSending();
                          },
                          onRightEnd: () {
                            turnHold = false;
                            angularVel = 0.0;
                            stopSending();
                          },
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
