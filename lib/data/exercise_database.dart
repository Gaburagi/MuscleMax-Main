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
      videoUrl: 'https://www.youtube.com/watch?v=rT7DgCr-3pg',
    ),
    Exercise(
      id: 'chest_2',
      name: 'Incline Dumbbell Press',
      sets: 4,
      reps: 10,
      restSeconds: 90,
      instructions: 'Set bench to 30-45 degrees, press dumbbells up and together at the top',
      videoUrl: 'https://www.youtube.com/watch?v=8iPEnn-ltC8',
    ),
    Exercise(
      id: 'chest_3',
      name: 'Decline Bench Press',
      sets: 3,
      reps: 10,
      restSeconds: 90,
      instructions: 'Set bench to decline position, lower bar to lower chest, press up',
      videoUrl: 'https://www.youtube.com/watch?v=OR6WM5Z2Hqs',
    ),
    Exercise(
      id: 'chest_4',
      name: 'Chest Dips',
      sets: 3,
      reps: 12,
      restSeconds: 60,
      instructions: 'Lean forward slightly, lower until upper arms parallel to floor, push back up',
      videoUrl: 'https://www.youtube.com/watch?v=2z8JmcrW-As',
    ),
    Exercise(
      id: 'chest_5',
      name: 'Cable Flyes',
      sets: 3,
      reps: 15,
      restSeconds: 60,
      instructions: 'Set cables at chest height, bring hands together in front of chest with slight bend in elbows',
      videoUrl: 'https://www.youtube.com/watch?v=JUDTGZh4rhg',
    ),
    Exercise(
      id: 'chest_6',
      name: 'Dumbbell Flyes',
      sets: 3,
      reps: 12,
      restSeconds: 60,
      instructions: 'Lie flat, open arms wide with slight elbow bend, bring dumbbells together above chest',
      videoUrl: 'https://www.youtube.com/watch?v=vRoodNNq4rY',
    ),
    Exercise(
      id: 'chest_7',
      name: 'Push-ups',
      sets: 3,
      reps: 15,
      restSeconds: 45,
      instructions: 'Standard push-up form, body straight, lower chest to ground, push up',
      videoUrl: 'https://www.youtube.com/watch?v=IODxDxX7oi4',
    ),
    Exercise(
      id: 'chest_8',
      name: 'Incline Push-ups',
      sets: 3,
      reps: 15,
      restSeconds: 45,
      instructions: 'Hands on elevated surface, perform push-ups targeting upper chest',
      videoUrl: 'https://www.youtube.com/watch?v=8HWFJ9xJtL8',
    ),
    Exercise(
      id: 'chest_9',
      name: 'Decline Push-ups',
      sets: 3,
      reps: 12,
      restSeconds: 45,
      instructions: 'Feet elevated, perform push-ups targeting lower chest',
      videoUrl: 'https://www.youtube.com/watch?v=IZxyjW7MPJQ',
    ),
    Exercise(
      id: 'chest_10',
      name: 'Pec Deck Machine',
      sets: 3,
      reps: 15,
      restSeconds: 60,
      instructions: 'Sit with back against pad, bring arms together in front of chest',
      videoUrl: 'https://www.youtube.com/watch?v=JJitfZKlKk4',
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
      videoUrl: 'https://www.youtube.com/watch?v=3W-g4SGb26o',
    ),
    Exercise(
      id: 'back_2',
      name: 'Pull-ups',
      sets: 4,
      reps: 10,
      restSeconds: 90,
      instructions: 'Hang from bar, pull until chin over bar, lower with control',
      videoUrl: 'https://www.youtube.com/watch?v=dAScZVF5o9k',
    ),
    Exercise(
      id: 'back_3',
      name: 'Barbell Rows',
      sets: 4,
      reps: 10,
      restSeconds: 90,
      instructions: 'Bend at hips, pull bar to lower chest, squeeze shoulder blades together',
      videoUrl: 'https://www.youtube.com/watch?v=FWJR5Ve8bnQ',
    ),
    Exercise(
      id: 'back_4',
      name: 'Lat Pulldown',
      sets: 4,
      reps: 12,
      restSeconds: 60,
      instructions: 'Sit at machine, pull bar down to upper chest, squeeze lats',
      videoUrl: 'https://www.youtube.com/watch?v=43hWj8mfYGY',
    ),
    Exercise(
      id: 'back_5',
      name: 'T-Bar Row',
      sets: 4,
      reps: 10,
      restSeconds: 90,
      instructions: 'Straddle bar, pull handle to chest, keep back straight',
      videoUrl: 'https://www.youtube.com/watch?v=sw3JUZbvxWQ',
    ),
    Exercise(
      id: 'back_6',
      name: 'Seated Cable Row',
      sets: 4,
      reps: 12,
      restSeconds: 60,
      instructions: 'Sit at cable machine, pull handle to midsection, squeeze back',
      videoUrl: 'https://www.youtube.com/watch?v=mW9mREQ-D1o',
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
      videoUrl: 'https://www.youtube.com/watch?v=eFxMixk_qPQ',
    ),
    Exercise(
      id: 'back_9',
      name: 'Hyperextensions',
      sets: 3,
      reps: 15,
      restSeconds: 60,
      instructions: 'Position on hyperextension bench, lower torso, raise back up using lower back',
      videoUrl: 'https://www.youtube.com/watch?v=k6LyPhGRV-o',
    ),
    Exercise(
      id: 'back_10',
      name: 'Inverted Rows',
      sets: 3,
      reps: 12,
      restSeconds: 60,
      instructions: 'Under bar, pull chest to bar, keep body straight',
      videoUrl: 'https://www.youtube.com/watch?v=5Vy6mjhXg7s',
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
      videoUrl: 'https://www.youtube.com/watch?v=Dy28eq2PjcM',
    ),
    Exercise(
      id: 'legs_2',
      name: 'Front Squat',
      sets: 4,
      reps: 10,
      restSeconds: 120,
      instructions: 'Bar on front shoulders, keep torso upright, squat deep',
      videoUrl: 'https://www.youtube.com/watch?v=tifNwANXR5o',
    ),
    Exercise(
      id: 'legs_3',
      name: 'Romanian Deadlift',
      sets: 4,
      reps: 10,
      restSeconds: 90,
      instructions: 'Slight knee bend, hinge at hips, lower bar along legs, feel hamstring stretch',
      videoUrl: 'https://www.youtube.com/watch?v=2SHsk9AzdjA',
    ),
    Exercise(
      id: 'legs_4',
      name: 'Leg Press',
      sets: 4,
      reps: 12,
      restSeconds: 90,
      instructions: 'Feet shoulder-width on platform, press up, control descent',
      videoUrl: 'https://www.youtube.com/watch?v=IZxyjW7MPJQ',
    ),
    Exercise(
      id: 'legs_5',
      name: 'Bulgarian Split Squat',
      sets: 3,
      reps: 12,
      restSeconds: 60,
      instructions: 'Rear foot elevated, squat down on front leg, drive through front heel',
      videoUrl: 'https://www.youtube.com/watch?v=2C-uNgKwPLE',
    ),
    Exercise(
      id: 'legs_6',
      name: 'Leg Extension',
      sets: 3,
      reps: 15,
      restSeconds: 60,
      instructions: 'Sit at machine, extend legs fully, squeeze quads at top',
      videoUrl: 'https://www.youtube.com/watch?v=YyvSfVjQeL0',
    ),
    Exercise(
      id: 'legs_7',
      name: 'Leg Curl',
      sets: 3,
      reps: 15,
      restSeconds: 60,
      instructions: 'Lie face down, curl legs up, squeeze hamstrings',
      videoUrl: 'https://www.youtube.com/watch?v=1Tq3QdYUuHs',
    ),
    Exercise(
      id: 'legs_8',
      name: 'Walking Lunges',
      sets: 3,
      reps: 20,
      restSeconds: 60,
      instructions: 'Step forward into lunge, alternate legs, keep torso upright',
      videoUrl: 'https://www.youtube.com/watch?v=Z2n58m2i4jg',
    ),
    Exercise(
      id: 'legs_9',
      name: 'Calf Raises',
      sets: 4,
      reps: 20,
      restSeconds: 45,
      instructions: 'Rise up on toes, hold at top, lower with control',
      videoUrl: 'https://www.youtube.com/watch?v=YMmgqO8Jo-k',
    ),
    Exercise(
      id: 'legs_10',
      name: 'Goblet Squat',
      sets: 3,
      reps: 15,
      restSeconds: 60,
      instructions: 'Hold dumbbell at chest, squat deep, elbows between knees',
      videoUrl: 'https://www.youtube.com/watch?v=MeIiIdhvXT0',
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
      videoUrl: 'https://www.youtube.com/watch?v=F3QY5vMz_6I',
    ),
    Exercise(
      id: 'shoulders_2',
      name: 'Dumbbell Shoulder Press',
      sets: 4,
      reps: 10,
      restSeconds: 90,
      instructions: 'Press dumbbells overhead, rotate wrists at top',
      videoUrl: 'https://www.youtube.com/watch?v=B-aVuyhvLHU',
    ),
    Exercise(
      id: 'shoulders_3',
      name: 'Lateral Raises',
      sets: 4,
      reps: 15,
      restSeconds: 45,
      instructions: 'Raise dumbbells to sides until arms parallel to floor, control descent',
      videoUrl: 'https://www.youtube.com/watch?v=3VcKaXpzqRo',
    ),
    Exercise(
      id: 'shoulders_4',
      name: 'Front Raises',
      sets: 3,
      reps: 15,
      restSeconds: 45,
      instructions: 'Raise dumbbells in front to shoulder height, alternate or together',
      videoUrl: 'https://www.youtube.com/watch?v=-t7fuZ0KhDA',
    ),
    Exercise(
      id: 'shoulders_5',
      name: 'Arnold Press',
      sets: 3,
      reps: 12,
      restSeconds: 90,
      instructions: 'Start palms facing you, rotate as you press up, reverse on descent',
      videoUrl: 'https://www.youtube.com/watch?v=vj2w851ZHRM',
    ),
    Exercise(
      id: 'shoulders_6',
      name: 'Upright Rows',
      sets: 3,
      reps: 12,
      restSeconds: 60,
      instructions: 'Pull bar up along body to chin, elbows high and wide',
      videoUrl: 'https://www.youtube.com/watch?v=IPuX5COaQGk',
    ),
    Exercise(
      id: 'shoulders_7',
      name: 'Reverse Flyes',
      sets: 3,
      reps: 15,
      restSeconds: 60,
      instructions: 'Bend forward, raise dumbbells out to sides, squeeze shoulder blades',
      videoUrl: 'https://www.youtube.com/watch?v=6yMdhi5ELOE',
    ),
    Exercise(
      id: 'shoulders_8',
      name: 'Shrugs',
      sets: 4,
      reps: 15,
      restSeconds: 60,
      instructions: 'Hold heavy dumbbells, shrug shoulders up, hold briefly, lower',
      videoUrl: 'https://www.youtube.com/watch?v=Vf5n4V8_MDY',
    ),
    Exercise(
      id: 'shoulders_9',
      name: 'Cable Lateral Raises',
      sets: 3,
      reps: 15,
      restSeconds: 45,
      instructions: 'Single arm, pull cable from low to high, maintain tension',
      videoUrl: 'https://www.youtube.com/watch?v=B0Q0q9Ua3jQ',
    ),
    Exercise(
      id: 'shoulders_10',
      name: 'Pike Push-ups',
      sets: 3,
      reps: 12,
      restSeconds: 60,
      instructions: 'Hips high, lower head towards ground, press back up',
      videoUrl: 'https://www.youtube.com/watch?v=FvQS4DkdU3o',
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
      videoUrl: 'https://www.youtube.com/watch?v=kwG2ipFRgfo',
    ),
    Exercise(
      id: 'arms_2',
      name: 'Hammer Curls',
      sets: 3,
      reps: 12,
      restSeconds: 60,
      instructions: 'Hold dumbbells with neutral grip, curl up, control down',
      videoUrl: 'https://www.youtube.com/watch?v=zC3nLlEvin4',
    ),
    Exercise(
      id: 'arms_3',
      name: 'Preacher Curls',
      sets: 3,
      reps: 12,
      restSeconds: 60,
      instructions: 'Arms on preacher bench, curl bar up, squeeze at top',
      videoUrl: 'https://www.youtube.com/watch?v=E94dVv23J8s',
    ),
    Exercise(
      id: 'arms_4',
      name: 'Tricep Dips',
      sets: 4,
      reps: 12,
      restSeconds: 60,
      instructions: 'On parallel bars, lower body, push back up using triceps',
      videoUrl: 'https://www.youtube.com/watch?v=0326dy_-CzM',
    ),
    Exercise(
      id: 'arms_5',
      name: 'Close-Grip Bench Press',
      sets: 4,
      reps: 10,
      restSeconds: 90,
      instructions: 'Narrow grip, lower to chest keeping elbows close, press up',
      videoUrl: 'https://www.youtube.com/watch?v=5aY91NQ0G0Q',
    ),
    Exercise(
      id: 'arms_6',
      name: 'Skull Crushers',
      sets: 3,
      reps: 12,
      restSeconds: 60,
      instructions: 'Lie on bench, lower bar to forehead, extend arms',
      videoUrl: 'https://www.youtube.com/watch?v=d_KZxkY_0cM',
    ),
    Exercise(
      id: 'arms_7',
      name: 'Cable Pushdowns',
      sets: 3,
      reps: 15,
      restSeconds: 45,
      instructions: 'Push bar down, lock out triceps, control return',
      videoUrl: 'https://www.youtube.com/watch?v=2-LAMcpzODU',
    ),
    Exercise(
      id: 'arms_8',
      name: 'Concentration Curls',
      sets: 3,
      reps: 12,
      restSeconds: 60,
      instructions: 'Seated, elbow on thigh, curl dumbbell up with focus',
      videoUrl: 'https://www.youtube.com/watch?v=jq0h1Vb9H5M',
    ),
    Exercise(
      id: 'arms_9',
      name: 'Cable Curls',
      sets: 3,
      reps: 15,
      restSeconds: 45,
      instructions: 'Stand at cable machine, curl bar up, maintain tension',
      videoUrl: 'https://www.youtube.com/watch?v=8BN8Iu5gmFE',
    ),
    Exercise(
      id: 'arms_10',
      name: 'Overhead Tricep Extension',
      sets: 3,
      reps: 12,
      restSeconds: 60,
      instructions: 'Hold dumbbell overhead, lower behind head, extend up',
      videoUrl: 'https://www.youtube.com/watch?v=6SSqN7E2-jU',
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
      videoUrl: 'https://www.youtube.com/watch?v=pSHjTRCQxIw',
    ),
    Exercise(
      id: 'core_2',
      name: 'Crunches',
      sets: 3,
      reps: 20,
      restSeconds: 45,
      instructions: 'Lie on back, curl upper body up, squeeze abs',
      videoUrl: 'https://www.youtube.com/watch?v=Xyd_fa5zoEU',
    ),
    Exercise(
      id: 'core_3',
      name: 'Russian Twists',
      sets: 3,
      reps: 30,
      restSeconds: 45,
      instructions: 'Seated, lean back, rotate torso side to side',
      videoUrl: 'https://www.youtube.com/watch?v=wkD8rjkodUI',
    ),
    Exercise(
      id: 'core_4',
      name: 'Bicycle Crunches',
      sets: 3,
      reps: 30,
      restSeconds: 45,
      instructions: 'Alternating elbow to opposite knee, extend other leg',
      videoUrl: 'https://www.youtube.com/watch?v=9FGilxCbdz8',
    ),
    Exercise(
      id: 'core_5',
      name: 'Leg Raises',
      sets: 3,
      reps: 15,
      restSeconds: 60,
      instructions: 'Lie flat, raise legs to 90 degrees, lower with control',
      videoUrl: 'https://www.youtube.com/watch?v=JB2oyawG9KI',
    ),
    Exercise(
      id: 'core_6',
      name: 'Mountain Climbers',
      sets: 3,
      reps: 30,
      restSeconds: 45,
      instructions: 'Plank position, drive knees to chest alternating quickly',
      videoUrl: 'https://www.youtube.com/watch?v=nmwgirgXLYM',
    ),
    Exercise(
      id: 'core_7',
      name: 'Side Plank',
      sets: 3,
      reps: 1,
      restSeconds: 60,
      instructions: 'Hold body straight on side, 30-45 seconds each side',
      videoUrl: 'https://www.youtube.com/watch?v=K2VljzCC16g',
    ),
    Exercise(
      id: 'core_8',
      name: 'Dead Bug',
      sets: 3,
      reps: 20,
      restSeconds: 45,
      instructions: 'On back, extend opposite arm and leg, alternate',
      videoUrl: 'https://www.youtube.com/watch?v=4j3T4w_1l8g',
    ),
    Exercise(
      id: 'core_9',
      name: 'Ab Wheel Rollout',
      sets: 3,
      reps: 12,
      restSeconds: 60,
      instructions: 'Roll ab wheel forward, extend fully, pull back',
      videoUrl: 'https://www.youtube.com/watch?v=8x1MAbk8P-4',
    ),
    Exercise(
      id: 'core_10',
      name: 'Hanging Knee Raises',
      sets: 3,
      reps: 15,
      restSeconds: 60,
      instructions: 'Hang from bar, raise knees to chest, control descent',
      videoUrl: 'https://www.youtube.com/watch?v=ymigWt5TOV8',
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
      videoUrl: 'https://www.youtube.com/watch?v=TU8QYVW0gDU',
    ),
    Exercise(
      id: 'cardio_2',
      name: 'Jumping Jacks',
      sets: 3,
      reps: 30,
      restSeconds: 30,
      instructions: 'Jump legs apart while raising arms overhead, return',
      videoUrl: 'https://www.youtube.com/watch?v=c4DAnQ6DtF8',
    ),
    Exercise(
      id: 'cardio_3',
      name: 'High Knees',
      sets: 3,
      reps: 30,
      restSeconds: 30,
      instructions: 'Run in place bringing knees high, maintain quick pace',
      videoUrl: 'https://www.youtube.com/watch?v=OAJ_J3EZkdY',
    ),
    Exercise(
      id: 'cardio_4',
      name: 'Jump Rope',
      sets: 3,
      reps: 1,
      restSeconds: 60,
      instructions: 'Jump rope for 1-2 minutes, maintain rhythm',
      videoUrl: 'https://www.youtube.com/watch?v=wE4nTx65k4c',
    ),
    Exercise(
      id: 'cardio_5',
      name: 'Box Jumps',
      sets: 3,
      reps: 12,
      restSeconds: 90,
      instructions: 'Jump onto box, land softly, step down',
      videoUrl: 'https://www.youtube.com/watch?v=52rRRa5tY7Q',
    ),
    Exercise(
      id: 'cardio_6',
      name: 'Sprints',
      sets: 5,
      reps: 1,
      restSeconds: 120,
      instructions: 'Sprint at maximum effort for 20-30 seconds',
      videoUrl: 'https://www.youtube.com/watch?v=Tbqz2lfhh6E',
    ),
    Exercise(
      id: 'cardio_7',
      name: 'Battle Ropes',
      sets: 3,
      reps: 1,
      restSeconds: 60,
      instructions: 'Alternate wave motion with ropes for 30 seconds',
      videoUrl: 'https://www.youtube.com/watch?v=if6w4oHlC8k',
    ),
    Exercise(
      id: 'cardio_8',
      name: 'Rowing Machine',
      sets: 3,
      reps: 1,
      restSeconds: 90,
      instructions: 'Row for 1-2 minutes at steady pace',
      videoUrl: 'https://www.youtube.com/watch?v=G8KbtQzsX5Y',
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
      videoUrl: 'https://www.youtube.com/watch?v=7v3tM5kfpLk',
    ),
    Exercise(
      id: 'fullbody_2',
      name: 'Thrusters',
      sets: 4,
      reps: 10,
      restSeconds: 90,
      instructions: 'Squat with dumbbells, stand and press overhead in one motion',
      videoUrl: 'https://www.youtube.com/watch?v=5r0S_9vQwn0',
    ),
    Exercise(
      id: 'fullbody_3',
      name: 'Man Makers',
      sets: 3,
      reps: 8,
      restSeconds: 120,
      instructions: 'Burpee with dumbbells, add row at bottom, press at top',
      videoUrl: 'https://www.youtube.com/watch?v=ErG94t1nIs4',
    ),
    Exercise(
      id: 'fullbody_4',
      name: 'Turkish Get-Up',
      sets: 3,
      reps: 5,
      restSeconds: 90,
      instructions: 'Complex movement from lying to standing with weight overhead',
      videoUrl: 'https://www.youtube.com/watch?v=0O8pI5QNYB0',
    ),
    Exercise(
      id: 'fullbody_5',
      name: 'Kettlebell Swings',
      sets: 4,
      reps: 20,
      restSeconds: 60,
      instructions: 'Hip hinge, swing kettlebell to shoulder height, control descent',
      videoUrl: 'https://www.youtube.com/watch?v=ysLq2Yv2Y_4',
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

  // Find exercise by exact name (case insensitive)
  static Exercise? findExerciseByName(String name) {
    final allExercises = getAllExercises();
    try {
      return allExercises.firstWhere(
        (exercise) => exercise.name.toLowerCase() == name.toLowerCase()
      );
    } catch (e) {
      return null;
    }
  }
}
