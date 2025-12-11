import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:fusion_new/l10n/app_localizations.dart';

class SevenDayActivityPage extends StatefulWidget {
  final String username;
  final String backendBaseUrl;

  const SevenDayActivityPage({
    Key? key,
    required this.username,
    required this.backendBaseUrl,
  }) : super(key: key);

  @override
  SevenDayActivityPageState createState() => SevenDayActivityPageState();
}

class SevenDayActivityPageState extends State<SevenDayActivityPage> {
  List<Map<String, dynamic>> _weekData = [];
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _fetchWeekData();
  }

  Future<void> _fetchWeekData() async {
    try {
      final response = await http.get(
        Uri.parse('${widget.backendBaseUrl}/steps/last-7-days/${widget.username}'),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        setState(() {
          _weekData = List<Map<String, dynamic>>.from(data['days']);
          _loading = false;
        });
      } else {
        print('Failed to load week data: ${response.statusCode}');
        setState(() => _loading = false);
      }
    } catch (e) {
      print('Error fetching week data: $e');
      setState(() => _loading = false);
    }
  }

  List<BarChartGroupData> _buildBarGroups() {
    return _weekData.asMap().entries.map((entry) {
      int index = entry.key;
      Map<String, dynamic> day = entry.value;
      int steps = day['steps'] ?? 0;

      return BarChartGroupData(
        x: index,
        barRods: [
          BarChartRodData(
            toY: steps.toDouble(),
            color: Colors.green[700]!,
            width: 30,
            borderRadius: const BorderRadius.vertical(top: Radius.circular(4)),
          ),
        ],
      );
    }).toList();
  }

  String _getDayLabel(BuildContext context, String dayName) {
    final localizations = AppLocalizations.of(context)!;
    
    // Map full day names to short day names
    final dayMap = {
      localizations.monday: localizations.mondayShort,
      localizations.tuesday: localizations.tuesdayShort,
      localizations.wednesday: localizations.wednesdayShort,
      localizations.thursday: localizations.thursdayShort,
      localizations.friday: localizations.fridayShort,
      localizations.saturday: localizations.saturdayShort,
      localizations.sunday: localizations.sundayShort,
    };
    
    return dayMap[dayName] ?? dayName.substring(0, 2);
  }

  @override
  Widget build(BuildContext context) {
    final localizations = AppLocalizations.of(context)!;
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;

    return Scaffold(
      backgroundColor: const Color.fromARGB(255, 200, 230, 201),
      body: SafeArea(
        child: _loading
            ? const Center(child: CircularProgressIndicator(color: Colors.green))
            : SingleChildScrollView(
                padding: EdgeInsets.all(screenWidth * 0.04),
                child: Column(
                  children: [
                    // Header with back button
                    Container(
                      padding: EdgeInsets.all(screenWidth * 0.04),
                      decoration: BoxDecoration(
                        color: Colors.green[50],
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: Colors.green, width: 2),
                      ),
                      child: Row(
                        children: [
                          IconButton(
                            icon: const Icon(Icons.arrow_back, color: Colors.green, size: 28),
                            onPressed: () => Navigator.pop(context),
                            padding: EdgeInsets.zero,
                            constraints: const BoxConstraints(),
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              localizations.sevenDayActivityTitle,
                              style: const TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    SizedBox(height: screenHeight * 0.02),

                    // Bar Chart
                    Container(
                      padding: EdgeInsets.all(screenWidth * 0.04),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: Colors.green, width: 2),
                      ),
                      child: Column(
                        children: [
                          Text(
                            localizations.steps,
                            style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          SizedBox(height: screenHeight * 0.02),
                          SizedBox(
                            height: screenHeight * 0.4,
                            child: BarChart(
                              BarChartData(
                                alignment: BarChartAlignment.spaceAround,
                                maxY: _weekData.isEmpty
                                    ? 10000
                                    : (_weekData.map((d) => d['steps'] as int).reduce((a, b) => a > b ? a : b).toDouble() * 1.2).clamp(100, double.infinity),
                                barTouchData: BarTouchData(
                                  enabled: true,
                                  touchTooltipData: BarTouchTooltipData(
                                    tooltipBgColor: Colors.green[100],
                                    getTooltipItem: (group, groupIndex, rod, rodIndex) {
                                      final dayData = _weekData[groupIndex];
                                      final isFuture = dayData['isFuture'] ?? false;
                                      return BarTooltipItem(
                                        isFuture 
                                          ? '${dayData['dayName']}\n${localizations.noData}'
                                          : '${dayData['dayName']}\n${rod.toY.toInt()} ${localizations.steps}',
                                        const TextStyle(
                                          color: Colors.black,
                                          fontSize: 12,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      );
                                    },
                                  ),
                                ),
                                titlesData: FlTitlesData(
                                  show: true,
                                  bottomTitles: AxisTitles(
                                    sideTitles: SideTitles(
                                      showTitles: true,
                                      reservedSize: 30,
                                      getTitlesWidget: (value, meta) {
                                        if (value.toInt() < 0 || value.toInt() >= _weekData.length) {
                                          return const SizedBox.shrink();
                                        }
                                        final dayName = _weekData[value.toInt()]['dayName'] as String;
                                        return Padding(
                                          padding: const EdgeInsets.only(top: 8.0),
                                          child: Text(
                                            _getDayLabel(context, dayName),
                                            style: const TextStyle(fontSize: 11),
                                          ),
                                        );
                                      },
                                    ),
                                  ),
                                  leftTitles: AxisTitles(
                                    sideTitles: SideTitles(
                                      showTitles: true,
                                      reservedSize: 40,
                                      getTitlesWidget: (value, meta) {
                                        return Text(
                                          value.toInt().toString(),
                                          style: const TextStyle(fontSize: 10),
                                        );
                                      },
                                    ),
                                  ),
                                  topTitles: const AxisTitles(
                                    sideTitles: SideTitles(showTitles: false),
                                  ),
                                  rightTitles: const AxisTitles(
                                    sideTitles: SideTitles(showTitles: false),
                                  ),
                                ),
                                      borderData: FlBorderData(
                                        show: true,
                                        border: Border(
                                          left: BorderSide(color: Colors.grey[400]!, width: 1),
                                          bottom: BorderSide(color: Colors.grey[400]!, width: 1),
                                        ),
                                      ),
                                      barGroups: _buildBarGroups(),
                                      gridData: FlGridData(
                                        show: true,
                                        drawVerticalLine: false,
                                        horizontalInterval: _weekData.isEmpty
                                            ? 2000
                                            : (_weekData.map((d) => d['steps'] as int).reduce((a, b) => a > b ? a : b) / 5).ceilToDouble().clamp(100, double.infinity),
                                        getDrawingHorizontalLine: (value) {
                                          return FlLine(
                                            color: Colors.grey[300]!,
                                            strokeWidth: 1,
                                          );
                                        },
                                      ),
                                    ),
                                  ),
                          ),
                          SizedBox(height: screenHeight * 0.02),
                          // Summary stats
                          if (_weekData.isNotEmpty) ...[
                            const Divider(color: Colors.green),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceAround,
                              children: [
                                Column(
                                  children: [
                                    Text(
                                      localizations.total,
                                      style: const TextStyle(
                                        fontSize: 12,
                                        color: Colors.grey,
                                      ),
                                    ),
                                    Text(
                                      _weekData
                                        .where((day) => !(day['isFuture'] ?? false))
                                        .fold<int>(0, (sum, day) => sum + (day['steps'] as int))
                                        .toString(),
                                      style: const TextStyle(
                                        fontSize: 18,
                                        fontWeight: FontWeight.bold,
                                        color: Colors.green,
                                      ),
                                    ),
                                  ],
                                ),
                                Column(
                                  children: [
                                    Text(
                                      localizations.average,
                                      style: const TextStyle(
                                        fontSize: 12,
                                        color: Colors.grey,
                                      ),
                                    ),
                                    Text(
                                      () {
                                        final pastDays = _weekData.where((day) => !(day['isFuture'] ?? false)).toList();
                                        if (pastDays.isEmpty) return '0';
                                        final total = pastDays.fold<int>(0, (sum, day) => sum + (day['steps'] as int));
                                        return (total / pastDays.length).round().toString();
                                      }(),
                                      style: const TextStyle(
                                        fontSize: 18,
                                        fontWeight: FontWeight.bold,
                                        color: Colors.green,
                                      ),
                                    ),
                                  ],
                                ),
                                Column(
                                  children: [
                                    Text(
                                      localizations.highest,
                                      style: const TextStyle(
                                        fontSize: 12,
                                        color: Colors.grey,
                                      ),
                                    ),
                                    Text(
                                      () {
                                        final pastSteps = _weekData
                                          .where((day) => !(day['isFuture'] ?? false))
                                          .map((d) => d['steps'] as int);
                                        return pastSteps.isEmpty ? '0' : pastSteps.reduce((a, b) => a > b ? a : b).toString();
                                      }(),
                                      style: const TextStyle(
                                        fontSize: 18,
                                        fontWeight: FontWeight.bold,
                                        color: Colors.green,
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ],
                        ],
                      ),
                    ),

                    SizedBox(height: screenHeight * 0.02),

                    // Daily breakdown list
                    Container(
                      padding: EdgeInsets.all(screenWidth * 0.04),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: Colors.green, width: 2),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            localizations.dailyOverview,
                            style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 12),
                          ..._weekData.map((day) {
                            final isFuture = day['isFuture'] ?? false;
                            return Padding(
                              padding: const EdgeInsets.symmetric(vertical: 8.0),
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  Text(
                                    day['dayName'],
                                    style: TextStyle(
                                      fontSize: 14,
                                      color: isFuture ? Colors.grey[400] : Colors.black,
                                    ),
                                  ),
                                  Row(
                                    children: [
                                      Text(
                                        isFuture ? 'N/A' : '${day['steps']} ${localizations.steps}',
                                        style: TextStyle(
                                          fontSize: 14,
                                          fontWeight: FontWeight.bold,
                                          color: isFuture ? Colors.grey[400] : Colors.black,
                                        ),
                                      ),
                                      const SizedBox(width: 8),
                                      Text(
                                        day['date'],
                                        style: TextStyle(
                                          fontSize: 12,
                                          color: Colors.grey[600],
                                        ),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            );
                          }).toList(),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
      ),
    );
  }
}