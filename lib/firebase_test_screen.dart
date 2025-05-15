import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class FirebaseTestScreen extends StatefulWidget {
  const FirebaseTestScreen({Key? key}) : super(key: key);

  @override
  _FirebaseTestScreenState createState() => _FirebaseTestScreenState();
}

class _FirebaseTestScreenState extends State<FirebaseTestScreen> {
  // Status messages
  String _authStatus = 'Not tested';
  String _firestoreStatus = 'Not tested';

  // Test data
  final String _testEmail = 'test@example.com';
  final String _testPassword = 'Test@123';

  // Controllers
  final TextEditingController _dataController = TextEditingController(
    text: 'Test data',
  );

  @override
  void dispose() {
    _dataController.dispose();
    super.dispose();
  }

  // Test Firebase Authentication - Anonymous sign in
  Future<void> _testAuth() async {
    setState(() {
      _authStatus = 'Testing...';
    });

    try {
      // Try anonymous sign in
      await FirebaseAuth.instance.signInAnonymously();
      setState(() {
        _authStatus = 'Authentication successful! (Anonymous)';
      });
    } catch (e) {
      setState(() {
        _authStatus = 'Authentication error: ${e.toString()}';
      });
    }
  }

  // Test Firestore - Write and read data
  Future<void> _testFirestore() async {
    setState(() {
      _firestoreStatus = 'Testing...';
    });

    try {
      // Create a test collection
      final testData = {
        'message': _dataController.text,
        'timestamp': FieldValue.serverTimestamp(),
      };

      // Write data
      await FirebaseFirestore.instance
          .collection('firebase_test')
          .add(testData);

      // Read data
      final querySnapshot =
          await FirebaseFirestore.instance
              .collection('firebase_test')
              .orderBy('timestamp', descending: true)
              .limit(1)
              .get();

      if (querySnapshot.docs.isNotEmpty) {
        final data = querySnapshot.docs.first.data();
        setState(() {
          _firestoreStatus =
              'Firestore test successful! Wrote and read: ${data['message']}';
        });
      } else {
        setState(() {
          _firestoreStatus =
              'Firestore write successful, but could not read data back';
        });
      }
    } catch (e) {
      setState(() {
        _firestoreStatus = 'Firestore error: ${e.toString()}';
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Firebase Test'),
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const Text(
              'Firebase Test Screen',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),

            // Authentication test section
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Authentication Test',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text('Status: $_authStatus'),
                    const SizedBox(height: 16),
                    ElevatedButton(
                      onPressed: _testAuth,
                      child: const Text('Test Anonymous Auth'),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),

            // Firestore test section
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Firestore Test',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text('Status: $_firestoreStatus'),
                    const SizedBox(height: 16),
                    TextField(
                      controller: _dataController,
                      decoration: const InputDecoration(
                        labelText: 'Test data to write',
                        border: OutlineInputBorder(),
                      ),
                    ),
                    const SizedBox(height: 16),
                    ElevatedButton(
                      onPressed: _testFirestore,
                      child: const Text('Test Firestore'),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
