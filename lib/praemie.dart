import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:provider/provider.dart';
import 'step_tracker.dart';

class PraemieItem {
  final String id;
  final String title;
  final int points;
  final String description;
  
  PraemieItem({
    required this.id,
    required this.title,
    required this.points,
    this.description = '',
  });

  factory PraemieItem.fromJson(Map<String, dynamic> json) {
    return PraemieItem(
      id: json['_id'] ?? '',
      title: json['title'] ?? '',
      points: json['points'] ?? 0,
      description: json['description'] ?? '',
    );
  }
}

class PraemiePage extends StatefulWidget {
  final String? backendBaseUrl;
  final String? username;

  const PraemiePage({super.key, this.backendBaseUrl, this.username});

  @override
  State<PraemiePage> createState() => _PraemiePageState();
}

class _PraemiePageState extends State<PraemiePage> {
  String? _redeemedMessage;
  List<PraemieItem> _praemieItems = [];
  bool _isLoading = true;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _fetchRewards();
  }

  Future<void> _fetchRewards() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      String apiUrl = widget.backendBaseUrl ?? 'http://localhost:3000/api';
      
      final response = await http.get(
        Uri.parse('$apiUrl/rewards/active'),
        headers: <String, String>{
          'Content-Type': 'application/json; charset=UTF-8',
        },
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final List<dynamic> rewardsJson = data['rewards'] ?? [];
        
        setState(() {
          _praemieItems = rewardsJson
              .map((json) => PraemieItem.fromJson(json))
              .toList();
          _isLoading = false;
        });

        print('Loaded ${_praemieItems.length} rewards from backend');
      } else {
        setState(() {
          _errorMessage = 'Fehler beim Laden der Prämien';
          _isLoading = false;
        });
      }
    } catch (e) {
      print('Error fetching rewards: $e');
      setState(() {
        _errorMessage = 'Verbindungsfehler';
        _isLoading = false;
      });
    }
  }

  Future<void> _redeemReward(BuildContext context, PraemieItem item, String username, int userPoints) async {
    if (userPoints < item.points) return;

    String apiUrl = widget.backendBaseUrl ?? 'http://localhost:3000/api';
    
    try {
      final response = await http.post(
        Uri.parse('$apiUrl/redeem-reward'),
        headers: <String, String>{
          'Content-Type': 'application/json; charset=UTF-8',
        },
        body: jsonEncode({
          'username': username,
          'itemTitle': item.title,
          'pointsRequired': item.points,
        }),
      );

      if (response.statusCode == 200) {
        setState(() {
          _redeemedMessage = 'Prämie ${item.title} für ${item.points} Punkte eingelöst.';
        });

        // Deduct points locally
        Provider.of<StepTracker>(context, listen: false).deductPoints(item.points);

        // Clear message after 5 seconds
        Future.delayed(const Duration(seconds: 5), () {
          if (mounted) {
            setState(() {
              _redeemedMessage = null;
            });
          }
        });
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Fehler beim Einlösen. Bitte versuchen Sie es erneut.')),
        );
      }
    } catch (e) {
      print('Error redeeming reward: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Verbindungsfehler')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final stepTracker = Provider.of<StepTracker>(context);
    final int userPoints = stepTracker.points;
    final username = widget.username ?? stepTracker.username;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Prämienkatalog'),
        backgroundColor: Colors.green,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _fetchRewards,
            tooltip: 'Prämien aktualisieren',
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _errorMessage != null
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        _errorMessage!,
                        style: const TextStyle(fontSize: 16, color: Colors.red),
                      ),
                      const SizedBox(height: 16),
                      ElevatedButton(
                        onPressed: _fetchRewards,
                        child: const Text('Erneut versuchen'),
                      ),
                    ],
                  ),
                )
              : Column(
                  children: [
                    // Table Header
                    Container(
                      color: Colors.grey[200],
                      padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
                      child: Row(
                        children: [
                          const Expanded(
                            flex: 2,
                            child: Text(
                              'Prämien',
                              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                            ),
                          ),
                          const Expanded(
                            flex: 1,
                            child: Text(
                              'Punkte',
                              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                              textAlign: TextAlign.center,
                            ),
                          ),
                          Expanded(
                            flex: 1,
                            child: Container(),
                          ),
                        ],
                      ),
                    ),
                    const Divider(height: 1, thickness: 1),
                    
                    // Table Rows
                    Expanded(
                      child: _praemieItems.isEmpty
                          ? const Center(
                              child: Text(
                                'Keine Prämien verfügbar',
                                style: TextStyle(fontSize: 16, color: Colors.grey),
                              ),
                            )
                          : ListView.builder(
                              itemCount: _praemieItems.length,
                              itemBuilder: (context, index) {
                                final item = _praemieItems[index];
                                final bool canAfford = userPoints >= item.points;

                                return Column(
                                  children: [
                                    Padding(
                                      padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
                                      child: Row(
                                        children: [
                                          Expanded(
                                            flex: 2,
                                            child: Text(
                                              item.title,
                                              style: const TextStyle(fontSize: 16),
                                            ),
                                          ),
                                          Expanded(
                                            flex: 1,
                                            child: Text(
                                              '${item.points}',
                                              style: const TextStyle(fontSize: 16),
                                              textAlign: TextAlign.center,
                                            ),
                                          ),
                                          Expanded(
                                            flex: 1,
                                            child: ElevatedButton(
                                              onPressed: canAfford
                                                  ? () => _redeemReward(context, item, username, userPoints)
                                                  : null,
                                              style: ElevatedButton.styleFrom(
                                                backgroundColor: canAfford ? Colors.green : Colors.grey,
                                                disabledBackgroundColor: Colors.grey,
                                                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                                                shape: RoundedRectangleBorder(
                                                  borderRadius: BorderRadius.circular(8),
                                                ),
                                              ),
                                              child: const Text(
                                                'Kaufen',
                                                style: TextStyle(color: Colors.white, fontSize: 14),
                                              ),
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                    const Divider(height: 1, thickness: 0.5),
                                  ],
                                );
                              },
                            ),
                    ),
                    
                    // Redemption Message
                    if (_redeemedMessage != null)
                      Container(
                        margin: const EdgeInsets.all(16),
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: Colors.green[700],
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Text(
                          _redeemedMessage!,
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 16,
                            fontWeight: FontWeight.w500,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ),
                  ],
                ),
    );
  }
}