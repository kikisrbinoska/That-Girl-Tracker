import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/step_data.dart';
import '../models/workout.dart';
import '../models/training_plan.dart';
import '../models/water_log.dart';
import '../models/meal.dart';
import '../models/routine.dart';
import '../models/sleep_log.dart';
import 'step_service.dart';
import 'fitness_repository.dart';
import 'nutrition_repository.dart';
import 'routine_repository.dart';

// ── Service / Repository Providers ──

final stepServiceProvider = Provider<StepService>((ref) => StepService());

final fitnessRepositoryProvider =
    Provider<FitnessRepository>((ref) => FitnessRepository());

final nutritionRepositoryProvider =
    Provider<NutritionRepository>((ref) => NutritionRepository());

final routineRepositoryProvider =
    Provider<RoutineRepository>((ref) => RoutineRepository());

// ── Step Providers ──

final stepCountProvider = StreamProvider<int>((ref) {
  final service = ref.watch(stepServiceProvider);
  return service.stepCountStream();
});

final todayStepsProvider = FutureProvider<StepData>((ref) async {
  final service = ref.watch(stepServiceProvider);
  return service.getTodaySteps();
});

final weeklyStepsProvider = FutureProvider<List<StepData>>((ref) async {
  final service = ref.watch(stepServiceProvider);
  return service.getWeeklySteps();
});

// ── Workout Providers ──

final workoutsProvider = StreamProvider<List<Workout>>((ref) {
  final repo = ref.watch(fitnessRepositoryProvider);
  return repo.getWorkouts();
});

final todayWorkoutsProvider = StreamProvider<List<Workout>>((ref) {
  final repo = ref.watch(fitnessRepositoryProvider);
  return repo.getTodayWorkouts();
});

// ── Training Plan Providers ──

final trainingPlanProvider = StreamProvider<List<TrainingPlan>>((ref) {
  final repo = ref.watch(fitnessRepositoryProvider);
  return repo.getTrainingPlan();
});

// ── Water Providers ──

final todayWaterLogProvider = StreamProvider<WaterLog?>((ref) {
  final repo = ref.watch(nutritionRepositoryProvider);
  return repo.watchTodayWaterLog();
});

final weeklyWaterProvider = FutureProvider<List<WaterLog>>((ref) async {
  final repo = ref.watch(nutritionRepositoryProvider);
  return repo.getWeeklyWaterLogs();
});

// ── Meal Providers ──

final todayMealsProvider = StreamProvider<List<Meal>>((ref) {
  final repo = ref.watch(nutritionRepositoryProvider);
  return repo.getTodayMeals();
});

// ── Routine Providers ──

final morningRoutineProvider = StreamProvider<Routine?>((ref) {
  final repo = ref.watch(routineRepositoryProvider);
  return repo.watchRoutine('morning');
});

final eveningRoutineProvider = StreamProvider<Routine?>((ref) {
  final repo = ref.watch(routineRepositoryProvider);
  return repo.watchRoutine('evening');
});

// ── Sleep Providers ──

final todaySleepProvider = FutureProvider<SleepLog?>((ref) async {
  final repo = ref.watch(routineRepositoryProvider);
  return repo.getTodaySleepLog();
});

final weeklySleepProvider = FutureProvider<List<SleepLog>>((ref) async {
  final repo = ref.watch(routineRepositoryProvider);
  return repo.getWeeklySleep();
});
