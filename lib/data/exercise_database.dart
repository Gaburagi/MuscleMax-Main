import '../models/workout_model.dart';

class ExerciseDatabase {
  // Complete exercise library organized by muscle groups
  static final Map<String, List<Exercise>> exercisesByMuscleGroup = {
    'Chest': chestExercises,
    'Back': backExercises,
    'Legs': legExercises,
    'Shoulders': shoulderExercises,
    'Arms': armExercises,
    'Core': coreExercises,
    'Cardio': cardioExercises,
    'Full Body': fullBodyExercises,
  };

  // CHEST EXERCISES
  static final List<Exercise> chestExercises = [
    Exercise(
      id: 'chest_1',
      name: 'Barbell Bench Press',
      sets: 4,
      reps: 8,
      restSeconds: 120,
      instructions: 'Lie flat on bench, grip bar slightly wider than shoulders, lower to chest, press up explosively',
    ),
    Exercise(
      id: 'chest_2',
      name: 'Incline Dumbbell Press',
      sets: 4,
      reps: 10,
      restSeconds: 90,
      instructions: 'Set bench to 30-45 degrees, press dumbbells up and together at the top',
    ),
    Exercise(
      id: 'chest_3',
      name: 'Decline Bench Press',
      sets: 3,
      reps: 10,
      restSeconds: 90,
      instructions: 'Set bench to decline position, lower bar to lower chest, press up',
    ),
    Exercise(
      id: 'chest_4',
      name: 'Chest Dips',
      sets: 3,
      reps: 12,
      restSeconds: 60,
      instructions: 'Lean forward slightly, lower until upper arms parallel to floor, push back up',
    ),
    Exercise(
      id: 'chest_5',
      name: 'Cable Flyes',
      sets: 3,
      reps: 15,
      restSeconds: 60,
      instructions: 'Set cables at chest height, bring hands together in front of chest with slight bend in elbows',
    ),
    Exercise(
      id: 'chest_6',
      name: 'Dumbbell Flyes',
      sets: 3,
      reps: 12,
      restSeconds: 60,
      instructions: 'Lie flat, open arms wide with slight elbow bend, bring dumbbells together above chest',
    ),
    Exercise(
      id: 'chest_7',
      name: 'Push-ups',
      sets: 3,
      reps: 15,
      restSeconds: 45,
      instructions: 'Standard push-up form, body straight, lower chest to ground, push up',
    ),
    Exercise(
      id: 'chest_8',
      name: 'Incline Push-ups',
      sets: 3,
      reps: 15,
      restSeconds: 45,
      instructions: 'Hands on elevated surface, perform push-ups targeting upper chest',
    ),
    Exercise(
      id: 'chest_9',
      name: 'Decline Push-ups',
      sets: 3,
      reps: 12,
      restSeconds: 45,
      instructions: 'Feet elevated, perform push-ups targeting lower chest',
    ),
    Exercise(
      id: 'chest_10',
      name: 'Pec Deck Machine',
      sets: 3,
      reps: 15,
      restSeconds: 60,
      instructions: 'Sit with back against pad, bring arms together in front of chest',
    ),
  ];

