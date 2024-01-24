import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class ViewComplaint extends StatefulWidget {
  const ViewComplaint({super.key});

  @override
  _ViewComplaintState createState() => _ViewComplaintState();
}

class _ViewComplaintState extends State<ViewComplaint> {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  late User _user;

  @override
  void initState() {
    super.initState();
    _user = _auth.currentUser!;
  }

  DateTime? _getTimestamp(Map<String, dynamic> messageData) {
    final timestamp = messageData['timestamp'];
    if (timestamp is Timestamp) {
      return timestamp.toDate();
    }
    return null;
  }

  Future<String?> _getUserName(String userId) async {
    try {
      DocumentSnapshot<Map<String, dynamic>> userSnapshot =
          await FirebaseFirestore.instance
              .collection('users')
              .doc(userId)
              .get();

      if (userSnapshot.exists) {
        return userSnapshot.data()!['username'];
      } else {
        return null;
      }
    } catch (e) {
      print("Error fetching user data: $e");
      return null;
    }
  }

  Widget _buildMessageCard(Map<String, dynamic> messageData) {
    DateTime? timestamp = _getTimestamp(messageData);

    if (timestamp != null) {
      String formattedTime = DateFormat('HH:mm').format(timestamp);

      return FutureBuilder<String?>(
        future: _getUserName(messageData['userId']),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const CircularProgressIndicator(
              color: Colors.blue,
            );
          } else if (snapshot.hasError) {
            return Text('Error: ${snapshot.error}');
          } else {
            String userName = snapshot.data ?? 'Unknown User';
            return Card(
              margin: const EdgeInsets.symmetric(vertical: 8),
              child: Padding(
                padding: const EdgeInsets.all(8),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'رقم السيارة: ${messageData['carNumber']}',
                      style: const TextStyle(fontSize: 20),
                    ),
                    Text(
                      'محتوى الشكوى: ${messageData['complaint']}',
                      style: const TextStyle(fontSize: 20),
                    ),
                    Text(
                      'الوقت: $formattedTime',
                      style: const TextStyle(fontSize: 20),
                    ),
                    Text(
                      'المستخدم: ${messageData['userName']}',
                      style: const TextStyle(fontSize: 20),
                    ),
                  ],
                ),
              ),
            );
          }
        },
      );
    } else {
      return const SizedBox();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.blue,
        title: const Text('صفحة الشكاوي'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            const SizedBox(height: 32),
            const Text(
              'الشكاوي المرسلة',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 24),
            Expanded(
              child: StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
                stream: FirebaseFirestore.instance
                    .collection('messages')
                    .orderBy('timestamp', descending: true)
                    .snapshots(),
                builder: (BuildContext context,
                    AsyncSnapshot<QuerySnapshot<Map<String, dynamic>>>
                        snapshot) {
                  if (snapshot.hasError) {
                    print("Error: ${snapshot.error}");
                    return Text('Error: ${snapshot.error}');
                  }

                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return Center(
                      child: Container(
                        height: 50,
                        width: 60,
                        child: FittedBox(
                          child: CircularProgressIndicator(
                            color: Colors.blue,
                          ),
                        ),
                      ),
                    );
                  }

                  final List<QueryDocumentSnapshot<Map<String, dynamic>>>
                      documents = snapshot.data?.docs ?? [];

                  return ListView.builder(
                    physics: BouncingScrollPhysics(),
                    itemCount: documents.length,
                    itemBuilder: (BuildContext context, int index) {
                      final Map<String, dynamic> messageData =
                          documents[index].data();
                      return _buildMessageCard(messageData);
                    },
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
