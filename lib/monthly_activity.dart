import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:fusion_new/l10n/app_localizations.dart';

class MonthlyActivityPage extends StatefulWidget {
  final String username;
  final String backendBaseUrl;

  const MonthlyActivityPage({
    Key? key,
    required this.username,
    required this.backendBaseUrl,
  }) : super(key: key);

  @override
  MonthlyActivityPageState createState() => MonthlyActivityPageState();
}

class MonthlyActivityPageState extends State<MonthlyActivityPage> {
  List<Map<String, dynamic>> _monthData = [];
  bool _loading = true;
  String _monthName = '';

  @override
  void initState() {
    super.initState();
    _fetchMonthData();
  }

  Future<void> _fetchMonthData() async {
    try {
      final response = await http.get(
        Uri.parse('${widget.backendBaseUrl}/steps/monthly/${widget.username}'),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        setState(() {
          _monthData = List<Map<String, dynamic>>.from(data['days']);
          _monthName = data['monthName'] ?? '';
          _loading = false;
        });
      } else {
        print('Failed to load month data: ${response.statusCode}');
        setState(() => _loading = false);
      }
    } catch (e) {
      print('Error fetching month data: $e');
      setState(() => _loading = false);
    }
  }

  List<BarChartGroupData> _buildBarGroups() {
    return _monthData.asMap().entries.map((entry) {
      int index = entry.key;
      Map<String, dynamic> day = entry.value;
      int steps = day['steps'] ?? 0;

      return BarChartGroupData(
        x: index,
        barRods: [
          BarChartRodData(
            toY: steps.toDouble(),
            color: Colors.green[700]!,
            width: 8,
            borderRadius: const BorderRadius.vertical(top: Radius.circular(2)),
          ),
        ],
      );
    }).toList();
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
                              localizations.monthlyActivityTitle,
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
                          if (_monthName.isNotEmpty) ...[
                            const SizedBox(height: 4),
                            Text(
                              _monthName,
                              style: TextStyle(
                                fontSize: 14,
                                color: Colors.grey[600],
                              ),
                            ),
                          ],
                          SizedBox(height: screenHeight * 0.02),
                          SizedBox(
                            height: screenHeight * 0.35,
                            child: BarChart(
                              BarChartData(
                                alignment: BarChartAlignment.spaceAround,
                                maxY: _monthData.isEmpty
                                    ? 10000
                                    : (_monthData.map((d) => d['steps'] as int).reduce((a, b) => a > b ? a : b).toDouble() * 1.2).clamp(100, double.infinity),
                                barTouchData: BarTouchData(
                                  enabled: true,
                                  touchTooltipData: BarTouchTooltipData(
                                    tooltipBgColor: Colors.green[100],
                                    getTooltipItem: (group, groupIndex, rod, rodIndex) {
                                      final dayData = _monthData[groupIndex];
                                      final isFuture = dayData['isFuture'] ?? false;
                                      return BarTooltipItem(
                                        isFuture 
                                          ? '${dayData['dayNumber']}.\n${localizations.noData}'
                                          : '${dayData['dayNumber']}. ${dayData['monthName']}\n${rod.toY.toInt()} ${localizations.steps}',
                                        const TextStyle(
                                          color: Colors.black,
                                          fontSize: 11,
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
                                      interval: 5,
                                      getTitlesWidget: (value, meta) {
                                        if (value.toInt() < 0 || value.toInt() >= _monthData.length) {
                                          return const SizedBox.shrink();
                                        }
                                        final dayNumber = _monthData[value.toInt()]['dayNumber'];
                                        if (value.toInt() % 5 == 0 || value.toInt() == _monthData.length - 1) {
                                          return Padding(
                                            padding: const EdgeInsets.only(top: 8.0),
                                            child: Text(
                                              dayNumber.toString(),
                                              style: const TextStyle(fontSize: 10),
                                            ),
                                          );
                                        }
                                        return const SizedBox.shrink();
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
                                          style: const TextStyle(fontSize: 9),
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
                                  horizontalInterval: _monthData.isEmpty
                                      ? 2000
                                      : (_monthData.map((d) => d['steps'] as int).reduce((a, b) => a > b ? a : b) / 5).ceilToDouble().clamp(100, double.infinity),
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
                          if (_monthData.isNotEmpty) ...[
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
                                      _monthData
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
                                        final pastDays = _monthData.where((day) => !(day['isFuture'] ?? false)).toList();
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
                                        final pastSteps = _monthData
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

                    // Daily breakdown list (scrollable)
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
                            localizations.date,
                            style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 12),
                          SizedBox(
                            height: screenHeight * 0.3,
                            child: ListView.builder(
                              itemCount: _monthData.length,
                              itemBuilder: (context, index) {
                                final day = _monthData[index];
                                final isFuture = day['isFuture'] ?? false;
                                return Padding(
                                  padding: const EdgeInsets.symmetric(vertical: 6.0),
                                  child: Row(
                                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                    children: [
                                      Text(
                                        '${day['dayNumber']}. ${day['monthName']} (${day['dayName']})',
                                        style: TextStyle(
                                          fontSize: 13,
                                          color: isFuture ? Colors.grey[400] : Colors.black,
                                        ),
                                      ),
                                      Text(
                                        isFuture ? 'N/A' : '${day['steps']} ${localizations.steps}',
                                        style: TextStyle(
                                          fontSize: 13,
                                          fontWeight: FontWeight.bold,
                                          color: isFuture ? Colors.grey[400] : Colors.green[700],
                                        ),
                                      ),
                                    ],
                                  ),
                                );
                              },
                            ),
                          ),
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