  // BACK EXERCISES
  static final List<Exercise> backExercises = [
    Exercise(
      id: 'back_1',
      name: 'Deadlift',
      sets: 4,
      reps: 6,
      restSeconds: 180,
      instructions: 'Hip-width stance, grip bar outside legs, pull with legs and back, keep spine neutral',
    ),
    Exercise(
      id: 'back_2',
      name: 'Pull-ups',
      sets: 4,
      reps: 10,
      restSeconds: 90,
      instructions: 'Hang from bar, pull until chin over bar, lower with control',
    ),
    Exercise(
      id: 'back_3',
      name: 'Barbell Rows',
      sets: 4,
      reps: 10,
      restSeconds: 90,
      instructions: 'Bend at hips, pull bar to lower chest, squeeze shoulder blades together',
    ),
    Exercise(
      id: 'back_4',
      name: 'Lat Pulldown',
      sets: 4,
      reps: 12,
      restSeconds: 60,
      instructions: 'Sit at machine, pull bar down to upper chest, squeeze lats',
    ),
    Exercise(
      id: 'back_5',
      name: 'T-Bar Row',
      sets: 4,
      reps: 10,
      restSeconds: 90,
      instructions: 'Straddle bar, pull handle to chest, keep back straight',
    ),
    Exercise(
      id: 'back_6',
      name: 'Seated Cable Row',
      sets: 4,
      reps: 12,
      restSeconds: 60,
      instructions: 'Sit at cable machine, pull handle to midsection, squeeze back',
    ),
    Exercise(
      id: 'back_7',
      name: 'Dumbbell Rows',
      sets: 4,
      reps: 12,
      restSeconds: 60,
      instructions: 'Support with one hand, row dumbbell to hip with other arm',
    ),
    Exercise(
      id: 'back_8',
      name: 'Face Pulls',
      sets: 3,
      reps: 15,
      restSeconds: 45,
      instructions: 'Pull rope towards face, split rope around head, squeeze rear delts',
    ),
    Exercise(
      id: 'back_9',
      name: 'Hyperextensions',
      sets: 3,
      reps: 15,
      restSeconds: 60,
      instructions: 'Position on hyperextension bench, lower torso, raise back up using lower back',
    ),
    Exercise(
      id: 'back_10',
      name: 'Inverted Rows',
      sets: 3,
      reps: 12,
      restSeconds: 60,
      instructions: 'Under bar, pull chest to bar, keep body straight',
    ),
  ];

  // LEG EXERCISES
  static final List<Exercise> legExercises = [
    Exercise(
      id: 'legs_1',
      name: 'Barbell Squat',
      sets: 4,
      reps: 8,
      restSeconds: 120,
      instructions: 'Bar on upper back, squat down until thighs parallel, drive through heels',
    ),
    Exercise(
      id: 'legs_2',
      name: 'Front Squat',
      sets: 4,
      reps: 10,
      restSeconds: 120,
      instructions: 'Bar on front shoulders, keep torso upright, squat deep',
    ),
    Exercise(
      id: 'legs_3',
      name: 'Romanian Deadlift',
      sets: 4,
      reps: 10,
      restSeconds: 90,
      instructions: 'Slight knee bend, hinge at hips, lower bar along legs, feel hamstring stretch',
    ),
    Exercise(
      id: 'legs_4',
      name: 'Leg Press',
      sets: 4,
      reps: 12,
      restSeconds: 90,
      instructions: 'Feet shoulder-width on platform, press up, control descent',
    ),
    Exercise(
      id: 'legs_5',
      name: 'Bulgarian Split Squat',
      sets: 3,
      reps: 12,
      restSeconds: 60,
      instructions: 'Rear foot elevated, squat down on front leg, drive through front heel',
    ),
    Exercise(
      id: 'legs_6',
      name: 'Leg Extension',
      sets: 3,
      reps: 15,
      restSeconds: 60,
      instructions: 'Sit at machine, extend legs fully, squeeze quads at top',
    ),
    Exercise(
      id: 'legs_7',
      name: 'Leg Curl',
      sets: 3,
      reps: 15,
      restSeconds: 60,
      instructions: 'Lie face down, curl legs up, squeeze hamstrings',
    ),
    Exercise(
      id: 'legs_8',
      name: 'Walking Lunges',
      sets: 3,
      reps: 20,
      restSeconds: 60,
      instructions: 'Step forward into lunge, alternate legs, keep torso upright',
    ),
    Exercise(
      id: 'legs_9',
      name: 'Calf Raises',
      sets: 4,
      reps: 20,
      restSeconds: 45,
      instructions: 'Rise up on toes, hold at top, lower with control',
    ),
    Exercise(
      id: 'legs_10',
      name: 'Goblet Squat',
      sets: 3,
      reps: 15,
      restSeconds: 60,
      instructions: 'Hold dumbbell at chest, squat deep, elbows between knees',
    ),
  ];

