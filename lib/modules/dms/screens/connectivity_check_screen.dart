import 'package:flutter/material.dart';
import 'package:cargoind/modules/dms/services/connectivity_service.dart';

class ConnectivityCheckScreen extends StatefulWidget {
  @override
  _ConnectivityCheckScreenState createState() => _ConnectivityCheckScreenState();
}

class _ConnectivityCheckScreenState extends State<ConnectivityCheckScreen> {
  bool _isChecking = false;
  String _results = '';

  @override
  void initState() {
    super.initState();
    _runConnectivityCheck();
  }

  Future<void> _runConnectivityCheck() async {
    setState(() {
      _isChecking = true;
      _results = 'Checking connectivity...';
    });

    try {
      final results = await ConnectivityService.checkConnectivity();
      final formattedResults = ConnectivityService.formatResults(results);
      
      setState(() {
        _results = formattedResults;
        _isChecking = false;
      });
    } catch (e) {
      setState(() {
        _results = 'Error during connectivity check: $e';
        _isChecking = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Connectivity Check'),
        backgroundColor: Theme.of(context).colorScheme.primary,
        foregroundColor: Colors.white,
      ),
      body: Padding(
        padding: EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                ElevatedButton(
                  onPressed: _isChecking ? null : _runConnectivityCheck,
                  child: Text('Run Check'),
                ),
                SizedBox(width: 16),
                if (_isChecking)
                  CircularProgressIndicator(),
              ],
            ),
            SizedBox(height: 20),
            Expanded(
              child: Container(
                width: double.infinity,
                padding: EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.grey[100],
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: Colors.grey[300]!),
                ),
                child: SingleChildScrollView(
                  child: Text(
                    _results,
                    style: TextStyle(
                      fontFamily: 'monospace',
                      fontSize: 12,
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}