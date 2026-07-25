import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:scout_os_app/core/config/environment.dart';
import '../../../workbench/presentation/controllers/workbench_controller.dart';

// ===========================
// Academy Workspace Controller
// Manages the Journey Curriculum Tree and Node selection.
// Integrates with WorkbenchController when a Mission node is active.
// ===========================

class AcademyWorkspaceController extends GetxController {
  final String academyId;
  final String curriculumId;

  final isLoading = true.obs;
  
  // Curriculum Models
  final curriculumTitle = ''.obs;
  final units = <dynamic>[].obs;
  final journeyNodes = <String, dynamic>{}.obs;

  final activeNodeId = ''.obs;
  final activeNodeType = ''.obs;
  
  final activeDocumentBlocks = <dynamic>[].obs;
  final isDocumentLoading = false.obs;
  
  late WorkbenchController workbenchController;

  AcademyWorkspaceController({required this.academyId, required this.curriculumId});

  @override
  void onInit() {
    super.onInit();
    // Inject WorkbenchController so it's ready if a Mission is selected
    workbenchController = Get.put(WorkbenchController());
    _fetchJourney();
  }

  void _fetchJourney() async {
    try {
      final response = await http.get(
        Uri.parse('${Environment.apiBaseUrl}/academies/$academyId/journeys/$curriculumId')
      );
      
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final curr = data['curriculum'];
        final journey = data['journey'];
        
        curriculumTitle.value = curr['title'] ?? 'Academy Workspace';
        units.value = curr['units'] ?? [];
        
        // Map journey node states (LOCKED, UNLOCKED, COMPLETED, etc)
        final Map<String, dynamic> nodesMap = journey['nodes'] ?? {};
        journeyNodes.value = nodesMap;
        
        // Auto-select active node if any
        if (journey['active_node_id'] != null && journey['active_node_id'] != "") {
          selectNode(journey['active_node_id']);
        } else if (units.isNotEmpty) {
           final firstUnit = units.first;
           if (firstUnit['lessons'] != null && firstUnit['lessons'].isNotEmpty) {
             final firstLesson = firstUnit['lessons'].first;
             if (firstLesson['nodes'] != null && firstLesson['nodes'].isNotEmpty) {
               selectNode(firstLesson['nodes'].first['id'], type: firstLesson['nodes'].first['type']);
             }
           }
        }
      }
    } catch (e) {
      print('Failed to fetch journey: \$e');
    } finally {
      isLoading.value = false;
    }
  }

  void selectNode(String nodeId, {String? type}) {
    activeNodeId.value = nodeId;
    if (type != null) {
      activeNodeType.value = type;
    } else {
      // Find type from units tree
      for (var unit in units) {
        for (var lesson in (unit['lessons'] ?? [])) {
          for (var node in (lesson['nodes'] ?? [])) {
            if (node['id'] == nodeId) {
              activeNodeType.value = node['type'];
              break;
            }
          }
        }
      }
    }

    // If it's a mission, load it into Workbench
    if (activeNodeType.value == 'MISSION') {
      workbenchController.loadMission(nodeId);
    }
    
    // Always fetch the document AST for the node
    _fetchDocument(nodeId);
  }

  void _fetchDocument(String nodeId) async {
    isDocumentLoading.value = true;
    try {
      final response = await http.get(
        Uri.parse('${Environment.apiBaseUrl}/academies/$academyId/journeys/$curriculumId/nodes/$nodeId/document')
      );
      
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        activeDocumentBlocks.value = data['blocks'] ?? [];
      }
    } catch (e) {
      print('Failed to fetch document: \$e');
    } finally {
      isDocumentLoading.value = false;
    }
  }
}
