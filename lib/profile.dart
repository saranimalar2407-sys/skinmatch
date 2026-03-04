import 'package:flutter/material.dart';
import 'api_service.dart';

class ProfileScreen extends StatefulWidget {
  final String userId;

  const ProfileScreen({super.key, required this.userId});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  Map<String, dynamic>? skinData;
  bool loading = true;

  @override
  void initState() {
    super.initState();
    loadData();
  }

  Future<void> loadData() async {
    final data = await ApiService.getSkinData(widget.userId);

    setState(() {
      skinData = data;
      loading = false;
    });
  }

  Widget infoTile(String title, String value) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: Colors.black12),
      ),
      child: Row(
        children: [
          Expanded(
            child: Text(
              title,
              style: const TextStyle(
                fontWeight: FontWeight.w700,
                color: Colors.black54,
              ),
            ),
          ),
          Text(
            value,
            style: const TextStyle(fontWeight: FontWeight.w900),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (loading) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    if (skinData == null) {
      return const Scaffold(
        body: Center(child: Text("No skin data found")),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text("Profile"),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            infoTile("Name", skinData!['fullName']),
            infoTile("Age", skinData!['age'].toString()),
            infoTile("Gender", skinData!['gender']),
            infoTile("Skin Type", skinData!['skinType']),
            infoTile("Undertone", skinData!['undertone']),
            infoTile("Shade Level", skinData!['shadeLevel']),
          ],
        ),
      ),
    );
  }
}