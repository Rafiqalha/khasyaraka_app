import '../dtos/journey_dto.dart';

/// Simulates a Dio HTTP client for the Journey API
class JourneyApiClient {
  
  Future<Map<String, dynamic>> fetchJourneyJson(String journeyId) async {
    // Simulated network delay
    await Future.delayed(const Duration(milliseconds: 600));
    
    // Hardcoded JSON representation of G1.5 Validation Journey
    return {
      'id': journeyId,
      'title': 'Core Programming Concepts',
      'nodes': [
        {
          'id': 'n1',
          'type': 'PRE_ASSESSMENT',
          'title': 'Pre-Assessment',
          'estimatedSeconds': 120,
          'isRequired': true,
          'telemetryKey': 'g15_pre_assessment'
        },
        {
          'id': 'n2',
          'type': 'JOURNEY_MAP',
          'title': 'Journey Map',
          'estimatedSeconds': 60,
          'isRequired': true,
          'telemetryKey': 'g15_journey_map'
        },
        {
          'id': 'n3',
          'type': 'NOTEBOOK',
          'title': 'What is an Array?',
          'estimatedSeconds': 180,
          'isRequired': true,
          'telemetryKey': 'g15_notebook_array'
        },
        {
          'id': 'n4',
          'type': 'MISSION',
          'title': 'Mission: Fix Off-by-One',
          'estimatedSeconds': 360,
          'isRequired': true,
          'telemetryKey': 'g15_mission_array'
        },
        {
          'id': 'n5',
          'type': 'THINKING',
          'title': 'Analyzing Result',
          'estimatedSeconds': 10,
          'isRequired': true,
          'telemetryKey': 'g15_thinking_array'
        },
        {
          'id': 'n6',
          'type': 'QUICK_CHECK',
          'title': 'Quick Check: Array Indexing',
          'estimatedSeconds': 60,
          'isRequired': true,
          'telemetryKey': 'g15_qc_array'
        },
        {
          'id': 'n7',
          'type': 'SANDBOX',
          'title': 'Sandbox: Array Playground',
          'estimatedSeconds': 300,
          'isRequired': false,
          'telemetryKey': 'g15_sandbox_array'
        }
      ]
    };
  }
}
