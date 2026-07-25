import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mocktail/mocktail.dart';
import 'package:scout_os_app/features/learning/infrastructure/dtos/learning_request_dtos.dart';
import 'package:scout_os_app/features/learning/presentation/controllers/journey_controller.dart';
import 'package:scout_os_app/features/learning/domain/usecases/load_journey_usecase.dart';
import 'package:scout_os_app/core/di/providers.dart';
import 'package:scout_os_app/features/learning/domain/entities/learning_entities.dart';
import 'package:hive/hive.dart';
import 'dart:io';

class MockLoadJourneyUseCase extends Mock implements LoadJourneyUseCase {}

class FakeJourneyRequest extends Fake implements JourneyRequest {}

void main() {
  late MockLoadJourneyUseCase mockUseCase;
  late ProviderContainer container;
  late Directory tempDir;

  setUpAll(() {
    registerFallbackValue(FakeJourneyRequest());
  });

  setUp(() async {
    mockUseCase = MockLoadJourneyUseCase();
    tempDir = await Directory.systemTemp.createTemp('hive_test');
    Hive.init(tempDir.path);
    await Hive.openBox('journey_cache');
    await Hive.openBox('mission_state');
    await Hive.openBox('telemetry_queue');
    
    container = ProviderContainer(
      overrides: [
        loadJourneyUseCaseProvider.overrideWithValue(mockUseCase),
      ],
    );
  });

  tearDown(() async {
    container.dispose();
    await Hive.close();
    await tempDir.delete(recursive: true);
  });

  group('JourneyController Tests', () {
    final mockGoal = LearningGoal(
      id: 'j_1',
      title: 'Test',
      activities: [
        RuntimeActivity(id: 'n1', type: NodeType.mission, title: 'N1', estimatedDuration: Duration(seconds: 10), isRequired: true, telemetryKey: 't1'),
        RuntimeActivity(id: 'n2', type: NodeType.notebook, title: 'N2', estimatedDuration: Duration(seconds: 10), isRequired: true, telemetryKey: 't2'),
      ],
    );

    test('Initial build starts loading and checks cache then network', () async {
      when(() => mockUseCase.getCachedJourney(any())).thenAnswer((_) async => (null, null));
      when(() => mockUseCase.refreshJourney(any())).thenAnswer((_) async => (mockGoal, null));

      final sub = container.listen(journeyProvider, (_, __) {});
      
      // Wait for async load to finish
      while(container.read(journeyProvider).isLoading) {
        await Future.delayed(const Duration(milliseconds: 10));
      }
      
      final state = container.read(journeyProvider);
      
      expect(state.isLoading, isFalse);
      expect(state.journey, isNotNull);
      expect(state.currentNodeId, 'n1');
      expect(state.lifecycle, NodeLifecycle.enter);
      
      sub.close();
    });

    test('interactNode transitions lifecycle to interact', () async {
      when(() => mockUseCase.getCachedJourney(any())).thenAnswer((_) async => (mockGoal, null));
      when(() => mockUseCase.refreshJourney(any())).thenAnswer((_) async => (mockGoal, null));

      final sub = container.listen(journeyProvider, (_, __) {});
      while(container.read(journeyProvider).isLoading) {
        await Future.delayed(const Duration(milliseconds: 10));
      }
      final notifier = container.read(journeyProvider.notifier);
      
      notifier.interactNode();
      expect(container.read(journeyProvider).lifecycle, NodeLifecycle.interact);
    });

    test('completeNode transitions lifecycle to complete', () async {
      when(() => mockUseCase.getCachedJourney(any())).thenAnswer((_) async => (mockGoal, null));
      when(() => mockUseCase.refreshJourney(any())).thenAnswer((_) async => (mockGoal, null));

      final sub = container.listen(journeyProvider, (_, __) {});
      while(container.read(journeyProvider).isLoading) {
        await Future.delayed(const Duration(milliseconds: 10));
      }
      final notifier = container.read(journeyProvider.notifier);
      
      notifier.completeNode();
      expect(container.read(journeyProvider).lifecycle, NodeLifecycle.complete);
    });

    test('nextNode transitions to the next node in the journey', () async {
      when(() => mockUseCase.getCachedJourney(any())).thenAnswer((_) async => (mockGoal, null));
      when(() => mockUseCase.refreshJourney(any())).thenAnswer((_) async => (mockGoal, null));

      final sub = container.listen(journeyProvider, (_, __) {});
      while(container.read(journeyProvider).isLoading) {
        await Future.delayed(const Duration(milliseconds: 10));
      }
      final notifier = container.read(journeyProvider.notifier);
      
      notifier.nextNode();
      
      final state = container.read(journeyProvider);
      expect(state.currentNodeId, 'n2');
      // n2 is notebook (passive), should auto transition to interact
      expect(state.lifecycle, NodeLifecycle.interact);
    });
  });
}
