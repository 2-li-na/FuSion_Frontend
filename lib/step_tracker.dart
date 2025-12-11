import 'dart:async';
import 'package:flutter/material.dart';
import 'package:health/health.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class StepTracker extends ChangeNotifier {
  // Configuration
  late String backendBaseUrl;
  late String username;

  // State
  int _dailySteps = 0;
  int _points = 0;
  int _weeklyAverageSteps = 0;
  bool _isAuthorized = false;
  bool _isInitialized = false;
  DateTime _lastFetchTime = DateTime.now();
  Timer? _syncTimer;

  // Health instance
  final Health _health = Health();

  // Getters
  int get dailySteps => _dailySteps;
  int get points => _points;
  int get weeklyAverageSteps => _weeklyAverageSteps;
  bool get isAuthorized => _isAuthorized;
  bool get isInitialized => _isInitialized;

  StepTracker();

  /// Configure with backend URL and username
  void configure({
    required String backendBaseUrl,
    required String username,
  }) {
    this.backendBaseUrl = backendBaseUrl;
    this.username = username;
  }

  /// Initialize step tracking with proper permissions
  Future<void> initialize() async {
    if (_isInitialized) return;
    
    print("Initializing Step Tracker for: $username");
    
    try {
      // 1. Request permissions
      await _requestPermissions();
      
      // 2. Fetch and sync steps if authorized
      if (_isAuthorized) {
        await _fetchAndSyncSteps();
        _startTimers();
      } else {
        print("Not authorized - using test data");
        _setTestData();
      }
      
      _isInitialized = true;
      notifyListeners();
      
    } catch (e) {
      print("Error initializing step tracker: $e");
      _setTestData();
      _isInitialized = true;
      notifyListeners();
    }
  }

  /// Request necessary permissions
  Future<void> _requestPermissions() async {
    print("Requesting health permissions...");
    
    List<HealthDataType> types = [HealthDataType.STEPS];
    
    try {
      // Check if Health Connect is available
      bool available = _health.isDataTypeAvailable(HealthDataType.STEPS);
      print("Health Connect available: $available");
      
      // Request authorization
      _isAuthorized = await _health.requestAuthorization(types);
      print("Health Authorization granted: $_isAuthorized");
      
      // Check specific permissions
      if (_isAuthorized) {
        bool? hasPermission = await _health.hasPermissions(types);
        print("Has step permissions: $hasPermission");
      }
      
    } catch (e) {
      print("Health permission error: $e");
      _isAuthorized = false;
    }
  }

  /// Fetch today's steps from health API
  Future<int> _fetchTodaysSteps() async {
    if (!_isAuthorized) {
      print("Not authorized to fetch steps");
      return 0;
    }

    try {
      final now = DateTime.now();
      final startOfDay = DateTime(now.year, now.month, now.day);
      
      print("Fetching steps from $startOfDay to $now");
      print("Time range: ${startOfDay.toIso8601String()} to ${now.toIso8601String()}");
      
      // getHealthDataFromTypes method
      print("Method 1: getHealthDataFromTypes");
      List<HealthDataPoint> healthData = await _health.getHealthDataFromTypes(
        types: [HealthDataType.STEPS],
        startTime: startOfDay,
        endTime: now,
      );

      print("Retrieved ${healthData.length} health data points");
      
      int totalSteps = 0;
      for (var point in healthData) {
        print("Data point: ${point.toString()}");
        if (point.value is NumericHealthValue) {
          int stepValue = (point.value as NumericHealthValue).numericValue.toInt();
          totalSteps += stepValue;
          print("Step value: $stepValue, running total: $totalSteps");
        }
      }

      // Trying getTotalStepsInInterval if available
      try {
        print("Method 2: getTotalStepsInInterval");
        int? intervalSteps = await _health.getTotalStepsInInterval(startOfDay, now);
        print("Interval steps: $intervalSteps");
        if (intervalSteps != null && intervalSteps > totalSteps) {
          totalSteps = intervalSteps;
        }
      } catch (e) {
        print("getTotalStepsInInterval not available: $e");
      }

      // Check for any health data at all
      try {
        print("Method 3: Check all available data types");
        List<HealthDataType> allTypes = [
          HealthDataType.STEPS,
          HealthDataType.DISTANCE_WALKING_RUNNING,
          HealthDataType.ACTIVE_ENERGY_BURNED,
        ];
        
        List<HealthDataPoint> allData = await _health.getHealthDataFromTypes(
          types: allTypes,
          startTime: startOfDay,
          endTime: now,
        );
        print("Total health data points (all types): ${allData.length}");
      } catch (e) {
        print("Could not fetch other health data: $e");
      }

      print("Final step count: $totalSteps");
      _dailySteps = totalSteps;
      _lastFetchTime = now;
      
      return totalSteps;
      
    } catch (e) {
      print("Error fetching steps: $e");
      return 0;
    }
  }

  /// Send step data to backend
  Future<bool> _sendStepsToBackend(int steps) async {
    if (steps <= 0) return false;
    
    try {
      final url = Uri.parse('$backendBaseUrl/steps');
      final body = {
        "username": username,
        "steps": steps,
        "date": DateTime.now().toIso8601String(),
        "source": "HEALTH_CONNECT"
      };

      print("Sending $steps steps to backend...");

      final response = await http.post(
        url,
        headers: {"Content-Type": "application/json"},
        body: jsonEncode(body),
      ).timeout(const Duration(seconds: 30));

      if (response.statusCode == 200 || response.statusCode == 201) {
        print("Steps synced successfully");
        return true;
      } else {
        print("Backend sync failed: ${response.statusCode}");
        return false;
      }
      
    } catch (e) {
      print("Error sending steps to backend: $e");
      return false;
    }
  }

  ///Fetch steps for a single day
  Future<int> _fetchStepsForSingleDay(DateTime date) async {
    if (!_isAuthorized) {
      return 0;
    }

    try {
      // Create start and end of day in LOCAL time (device timezone)
      final startOfDay = DateTime(date.year, date.month, date.day, 0, 0, 0);
      final endOfDay = DateTime(date.year, date.month, date.day, 23, 59, 59);
      
      print(" Fetching steps for ${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}");
      print(" Range: ${startOfDay.toString()} to ${endOfDay.toString()}");
      
      List<HealthDataPoint> healthData = await _health.getHealthDataFromTypes(
        types: [HealthDataType.STEPS],
        startTime: startOfDay,
        endTime: endOfDay,
      );

      int totalSteps = 0;
      for (var point in healthData) {
        if (point.value is NumericHealthValue) {
          int stepValue = (point.value as NumericHealthValue).numericValue.toInt();
          totalSteps += stepValue;
        }
      }

      print("  Found $totalSteps steps");
      return totalSteps;
      
    } catch (e) {
      print("   Error fetching steps: $e");
      return 0;
    }
  }

  /// Send steps for a specific date to backend
  Future<bool> _sendStepsForDate(int steps, DateTime localDate) async {
    if (steps < 0) return false; // Allow 0 steps to be synced
    
    try {
      // Create a UTC date at midnight for this local date to ensures the backend stores it as the correct date
      final utcDate = DateTime.utc(localDate.year, localDate.month, localDate.day, 0, 0, 0);
      
      final url = Uri.parse('$backendBaseUrl/steps');
      final body = {
        "username": username,
        "steps": steps,
        "date": utcDate.toIso8601String(), // Send as UTC ISO string
        "source": "HEALTH_CONNECT"
      };

      print("📤 Sending $steps steps for ${localDate.year}-${localDate.month.toString().padLeft(2, '0')}-${localDate.day.toString().padLeft(2, '0')}");

      final response = await http.post(
        url,
        headers: {"Content-Type": "application/json"},
        body: jsonEncode(body),
      ).timeout(const Duration(seconds: 30));

      if (response.statusCode == 200 || response.statusCode == 201) {
        print("    Successfully synced");
        return true;
      } else {
        print("    Backend sync failed: ${response.statusCode}");
        return false;
      }
      
    } catch (e) {
      print("    Error sending steps: $e");
      return false;
    }
  }

  /// Sync historical data (last 30 days) with backend
  Future<void> syncHistoricalData() async {
    if (!_isAuthorized) {
      print("Not authorized - cannot sync historical data");
      return;
    }

    print("\n Starting historical data sync (last 30 days)...");
    
    try {
      final now = DateTime.now();
      int successCount = 0;
      int failCount = 0;

      // Sync last 30 days, one day at a time
      for (int daysAgo = 29; daysAgo >= 0; daysAgo--) {
        final date = DateTime(now.year, now.month, now.day - daysAgo);
        
        // Fetch steps for this specific day
        int steps = await _fetchStepsForSingleDay(date);
        
        // Send to backend (even if 0 steps, to ensure accurate data)
        bool success = await _sendStepsForDate(steps, date);
        
        if (success) {
          successCount++;
        } else {
          failCount++;
        }
        
        // delay between requests to avoid rate limiting
        await Future.delayed(const Duration(milliseconds: 100));
      }

      print("Historical sync complete!");
      print("   Success: $successCount days");
      print("   Failed: $failCount days");
      
      // After syncing historical data, update weekly average and points
      await _calculateWeeklyPoints();
      await _fetchPointsFromBackend();
      await _fetchWeeklyAverage();
      
      notifyListeners();
      
    } catch (e) {
      print("Historical sync failed: $e");
    }
  }

  /// Main sync function - fetch and sync today + historical data
  Future<void> _fetchAndSyncSteps() async {
    print("Starting step sync...");
    
    try {
      // Fetch today's steps
      int todaySteps = await _fetchTodaysSteps();
      
      // Send today's steps to backend
      if (todaySteps > 0) {
        await _sendStepsToBackend(todaySteps);
      }
      // Sync historical data
      syncHistoricalData();
      
      // Fetch updated points and weekly average
      await _fetchPointsFromBackend();
      await _fetchWeeklyAverage();
      
      print("Sync complete: $todaySteps steps today, $_points points");
      notifyListeners();
      
    } catch (e) {
      print("Sync failed: $e");
    }
  }

  /// Fetch user's points from backend
  Future<void> _fetchPointsFromBackend() async {
    try {
      final url = Uri.parse('$backendBaseUrl/points/total/$username');
      
      final response = await http.get(url).timeout(const Duration(seconds: 30));

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        _points = data['totalPoints'] ?? 0;
        print("Retrieved $_points points from backend");
      } else {
        print("Failed to fetch points: ${response.statusCode}");
      }
      
    } catch (e) {
      print("Error fetching points: $e");
    }
  }


  /// Calculate weekly points based on steps
  Future<void> _calculateWeeklyPoints() async {
    try {
      final url = Uri.parse('$backendBaseUrl/points/calculate');
      final body = {
        "username": username,
        // Let backend calculate current week
      };

      print("Calculating weekly points...");

      final response = await http.post(
        url,
        headers: {"Content-Type": "application/json"},
        body: jsonEncode(body),
      ).timeout(const Duration(seconds: 30));

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        print("Weekly points calculated: ${data['pointsEarned']} points for ${data['averageSteps']} avg steps");
      } else {
        print("Points calculation failed: ${response.statusCode}");
      }
      
    } catch (e) {
      print("Error calculating points: $e");
    }
  }


  //Fetch weekly average steps from backend
  Future<void> _fetchWeeklyAverage() async {
    try {
      final url = Uri.parse('$backendBaseUrl/steps/weekly/$username');
      final response = await http.get(url).timeout(const Duration(seconds: 30));

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        _weeklyAverageSteps = data['averageSteps'] ?? 0;
        print("Weekly average: $_weeklyAverageSteps steps");
      } 
    } catch (e) {
      print("Error fetching weekly average steps: $e");
    }
  }

  

  /// Start background timers for automatic syncing
  void _startTimers() {
    print("Starting automatic sync timers");
    
    // Sync every 30 minutes
    _syncTimer?.cancel();
    _syncTimer = Timer.periodic(const Duration(minutes: 30), (timer) {
      print("30-min sync trigger");
      _fetchAndSyncSteps();
    });
  }




  /// Manual refresh method
  Future<void> refreshSteps() async {
    print("Manual refresh triggered");
    await _fetchAndSyncSteps();
  }

  /// Set test data when health APIs are unavailable
  void _setTestData() {
    _dailySteps = 2500 + (DateTime.now().hour * 200); // Simulated progression
    _points = 15;
    print("Using test data: $_dailySteps steps, $_points points");
    notifyListeners();
  }

  /// Deduct points for rewards
  void deductPoints(int pointsToDeduct) {
    if (_points >= pointsToDeduct) {
      _points -= pointsToDeduct;
      print("Deducted $pointsToDeduct points (remaining: $_points)");
      notifyListeners();
    } else {
      print("Insufficient points: need $pointsToDeduct, have $_points");
    }
  }

  /// Stop all timers and cleanup
  void stopTracking() {
    print("Stopping step tracking");
    _syncTimer?.cancel();
  }

  // Get comprehensive debug information
  String getDebugInfo() {
    return """
STEP TRACKER DEBUG INFO
═══════════════════════════════════════════════

Platform: Health Connect/HealthKit
Authorized: $_isAuthorized
Initialized: $_isInitialized
Daily Steps: $_dailySteps
Points: $_points
Last Sync: ${_lastFetchTime.toString()}
Sync Timer: ${_syncTimer?.isActive ?? false}
Backend: $backendBaseUrl
Username: $username

═══════════════════════════════════════════════
    """;
  }

  void syncStepsWithBackend() {
    refreshSteps();
  }
}