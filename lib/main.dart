import 'package:flutter/material.dart';
import 'package:nfc_manager/nfc_manager.dart';

void main() {
  runApp(const MainApp());
}

class MainApp extends StatelessWidget {
  const MainApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'NFC Writer App',
      theme: ThemeData(
        primarySwatch: Colors.blue,
        useMaterial3: true,
      ),
      home: const NFCTestPage(),
    );
  }
}

class NFCTestPage extends StatefulWidget {
  const NFCTestPage({super.key});

  @override
  State<NFCTestPage> createState() => _NFCTestPageState();
}

class _NFCTestPageState extends State<NFCTestPage> {
  String _nfcStatus = 'Đang kiểm tra NFC...';
  String _nfcData = 'Chưa ghi link vào NFC';
  bool _isWriting = false;
  final String _urlToWrite = 'https://www.youtube.com/';

  @override
  void initState() {
    super.initState();
    _checkNFCAvailability();
  }

  Future<void> _checkNFCAvailability() async {
    bool isAvailable = false;
    try {
      final availability = await NfcManager.instance.checkAvailability();
      isAvailable = availability == NfcAvailability.enabled;
    } catch (e) {
      isAvailable = false;
    }

    if (mounted) {
      setState(() {
        _nfcStatus = isAvailable ? 'NFC khả dụng' : 'NFC không khả dụng';
      });
    }
  }

  void _startNFCWriting() {
    setState(() {
      _isWriting = true;
      _nfcData = 'Đang đợi thẻ NFC...\n\nĐưa thẻ NFC lại gần để ghi link:\n$_urlToWrite';
    });

    NfcManager.instance.startSession(
      pollingOptions: {
        NfcPollingOption.iso14443,
        NfcPollingOption.iso15693,
      },
      onDiscovered: (NfcTag tag) async {
        try {
          if (mounted) {
            setState(() {
              _nfcData = 'Thành công!\n\nĐã phát hiện thẻ NFC.\n\nLink: $_urlToWrite\n\n(Ghi vào thẻ đang được phát triển)';
              _isWriting = false;
            });
          }

          await NfcManager.instance.stopSession();
        } catch (e) {
          if (mounted) {
            setState(() {
              _nfcData = 'Lỗi: ${e.toString()}';
              _isWriting = false;
            });
          }
          await NfcManager.instance.stopSession();
        }
      },
    );
  }

  void _stopNFCWriting() {
    NfcManager.instance.stopSession();
    setState(() {
      _isWriting = false;
      _nfcData = 'Đã dừng quét NFC';
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('NFC Writer App'),
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const Icon(
              Icons.nfc,
              size: 80,
              color: Colors.blue,
            ),
            const SizedBox(height: 20),
            Text(
              _nfcStatus,
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 20),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.blue.shade50,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.blue.shade200),
              ),
              child: Column(
                children: [
                  const Text(
                    'Link sẽ được ghi:',
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    _urlToWrite,
                    style: const TextStyle(
                      fontSize: 16,
                      color: Colors.blue,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),
            Card(
              elevation: 4,
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Text(
                  _nfcData,
                  textAlign: TextAlign.center,
                  style: const TextStyle(fontSize: 16),
                ),
              ),
            ),
            const SizedBox(height: 40),
            ElevatedButton.icon(
              onPressed: _isWriting ? null : _startNFCWriting,
              icon: const Icon(Icons.nfc),
              label: const Text('Bắt đầu quét NFC'),
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 16),
              ),
            ),
            const SizedBox(height: 16),
            ElevatedButton.icon(
              onPressed: _isWriting ? _stopNFCWriting : null,
              icon: const Icon(Icons.stop),
              label: const Text('Dừng quét NFC'),
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 16),
                backgroundColor: Colors.red,
                foregroundColor: Colors.white,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
