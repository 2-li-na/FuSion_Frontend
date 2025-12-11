import 'package:flutter/material.dart';
import 'package:fusion_new/l10n/app_localizations.dart';
import 'package:fusion_new/language_provider.dart';
import 'package:provider/provider.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'step_tracker.dart';
import 'faq.dart';
import 'login.dart';
import 'praemie.dart';
import 'datenschutz.dart';
import 'feedback.dart';
import 'impressum.dart';
import 'userprofile.dart';


class DashboardPage extends StatefulWidget {
  final String username;
  final String email;
  final String backendBaseUrl;

  const DashboardPage({
    super.key,
    required this.username,
    required this.backendBaseUrl, 
    required this.email,
  });

  @override
  DashboardPageState createState() => DashboardPageState();
}

class DashboardPageState extends State<DashboardPage> {
  // File? _profileImage;
  
  // Department statistics variables
  Map<String, int> _departmentStats = {};
  bool _loadingStats = true;
  
  String? _profileImageUrl; // URL of the profile image


  void _launchURL(String url) async {
    final Uri uri = Uri.parse(url);
    if (await canLaunchUrl(uri)) {
      await launchUrl(
        uri,
        mode: LaunchMode.externalApplication,
      );
    } else {
      throw 'Could not launch $url';
    }
  }