  // SHOULDER EXERCISES
  static final List<Exercise> shoulderExercises = [
    Exercise(
      id: 'shoulders_1',
      name: 'Overhead Press',
      sets: 4,
      reps: 8,
      restSeconds: 120,
      instructions: 'Press bar overhead, lock out arms, control descent to shoulders',
    ),
    Exercise(
      id: 'shoulders_2',
      name: 'Dumbbell Shoulder Press',
      sets: 4,
      reps: 10,
      restSeconds: 90,
      instructions: 'Press dumbbells overhead, rotate wrists at top',
    ),
    Exercise(
      id: 'shoulders_3',
      name: 'Lateral Raises',
      sets: 4,
      reps: 15,
      restSeconds: 45,
      instructions: 'Raise dumbbells to sides until arms parallel to floor, control descent',
    ),
    Exercise(
      id: 'shoulders_4',
      name: 'Front Raises',
      sets: 3,
      reps: 15,
      restSeconds: 45,
      instructions: 'Raise dumbbells in front to shoulder height, alternate or together',
    ),
    Exercise(
      id: 'shoulders_5',
      name: 'Arnold Press',
      sets: 3,
      reps: 12,
      restSeconds: 90,
      instructions: 'Start palms facing you, rotate as you press up, reverse on descent',
    ),
    Exercise(
      id: 'shoulders_6',
      name: 'Upright Rows',
      sets: 3,
      reps: 12,
      restSeconds: 60,
      instructions: 'Pull bar up along body to chin, elbows high and wide',
    ),
    Exercise(
      id: 'shoulders_7',
      name: 'Reverse Flyes',
      sets: 3,
      reps: 15,
      restSeconds: 60,
      instructions: 'Bend forward, raise dumbbells out to sides, squeeze shoulder blades',
    ),
    Exercise(
      id: 'shoulders_8',
      name: 'Shrugs',
      sets: 4,
      reps: 15,
      restSeconds: 60,
      instructions: 'Hold heavy dumbbells, shrug shoulders up, hold briefly, lower',
    ),
    Exercise(
      id: 'shoulders_9',
      name: 'Cable Lateral Raises',
      sets: 3,
      reps: 15,
      restSeconds: 45,
      instructions: 'Single arm, pull cable from low to high, maintain tension',
    ),
    Exercise(
      id: 'shoulders_10',
      name: 'Pike Push-ups',
      sets: 3,
      reps: 12,
      restSeconds: 60,
      instructions: 'Hips high, lower head towards ground, press back up',
    ),
  ];

