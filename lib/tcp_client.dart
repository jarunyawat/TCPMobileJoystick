import 'package:flutter/material.dart';
import 'dart:io';

class TcpClient {

  Socket? socket;
  String serverIp = "10.0.2.2";

  /// ================= TCP CONNECT =================
  Future<bool> connectTCP() async {
    try {
      socket = await Socket.connect(serverIp, 5000).timeout(const Duration(seconds: 3)); // <-- change
      debugPrint("TCP Connected");
      return true;
    } catch (e) {
      debugPrint("TCP connect error: $e");
      return false;
    }
  }

  void disconnectTCP() {
    socket?.destroy();
    socket = null;
  }

  void setIP(String ip){
    serverIp = ip;
  }

  String getIP(){
    return serverIp;
  }

  void send(String data) {
    socket?.write(data);
  }

  void close() {
    socket?.close();
  }
}
