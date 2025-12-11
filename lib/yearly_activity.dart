import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:fusion_new/l10n/app_localizations.dart';

class YearlyActivityPage extends StatefulWidget {
  final String username;
  final String backendBaseUrl;

  const YearlyActivityPage({
    Key? key,
    required this.username,
    required this.backendBaseUrl,
  }) : super(key: key);

  @override
  YearlyActivityPageState createState() => YearlyActivityPageState();
}

class YearlyActivityPageState extends State<YearlyActivityPage> {
  List<Map<String, dynamic>> _monthData = [];
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _fetchMonthData();
  }

  Future<void> _fetchMonthData() async {
    try {
      final response = await http.get(
        Uri.parse('${widget.backendBaseUrl}/steps/yearly/${widget.username}'),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        setState(() {
          _monthData = List<Map<String, dynamic>>.from(data['months']);
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
      Map<String, dynamic> month = entry.value;
      int steps = month['steps'] ?? 0;

      return BarChartGroupData(
        x: index,
        barRods: [
          BarChartRodData(
            toY: steps.toDouble(),
            color: Colors.green[700]!,
            width: 20,
            borderRadius: const BorderRadius.vertical(top: Radius.circular(4)),
          ),
        ],
      );
    }).toList();
  }

  String _getMonthLabel(BuildContext context, String monthName) {
    final localizations = AppLocalizations.of(context)!;
    
    // Map full month names to short month names
    final monthMap = {
      localizations.january: localizations.januaryShort,
      localizations.february: localizations.februaryShort,
      localizations.march: localizations.marchShort,
      localizations.april: localizations.aprilShort,
      localizations.may: localizations.mayShort,
      localizations.june: localizations.juneShort,
      localizations.july: localizations.julyShort,
      localizations.august: localizations.augustShort,
      localizations.september: localizations.septemberShort,
      localizations.october: localizations.octoberShort,
      localizations.november: localizations.novemberShort,
      localizations.december: localizations.decemberShort,
    };
    
    return monthMap[monthName] ?? monthName.substring(0, 3);
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
                              localizations.yearlyActivityTitle,
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
                                      final monthData = _monthData[groupIndex];
                                      final isFuture = monthData['isFuture'] ?? false;
                                      return BarTooltipItem(
                                        isFuture 
                                          ? '${monthData['monthName']}\n${localizations.noData}'
                                          : '${monthData['monthName']}\n${rod.toY.toInt()} ${localizations.steps}',
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
                                        if (value.toInt() < 0 || value.toInt() >= _monthData.length) {
                                          return const SizedBox.shrink();
                                        }
                                        final monthName = _monthData[value.toInt()]['monthName'] as String;
                                        return Padding(
                                          padding: const EdgeInsets.only(top: 8.0),
                                          child: Text(
                                            _getMonthLabel(context, monthName),
                                            style: const TextStyle(fontSize: 10),
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
                                        .where((month) => !(month['isFuture'] ?? false))
                                        .fold<int>(0, (sum, month) => sum + (month['steps'] as int))
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
                                        final pastMonths = _monthData.where((month) => !(month['isFuture'] ?? false)).toList();
                                        if (pastMonths.isEmpty) return '0';
                                        final total = pastMonths.fold<int>(0, (sum, month) => sum + (month['steps'] as int));
                                        return (total / pastMonths.length).round().toString();
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
                                          .where((month) => !(month['isFuture'] ?? false))
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

                    // Monthly breakdown list
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
                            localizations.monthlyOverview,
                            style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 12),
                          ..._monthData.map((month) {
                            final isFuture = month['isFuture'] ?? false;
                            return Padding(
                              padding: const EdgeInsets.symmetric(vertical: 8.0),
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  Text(
                                    month['monthName'],
                                    style: TextStyle(
                                      fontSize: 14,
                                      color: isFuture ? Colors.grey[400] : Colors.black,
                                    ),
                                  ),
                                  Text(
                                    isFuture ? 'N/A' : '${month['steps']} ${localizations.steps}',
                                    style: TextStyle(
                                      fontSize: 14,
                                      fontWeight: FontWeight.bold,
                                      color: isFuture ? Colors.grey[400] : Colors.black,
                                    ),
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