  // ARM EXERCISES
  static final List<Exercise> armExercises = [
    Exercise(
      id: 'arms_1',
      name: 'Barbell Curl',
      sets: 4,
      reps: 10,
      restSeconds: 60,
      instructions: 'Grip bar shoulder-width, curl up, squeeze biceps, control descent',
    ),
    Exercise(
      id: 'arms_2',
      name: 'Hammer Curls',
      sets: 3,
      reps: 12,
      restSeconds: 60,
      instructions: 'Hold dumbbells with neutral grip, curl up, control down',
    ),
    Exercise(
      id: 'arms_3',
      name: 'Preacher Curls',
      sets: 3,
      reps: 12,
      restSeconds: 60,
      instructions: 'Arms on preacher bench, curl bar up, squeeze at top',
    ),
    Exercise(
      id: 'arms_4',
      name: 'Tricep Dips',
      sets: 4,
      reps: 12,
      restSeconds: 60,
      instructions: 'On parallel bars, lower body, push back up using triceps',
    ),
    Exercise(
      id: 'arms_5',
      name: 'Close-Grip Bench Press',
      sets: 4,
      reps: 10,
      restSeconds: 90,
      instructions: 'Narrow grip, lower to chest keeping elbows close, press up',
    ),
    Exercise(
      id: 'arms_6',
      name: 'Skull Crushers',
      sets: 3,
      reps: 12,
      restSeconds: 60,
      instructions: 'Lie on bench, lower bar to forehead, extend arms',
    ),
    Exercise(
      id: 'arms_7',
      name: 'Cable Pushdowns',
      sets: 3,
      reps: 15,
      restSeconds: 45,
      instructions: 'Push bar down, lock out triceps, control return',
    ),
    Exercise(
      id: 'arms_8',
      name: 'Concentration Curls',
      sets: 3,
      reps: 12,
      restSeconds: 60,
      instructions: 'Seated, elbow on thigh, curl dumbbell up with focus',
    ),
    Exercise(
      id: 'arms_9',
      name: 'Cable Curls',
      sets: 3,
      reps: 15,
      restSeconds: 45,
      instructions: 'Stand at cable machine, curl bar up, maintain tension',
    ),
    Exercise(
      id: 'arms_10',
      name: 'Overhead Tricep Extension',
      sets: 3,
      reps: 12,
      restSeconds: 60,
      instructions: 'Hold dumbbell overhead, lower behind head, extend up',
    ),
  ];

  // CORE EXERCISES
  static final List<Exercise> coreExercises = [
    Exercise(
      id: 'core_1',
      name: 'Plank',
      sets: 3,
      reps: 1,
      restSeconds: 60,
      instructions: 'Hold body straight in plank position for 30-60 seconds',
    ),
    Exercise(
      id: 'core_2',
      name: 'Crunches',
      sets: 3,
      reps: 20,
      restSeconds: 45,
      instructions: 'Lie on back, curl upper body up, squeeze abs',
    ),
    Exercise(
      id: 'core_3',
      name: 'Russian Twists',
      sets: 3,
      reps: 30,
      restSeconds: 45,
      instructions: 'Seated, lean back, rotate torso side to side',
    ),
    Exercise(
      id: 'core_4',
      name: 'Bicycle Crunches',
      sets: 3,
      reps: 30,
      restSeconds: 45,
      instructions: 'Alternating elbow to opposite knee, extend other leg',
    ),
    Exercise(
      id: 'core_5',
      name: 'Leg Raises',
      sets: 3,
      reps: 15,
      restSeconds: 60,
      instructions: 'Lie flat, raise legs to 90 degrees, lower with control',
    ),
    Exercise(
      id: 'core_6',
      name: 'Mountain Climbers',
      sets: 3,
      reps: 30,
      restSeconds: 45,
      instructions: 'Plank position, drive knees to chest alternating quickly',
    ),
    Exercise(
      id: 'core_7',
      name: 'Side Plank',
      sets: 3,
      reps: 1,
      restSeconds: 60,
      instructions: 'Hold body straight on side, 30-45 seconds each side',
    ),
    Exercise(
      id: 'core_8',
      name: 'Dead Bug',
      sets: 3,
      reps: 20,
      restSeconds: 45,
      instructions: 'On back, extend opposite arm and leg, alternate',
    ),
    Exercise(
      id: 'core_9',
      name: 'Ab Wheel Rollout',
      sets: 3,
      reps: 12,
      restSeconds: 60,
      instructions: 'Roll ab wheel forward, extend fully, pull back',
    ),
    Exercise(
      id: 'core_10',
      name: 'Hanging Knee Raises',
      sets: 3,
      reps: 15,
      restSeconds: 60,
      instructions: 'Hang from bar, raise knees to chest, control descent',
    ),
  ];