  Future<void> _loadProfilePicture() async {
    final response = await http.get(
      Uri.parse('${widget.backendBaseUrl}/users/profile-picture/${widget.username}'),
    );
    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      if (data['profilePicture'].isNotEmpty) {
        String baseUrl = widget.backendBaseUrl.replaceAll('/api', '');
        setState(() {
          _profileImageUrl = '$baseUrl${data['profilePicture']}';
        });
      }
    }
  }

  // Load real department statistics from backend
  Future<void> _loadDepartmentStats() async {
    try {
      final url = Uri.parse('${widget.backendBaseUrl}/users/department-stats');
      final response = await http.get(url).timeout(const Duration(seconds: 10));
      
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body) as Map<String, dynamic>;
        setState(() {
          _departmentStats = data.map((key, value) => MapEntry(key, value as int));
          _loadingStats = false;
        });
        print("Loaded department stats: $_departmentStats");
      } else {
        print('Failed to load department stats: ${response.statusCode}');
        _setDefaultStats();
      }
    } catch (e) {
      print('Error loading department stats: $e');
      _setDefaultStats();
    }
  }

  void _setDefaultStats() {
    setState(() {
      _departmentStats = {
        'GW': 0, 'LT': 0, 'V': 0, 'SW': 0, 
        'W': 0, 'SK': 0, 'OE': 0, 'AI': 0
      };
      _loadingStats = false;
    });
  }

  // Generate bar chart data from real department counts
  List<BarChartGroupData> _buildRealBarGroups() {
    const departments = ['GW', 'LT', 'V', 'SW', 'W', 'SK', 'OE', 'AI'];
    const colors = [
      Colors.cyan, Colors.teal, Colors.green, Colors.yellow, 
      Colors.blue, Colors.orange, Colors.pink, Colors.indigo
    ];
    
    return departments.asMap().entries.map((entry) {
      int index = entry.key;
      String dept = entry.value;
      int count = _departmentStats[dept] ?? 0;
      
      return BarChartGroupData(
        x: index, 
        barRods: [BarChartRodData(
          toY: count.toDouble(), 
          color: colors[index],
          width: 20,
        )]
      );
    }).toList();
  }

  @override
  void initState() {
    super.initState();

    // Load profile picture if exists
    _loadProfilePicture();

    // Load real department statistics
    _loadDepartmentStats();

    final stepTracker = Provider.of<StepTracker>(context, listen: false);
    stepTracker.configure(
      backendBaseUrl: widget.backendBaseUrl,
      username: widget.username,
    );
    stepTracker.initialize();
  }

  @override
  void dispose() {
    final stepTracker = Provider.of<StepTracker>(context, listen: false);
    stepTracker.stopTracking();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final stepTracker = Provider.of<StepTracker>(context);
    final languageProvider = Provider.of<LanguageProvider>(context);
    final localizations = AppLocalizations.of(context)!;
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;

    return Scaffold(
      backgroundColor: const Color.fromARGB(255, 151, 207, 153),
      appBar: PreferredSize(
        preferredSize: Size.fromHeight(screenHeight * 0.15),
        child: Container(
          margin: EdgeInsets.symmetric(horizontal: screenWidth * 0.03),
          padding: EdgeInsets.symmetric(horizontal: screenWidth * 0.03),
          decoration: BoxDecoration(
            color: Colors.white,
            border: Border.all(color: Colors.green, width: 2.0),
            borderRadius: BorderRadius.circular(12.0),
          ),
          child: SafeArea(
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Builder(
                  builder: (context) => IconButton(
                    icon: Icon(Icons.menu, size: screenWidth * 0.08, color: Colors.black),
                    onPressed: () {
                      Scaffold.of(context).openDrawer();
                    },
                  ),
                ),
                Flexible(
                  child: Text(
                    localizations.overview,
                    style: TextStyle(
                      fontSize: screenWidth * 0.06,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                Image.asset('assets/images/logo.png', height: screenHeight * 0.08),
              ],
            ),
          ),
        ),
      ),
      drawer: Drawer(
        child: ListView(
          padding: EdgeInsets.zero,
          children: [
            UserAccountsDrawerHeader(
              accountName: Text(widget.username),
              accountEmail: Text(widget.email.isNotEmpty ? widget.email : localizations.noEmailAvailable),
              currentAccountPicture: GestureDetector(
                onTap: () {
                  Navigator.push(
                    context, 
                    MaterialPageRoute(
                      builder: (context) => UserProfilePage(
                        username: widget.username,
                        email: widget.email,
                        backendBaseUrl: widget.backendBaseUrl,
                        profileImageUrl: _profileImageUrl,
                      ),
                  ));
                },
                child: CircleAvatar(
                  backgroundColor: Colors.green[700],
                  backgroundImage: _profileImageUrl != null && _profileImageUrl!.isNotEmpty
                      ? NetworkImage(_profileImageUrl!)
                      : null,
                  child: _profileImageUrl == null || _profileImageUrl!.isEmpty
                      ? Text(
                          widget.username.isNotEmpty ? widget.username[0].toUpperCase() : 'U',
                          style: const TextStyle(fontSize: 40, color: Colors.white),
                        )
                      : null,
                ),
              ),
            ),
            ListTile(
              leading: const Icon(Icons.home),
              title: Text(localizations.overview),
              onTap: () {
                Navigator.pop(context);
              },
            ),
            ListTile(
              leading: const Icon(Icons.emoji_events),
              title: Text(localizations.rewards),
              onTap: () {
                _launchURL(
                    'https://www.hs-fulda.de/unsere-hochschule/a-z-alle-institutionen/hochschulsport/fusion/praemienkatalog');
              },
            ),
            ListTile(
              leading: const Icon(Icons.help),
              title: Text(localizations.faq),
              onTap: () {
                Navigator.push(context, MaterialPageRoute(builder: (context) => const FAQPage()));
              },
            ),
            ListTile(
              leading: const Icon(Icons.info),
              title: Text(localizations.imprint),
              onTap: () {
                Navigator.push(context, MaterialPageRoute(builder: (context) => const ImpressumPage()));
              },
            ),
            ListTile(
              leading: const Icon(Icons.lock),
              title: Text(localizations.privacy),
              onTap: () {
                Navigator.push(context, MaterialPageRoute(builder: (context) => const DatenschutzPage()));
              },
            ),
            ListTile(
              leading: const Icon(Icons.feedback),
              title: Text(localizations.feedback),
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => FeedbackPage(username: widget.username, backendBaseUrl: widget.backendBaseUrl)),
                );
              },
            ),
            ListTile(
              leading: const Icon(Icons.card_giftcard),
              title: Text(localizations.redeemReward),
              onTap: () {
                Navigator.push(context, MaterialPageRoute(builder: (context) => PraemiePage(
                  backendBaseUrl: widget.backendBaseUrl,
                  username: widget.username,
                )));
              },
            ),
            const Divider(),
            ListTile(
              leading: const Icon(Icons.language),
              title: Text(localizations.language),
              subtitle: Row(
                children: [
                  TextButton(
                    onPressed: () => languageProvider.changeToEnglish(),
                    style: TextButton.styleFrom(
                      backgroundColor: languageProvider.currentLocale.languageCode == 'en' 
                          ? Colors.green.withOpacity(0.2) 
                          : null,
                    ),
                    child: Text(localizations.english),
                  ),
                  TextButton(
                    onPressed: () => languageProvider.changeToGerman(),
                    style: TextButton.styleFrom(
                      backgroundColor: languageProvider.currentLocale.languageCode == 'de' 
                          ? Colors.green.withOpacity(0.2) 
                          : null,
                    ),
                    child: Text(localizations.german),
                  ),
                ],
              ),
            ),
            const Divider(),
            ListTile(
              leading: const Icon(Icons.logout, color: Colors.red),
              title: Text(localizations.logout, style: const TextStyle(color: Colors.green)),
              onTap: () {
                Navigator.pushAndRemoveUntil(
                  context,
                  MaterialPageRoute(builder: (context) => LoginPage(backendBaseUrl: widget.backendBaseUrl)),
                  (route) => false,
                );
              },
            ),
          ],
        ),
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.symmetric(horizontal: screenWidth * 0.04),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            // Activity Chart Section
            Container(
              padding: EdgeInsets.all(screenWidth * 0.04),
              margin: EdgeInsets.only(top: screenHeight * 0.02, bottom: screenHeight * 0.03),
              decoration: BoxDecoration(
                color: const Color.fromARGB(255, 236, 245, 235),
                border: Border.all(color: Colors.green, width: 2.0),
                borderRadius: BorderRadius.circular(12.0),
              ),
              child: Column(
                children: [
                  Text(
                    localizations.hello(widget.username),
                    style: TextStyle(fontSize: screenWidth * 0.06, fontWeight: FontWeight.bold),
                  ),
                  SizedBox(height: screenHeight * 0.01),
                  const Divider(color: Colors.green, thickness: 1),
                  SizedBox(height: screenHeight * 0.01),
                  Text(localizations.yourActivity, style: TextStyle(fontSize: screenWidth * 0.05)),
                  SizedBox(height: screenHeight * 0.02),
                  // Health Connect status and refresh
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: stepTracker.isAuthorized ? Colors.green[100] : Colors.orange[100],
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(
                        color: stepTracker.isAuthorized ? Colors.green[300]! : Colors.orange[300]!
                      ),
                    ),
                    child: Row(
                      children: [
                        Icon(
                          stepTracker.isAuthorized ? Icons.fitness_center : Icons.warning,
                          color: stepTracker.isAuthorized ? Colors.green[700] : Colors.orange[700],
                          size: 16,
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            
                            stepTracker.isAuthorized 
                              ? localizations.healthConnectConnected
                              : localizations.healthConnectNotConnected,
                            style: TextStyle(
                              fontSize: screenWidth * 0.035,
                              color: stepTracker.isAuthorized ? Colors.green[700] : Colors.orange[700],
                            ),
                          ),
                        ),
                        IconButton(
                          onPressed: () => stepTracker.syncStepsWithBackend(),
                          icon: Icon(
                            Icons.refresh,
                            color: stepTracker.isAuthorized ? Colors.green[700] : Colors.orange[700],
                            size: 20,
                          ),
                          tooltip: localizations.refreshSteps,
                        ),
                      ],
                    ),
                  ),
                  SizedBox(height: screenHeight * 0.02),
                  // Updated Donut Chart with proper sizing and layout
                  Row(
                    children: [
                      // Chart container with fixed size
                      SizedBox(
                        width: screenWidth * 0.40,
                        height: screenWidth * 0.40,
                        child: Stack(
                          alignment: Alignment.center,
                          children: [
                            // Outer circle for daily steps
                            PieChart(
                              PieChartData(
                                sections: [
                                  PieChartSectionData(
                                    value: stepTracker.dailySteps > 0 ? stepTracker.dailySteps.toDouble() : 1,
                                    color: Colors.green[400]!,
                                    title: '',
                                    radius: 28,
                                  ),
                                  PieChartSectionData(
                                    value: stepTracker.dailySteps > 0 
                                        ? (10000 - stepTracker.dailySteps).toDouble().clamp(0, 10000) 
                                        : 9999,
                                    color: Colors.grey[300]!,
                                    title: '',
                                    radius: 28,
                                  ),
                                ],
                                centerSpaceRadius: 40,
                                sectionsSpace: 1,
                              ),
                            ),
                            // Inner circle for weekly average
                            SizedBox(
                              width: 80,
                              height: 80,
                              child: PieChart(
                                PieChartData(
                                  sections: [
                                    PieChartSectionData(
                                      value: stepTracker.weeklyAverageSteps > 0 
                                          ? stepTracker.weeklyAverageSteps.toDouble() 
                                          : 1,
                                      color: Colors.blue[400]!,
                                      title: '',
                                      radius: 15,
                                    ),
                                    PieChartSectionData(
                                      value: stepTracker.weeklyAverageSteps > 0 
                                          ? (10000 - stepTracker.weeklyAverageSteps).toDouble().clamp(0, 10000) 
                                          : 9999,
                                      color: Colors.grey[200]!,
                                      title: '',
                                      radius: 15,
                                    ),
                                  ],
                                  centerSpaceRadius: 15,
                                  sectionsSpace: 1,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      SizedBox(width: screenWidth * 0.05),
                      // Legend with proper spacing
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // Daily steps legend
                            Row(
                              children: [
                                Container(
                                  width: screenWidth * 0.04,
                                  height: screenWidth * 0.04,
                                  decoration: BoxDecoration(
                                    color: Colors.green[400],
                                    shape: BoxShape.circle,
                                  ),
                                ),
                                SizedBox(width: screenWidth * 0.02),
                                Flexible(
                                  child: Text(
                                    '${stepTracker.dailySteps} ${localizations.todaysSteps}',
                                    style: TextStyle(fontSize: screenWidth * 0.035),
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ),
                              ],
                            ),
                            SizedBox(height: screenHeight * 0.01),
                            // Weekly average legend
                            Row(
                              children: [
                                Container(
                                  width: screenWidth * 0.04,
                                  height: screenWidth * 0.04,
                                  decoration: BoxDecoration(
                                    color: Colors.blue[400],
                                    shape: BoxShape.circle,
                                  ),
                                ),
                                SizedBox(width: screenWidth * 0.02),
                                Flexible(
                                  child: Text(
                                    '${stepTracker.weeklyAverageSteps} ${localizations.weeklyAverage}',
                                    style: TextStyle(fontSize: screenWidth * 0.035),
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ),
                              ],
                            ),
                            SizedBox(height: screenHeight * 0.01),
                            // Points legend
                            Row(
                              children: [
                                Container(
                                  width: screenWidth * 0.04,
                                  height: screenWidth * 0.04,
                                  decoration: const BoxDecoration(
                                    color: Colors.red,
                                    shape: BoxShape.circle,
                                  ),
                                ),
                                SizedBox(width: screenWidth * 0.02),
                                Flexible(
                                  child: Text(
                                    '${stepTracker.points} ${localizations.points}',
                                    style: TextStyle(fontSize: screenWidth * 0.035),
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            // Real Department Statistics Bar Chart Section
            Container(
              padding: EdgeInsets.all(screenWidth * 0.04),
              decoration: BoxDecoration(
                color: Colors.green[50],
                border: Border.all(color: Colors.green, width: 1.5),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Column(
                children: [
                  Text(
                    localizations.departmentStrength,
                    style: TextStyle(fontSize: screenWidth * 0.05, fontWeight: FontWeight.bold),
                  ),
                  SizedBox(height: screenHeight * 0.01),
                  Text(
                    localizations.registeredUsersPerDepartment,
                    style: TextStyle(fontSize: screenWidth * 0.035, color: Colors.grey[600]),
                  ),
                  SizedBox(height: screenHeight * 0.02),
                  SizedBox(
                    height: screenHeight * 0.3,
                    child: _loadingStats 
                      ? const Center(child: CircularProgressIndicator(color: Colors.green))
                      : BarChart(
                          BarChartData(
                            alignment: BarChartAlignment.spaceAround,
                            maxY: _departmentStats.values.isEmpty ? 10 : 
                                  (_departmentStats.values.reduce((a, b) => a > b ? a : b).toDouble() + 2),
                            barTouchData: BarTouchData(
                              enabled: true,
                              touchTooltipData: BarTouchTooltipData(
                                tooltipBgColor: Colors.green[100],
                                getTooltipItem: (group, groupIndex, rod, rodIndex) {
                                  const fullNames = [
                                    'Gesundheitswissenschaften',
                                    'Lebensmitteltechnologie', 
                                    'Verwaltung',
                                    'Sozialwesen',
                                    'Wirtschaft',
                                    'Sozial- u. Kulturwissenschaften',
                                    'Oecotrophologie',
                                    'Angewandte Informatik'
                                  ];
                                  return BarTooltipItem(
                                    '${fullNames[groupIndex]}\n${rod.toY.toInt()} Benutzer',
                                    const TextStyle(color: Colors.black, fontSize: 12),
                                  );
                                },
                              ),
                            ),
                            titlesData: FlTitlesData(
                              show: true,
                              bottomTitles: AxisTitles(
                                sideTitles: SideTitles(
                                  showTitles: true,
                                  getTitlesWidget: (value, meta) {
                                    const titles = ['GW', 'LT', 'V', 'SW', 'W', 'SK', 'OE', 'AI'];
                                    return Text(
                                      titles[value.toInt()],
                                      style: const TextStyle(fontSize: 11, fontWeight: FontWeight.bold),
                                    );
                                  },
                                ),
                              ),
                              leftTitles: AxisTitles(
                                sideTitles: SideTitles(
                                  showTitles: true,
                                  reservedSize: 30,
                                  getTitlesWidget: (value, meta) {
                                    return Text(
                                      value.toInt().toString(),
                                      style: const TextStyle(fontSize: 10),
                                    );
                                  },
                                ),
                              ),
                              topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                              rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                            ),
                            borderData: FlBorderData(show: false),
                            barGroups: _buildRealBarGroups(),
                            gridData: FlGridData(
                              show: true,
                              drawVerticalLine: false,
                              horizontalInterval: _departmentStats.values.isEmpty ? 5 : 
                                (_departmentStats.values.reduce((a, b) => a > b ? a : b) / 4).ceilToDouble(),
                            ),
                          ),
                        ),
                  ),
                  if (!_loadingStats) ...[
                    SizedBox(height: screenHeight * 0.01),
                    Text(
                      localizations.totalRegisteredUsers(_departmentStats.values.reduce((a, b) => a + b)),
                      style: TextStyle(fontSize: screenWidth * 0.035, fontWeight: FontWeight.w500),
                    ),
                  ],
                ],
              ),
            ),
          ],
        ),
      ),
      // floatingActionButton: FloatingActionButton(
      //   onPressed: () async {
      //     final stepTracker = Provider.of<StepTracker>(context, listen: false);
          
      //     // Show debug dialog
      //     showDialog(
      //       context: context,
      //       builder: (context) => AlertDialog(
      //         title: Text(localizations.stepTrackerDebug),
      //         content: SingleChildScrollView(
      //           child: Text(stepTracker.getDebugInfo()),
      //         ),
      //         actions: [
      //           TextButton(
      //             onPressed: () async {
      //               stepTracker.syncStepsWithBackend();
      //               if (mounted) Navigator.pop(context);
      //             },
      //             child: Text(localizations.synchronizeSteps),
      //           ),
      //           TextButton(
      //             onPressed: () => Navigator.pop(context),
      //             child: Text(localizations.ok),
      //           ),
      //         ],
      //       ),
      //     );
      //   },
      //   backgroundColor: Colors.green,
      //   tooltip: 'Debug Info',
      //   child: const Icon(Icons.directions_walk),
      // ),
    );
  }
}