  // CARDIO EXERCISES
  static final List<Exercise> cardioExercises = [
    Exercise(
      id: 'cardio_1',
      name: 'Burpees',
      sets: 3,
      reps: 15,
      restSeconds: 60,
      instructions: 'Squat, jump feet back, push-up, jump feet in, jump up',
    ),
    Exercise(
      id: 'cardio_2',
      name: 'Jumping Jacks',
      sets: 3,
      reps: 30,
      restSeconds: 30,
      instructions: 'Jump legs apart while raising arms overhead, return',
    ),
    Exercise(
      id: 'cardio_3',
      name: 'High Knees',
      sets: 3,
      reps: 30,
      restSeconds: 30,
      instructions: 'Run in place bringing knees high, maintain quick pace',
    ),
    Exercise(
      id: 'cardio_4',
      name: 'Jump Rope',
      sets: 3,
      reps: 1,
      restSeconds: 60,
      instructions: 'Jump rope for 1-2 minutes, maintain rhythm',
    ),
    Exercise(
      id: 'cardio_5',
      name: 'Box Jumps',
      sets: 3,
      reps: 12,
      restSeconds: 90,
      instructions: 'Jump onto box, land softly, step down',
    ),
    Exercise(
      id: 'cardio_6',
      name: 'Sprints',
      sets: 5,
      reps: 1,
      restSeconds: 120,
      instructions: 'Sprint at maximum effort for 20-30 seconds',
    ),
    Exercise(
      id: 'cardio_7',
      name: 'Battle Ropes',
      sets: 3,
      reps: 1,
      restSeconds: 60,
      instructions: 'Alternate wave motion with ropes for 30 seconds',
    ),
    Exercise(
      id: 'cardio_8',
      name: 'Rowing Machine',
      sets: 3,
      reps: 1,
      restSeconds: 90,
      instructions: 'Row for 1-2 minutes at steady pace',
    ),
  ];

  // FULL BODY EXERCISES
  static final List<Exercise> fullBodyExercises = [
    Exercise(
      id: 'fullbody_1',
      name: 'Clean and Press',
      sets: 4,
      reps: 6,
      restSeconds: 120,
      instructions: 'Clean bar to shoulders, press overhead, lower with control',
    ),
    Exercise(
      id: 'fullbody_2',
      name: 'Thrusters',
      sets: 4,
      reps: 10,
      restSeconds: 90,
      instructions: 'Squat with dumbbells, stand and press overhead in one motion',
    ),
    Exercise(
      id: 'fullbody_3',
      name: 'Man Makers',
      sets: 3,
      reps: 8,
      restSeconds: 120,
      instructions: 'Burpee with dumbbells, add row at bottom, press at top',
    ),
    Exercise(
      id: 'fullbody_4',
      name: 'Turkish Get-Up',
      sets: 3,
      reps: 5,
      restSeconds: 90,
      instructions: 'Complex movement from lying to standing with weight overhead',
    ),
    Exercise(
      id: 'fullbody_5',
      name: 'Kettlebell Swings',
      sets: 4,
      reps: 20,
      restSeconds: 60,
      instructions: 'Hip hinge, swing kettlebell to shoulder height, control descent',
    ),
  ];

  // Get all exercises
  static List<Exercise> getAllExercises() {
    return [
      ...chestExercises,
      ...backExercises,
      ...legExercises,
      ...shoulderExercises,
      ...armExercises,
      ...coreExercises,
      ...cardioExercises,
      ...fullBodyExercises,
    ];
  }

  // Get exercises by muscle group
  static List<Exercise> getExercisesByMuscleGroup(String muscleGroup) {
    return exercisesByMuscleGroup[muscleGroup] ?? [];
  }

  // Get random exercises
  static List<Exercise> getRandomExercises(int count, {String? muscleGroup}) {
    List<Exercise> pool = muscleGroup != null 
        ? getExercisesByMuscleGroup(muscleGroup)
        : getAllExercises();
    
    pool.shuffle();
    return pool.take(count).toList();
  }

  // Search exercises by name
  static List<Exercise> searchExercises(String query) {
    final allExercises = getAllExercises();
    return allExercises.where((exercise) => 
      exercise.name.toLowerCase().contains(query.toLowerCase())
    ).toList();
  }
}
