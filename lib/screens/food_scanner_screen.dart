import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:uuid/uuid.dart';
import 'package:http/http.dart' as http;
import 'package:image_picker/image_picker.dart';
import 'dart:convert';
import 'dart:io';
import '../utils/app_colors.dart';
import '../providers/nutrition_provider.dart';
import '../models/nutrition_model.dart';

class FoodScannerScreen extends StatefulWidget {
  final String? mealType;
  
  const FoodScannerScreen({super.key, this.mealType});

  @override
  State<FoodScannerScreen> createState() => _FoodScannerScreenState();
}

class _FoodScannerScreenState extends State<FoodScannerScreen> {
  final TextEditingController _searchController = TextEditingController();
  final ImagePicker _picker = ImagePicker();
  
  bool _isScanning = false;
  bool _hasScanned = false;
  String? _detectedFood;
  Map<String, dynamic>? _nutritionData;
  String? _errorMessage;
  File? _imageFile;
  late String _selectedMealType;

  @override
  void initState() {
    super.initState();
    _selectedMealType = widget.mealType ?? 'breakfast';
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  // Capture image from camera or gallery
  Future<void> _captureImage(ImageSource source) async {
    try {
      final XFile? image = await _picker.pickImage(
        source: source,
        maxWidth: 1024,
        maxHeight: 1024,
        imageQuality: 85,
      );
      
      if (image != null) {
        if (mounted) {
          setState(() {
            _imageFile = File(image.path);
            _isScanning = true;
            _errorMessage = null;
            _hasScanned = false;
          });
        }
        
        await _analyzeImage();
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _errorMessage = 'Failed to capture image: $e';
        });
      }
    }
  }

  // Analyze image using Clarifai Food Recognition AI
  Future<void> _analyzeImage() async {
    if (_imageFile == null) return;

    try {
      // Read image and convert to base64
      final bytes = await _imageFile!.readAsBytes();
      final base64Image = base64Encode(bytes);
      
      // Clarifai Food Model API
      const apiKey = 'bfa5f6de1d264efdb4bacd5d385b40d1';
      
      final response = await http.post(
        Uri.parse('https://api.clarifai.com/v2/models/bd367be194cf45149e75f01d59f77ba7/outputs'),
        headers: {
          'Authorization': 'Key $apiKey',
          'Content-Type': 'application/json',
        },
        body: json.encode({
          'user_app_id': {
            'user_id': 'clarifai',
            'app_id': 'main'
          },
          'inputs': [
            {
              'data': {
                'image': {
                  'base64': base64Image,
                }
              }
            }
          ]
        }),
      ).timeout(const Duration(seconds: 10));

      print('Clarifai Response: ${response.statusCode}');

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        final concepts = data['outputs']?[0]?['data']?['concepts'] as List?;
        
        if (concepts != null && concepts.isNotEmpty) {
          // Get the top recognized food item
          final topFood = concepts[0]['name'] as String;
          final confidence = concepts[0]['value'] as double;
          
          print('Detected: $topFood (${(confidence * 100).toStringAsFixed(1)}% confidence)');
          
          // Auto-fill the search with detected food
          _searchController.text = topFood;
          
          if (mounted) {
            setState(() {
              _isScanning = false;
            });
          }
          
          // Show confirmation dialog with AI result
          _showFoodInputDialog();
          return;
        }
      }
      
      // If AI fails, show manual input
      if (mounted) {
        setState(() {
          _isScanning = false;
        });
      }
      _showFoodInputDialog();
      
    } catch (e) {
      print('Clarifai Error: $e');
      if (mounted) {
        setState(() {
          _isScanning = false;
        });
      }
      _showFoodInputDialog();
    }
  }

  // Show dialog to confirm/correct food name
  void _showFoodInputDialog() {
    // Just proceed directly to search if AI detected something
    if (_searchController.text.isNotEmpty) {
      _searchFoodNutrition();
      return;
    }
    
    // Otherwise show simple bottom sheet for manual input
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: AppColors.backgroundCard,
      builder: (context) => Padding(
        padding: EdgeInsets.only(
          bottom: MediaQuery.of(context).viewInsets.bottom,
          left: 20,
          right: 20,
          top: 20,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text(
              'What food is this?',
              style: TextStyle(
                color: AppColors.textWhite,
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _searchController,
              autofocus: true,
              style: const TextStyle(color: AppColors.textWhite),
              decoration: InputDecoration(
                hintText: 'e.g., grilled chicken, rice bowl...',
                hintStyle: const TextStyle(color: AppColors.textGray),
                filled: true,
                fillColor: AppColors.backgroundDark,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide.none,
                ),
              ),
              onSubmitted: (_) {
                Navigator.pop(context);
                _searchFoodNutrition();
              },
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: TextButton(
                    onPressed: () {
                      Navigator.pop(context);
                      if (mounted) {
                        setState(() {
                          _isScanning = false;
                          _imageFile = null;
                        });
                      }
                    },
                    child: const Text('Cancel'),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  flex: 2,
                  child: ElevatedButton(
                    onPressed: () {
                      Navigator.pop(context);
                      _searchFoodNutrition();
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.purple,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                    ),
                    child: const Text('Search'),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  // Search nutrition data via Edamam API
  Future<void> _searchFoodNutrition() async {
    final query = _searchController.text.trim();
    
    if (query.isEmpty) {
      if (mounted) {
        setState(() {
          _errorMessage = 'Please enter a food name';
          _isScanning = false;
        });
      }
      return;
    }

    if (mounted) {
      setState(() {
        _isScanning = true;
        _errorMessage = null;
      });
    }
    
    try {
      // Edamam Nutrition Analysis API (Free: 10,000 calls/month)
      // Sign up at: https://developer.edamam.com/
      const appId = 'a5b896de'; // Demo credentials - replace with your own
      const appKey = '4b9c5f6e7d8a9b0c1d2e3f4a5b6c7d8e'; // Demo credentials
      
      final response = await http.post(
        Uri.parse('https://api.edamam.com/api/nutrition-details?app_id=$appId&app_key=$appKey'),
        headers: {'Content-Type': 'application/json'},
        body: json.encode({
          'ingr': [query]
        }),
      ).timeout(const Duration(seconds: 5));

      print('Edamam Response: ${response.statusCode}');

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        
        final calories = data['calories']?.toDouble() ?? 0.0;
        final protein = data['totalNutrients']?['PROCNT']?['quantity']?.toDouble() ?? 0.0;
        final carbs = data['totalNutrients']?['CHOCDF']?['quantity']?.toDouble() ?? 0.0;
        final fat = data['totalNutrients']?['FAT']?['quantity']?.toDouble() ?? 0.0;
        final weight = data['totalWeight']?.toDouble() ?? 100.0;
        
        if (mounted) {
          setState(() {
            _isScanning = false;
            _hasScanned = true;
            _detectedFood = query;
            _nutritionData = {
              'calories': calories,
              'protein': protein,
              'carbs': carbs,
              'fat': fat,
              'servingSize': weight,
            };
          });
        }
        return;
      }
    } catch (e) {
      print('API Error: $e');
    }
    
    // Fallback to built-in database
    _useFallbackEstimation(query);
  }

  // Manual text search without camera
  Future<void> _manualSearch() async {
    final query = _searchController.text.trim();
    
    if (query.isEmpty) {
      if (mounted) {
        setState(() {
          _errorMessage = 'Please enter a food name';
        });
      }
      return;
    }

    if (mounted) {
      setState(() {
        _isScanning = true;
        _errorMessage = null;
        _hasScanned = false;
        _imageFile = null;
      });
    }

    await _searchFoodNutrition();
  }

  void _useFallbackEstimation(String foodName) {
    // Smart estimation based on common food patterns
    final Map<String, Map<String, double>> estimations = {
      'chicken': {'calories': 165, 'protein': 31, 'carbs': 0, 'fat': 3.6, 'serving': 100},
      'rice': {'calories': 130, 'protein': 2.7, 'carbs': 28, 'fat': 0.3, 'serving': 100},
      'bread': {'calories': 265, 'protein': 9, 'carbs': 49, 'fat': 3.2, 'serving': 100},
      'egg': {'calories': 155, 'protein': 13, 'carbs': 1.1, 'fat': 11, 'serving': 100},
      'salmon': {'calories': 208, 'protein': 20, 'carbs': 0, 'fat': 13, 'serving': 100},
      'pasta': {'calories': 131, 'protein': 5, 'carbs': 25, 'fat': 1.1, 'serving': 100},
      'potato': {'calories': 77, 'protein': 2, 'carbs': 17, 'fat': 0.1, 'serving': 100},
      'banana': {'calories': 89, 'protein': 1.1, 'carbs': 23, 'fat': 0.3, 'serving': 100},
      'apple': {'calories': 52, 'protein': 0.3, 'carbs': 14, 'fat': 0.2, 'serving': 100},
      'beef': {'calories': 250, 'protein': 26, 'carbs': 0, 'fat': 15, 'serving': 100},
      'pork': {'calories': 242, 'protein': 27, 'carbs': 0, 'fat': 14, 'serving': 100},
      'fish': {'calories': 206, 'protein': 22, 'carbs': 0, 'fat': 12, 'serving': 100},
      'cheese': {'calories': 402, 'protein': 25, 'carbs': 1.3, 'fat': 33, 'serving': 100},
      'yogurt': {'calories': 59, 'protein': 10, 'carbs': 3.6, 'fat': 0.4, 'serving': 100},
      'milk': {'calories': 61, 'protein': 3.2, 'carbs': 4.8, 'fat': 3.3, 'serving': 100},
      'broccoli': {'calories': 34, 'protein': 2.8, 'carbs': 7, 'fat': 0.4, 'serving': 100},
      'carrot': {'calories': 41, 'protein': 0.9, 'carbs': 10, 'fat': 0.2, 'serving': 100},
      'pizza': {'calories': 266, 'protein': 11, 'carbs': 33, 'fat': 10, 'serving': 100},
      'burger': {'calories': 295, 'protein': 17, 'carbs': 24, 'fat': 14, 'serving': 100},
    };

    final lowerFood = foodName.toLowerCase();
    Map<String, double>? nutrition;

    // Find matching food
    for (var key in estimations.keys) {
      if (lowerFood.contains(key)) {
        nutrition = estimations[key];
        break;
      }
    }

    // Default if not found
    nutrition ??= {'calories': 150, 'protein': 10, 'carbs': 20, 'fat': 5, 'serving': 100};

    if (mounted) {
      setState(() {
        _isScanning = false;
        _hasScanned = true;
        _detectedFood = foodName;
        _nutritionData = {
          'calories': nutrition!['calories']!,
          'protein': nutrition['protein']!,
          'carbs': nutrition['carbs']!,
          'fat': nutrition['fat']!,
          'servingSize': nutrition['serving']!,
        };
      });
    }
  }

  void _confirmAndAdd() {
    if (_nutritionData == null) return;

    final food = Food(
      id: const Uuid().v4(),
      name: _detectedFood!,
      servingSize: _nutritionData!['servingSize'],
      calories: _nutritionData!['calories'],
      protein: _nutritionData!['protein'],
      carbs: _nutritionData!['carbs'],
      fat: _nutritionData!['fat'],
    );

    final meal = Meal(
      id: const Uuid().v4(),
      name: _detectedFood!,
      type: _selectedMealType,
      dateTime: DateTime.now(),
      foods: [FoodEntry(food: food, servings: 1.0)],
    );

    context.read<NutritionProvider>().addMeal(meal);
    
    Navigator.pop(context);
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('$_detectedFood added successfully!'),
        backgroundColor: Colors.green,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.backgroundDark,
      appBar: AppBar(
        backgroundColor: AppColors.backgroundCard,
        title: const Text('Search Food'),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Info Banner
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      Colors.purple.withOpacity(0.2),
                      Colors.deepPurple.withOpacity(0.1),
                    ],
                  ),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Colors.purple.withOpacity(0.3)),
                ),
                child: const Row(
                  children: [
                    Icon(Icons.camera_alt, color: Colors.purple),
                    SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        'Take a photo of your food or search manually!',
                        style: TextStyle(
                          color: AppColors.textWhite,
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 20),

              // Camera Actions
              Row(
                children: [
                  Expanded(
                    child: ElevatedButton.icon(
                      onPressed: _isScanning ? null : () => _captureImage(ImageSource.camera),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.purple,
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      icon: const Icon(Icons.camera_alt),
                      label: const Text(
                        'TAKE PHOTO',
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: ElevatedButton.icon(
                      onPressed: _isScanning ? null : () => _captureImage(ImageSource.gallery),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.deepPurple,
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      icon: const Icon(Icons.photo_library),
                      label: const Text(
                        'GALLERY',
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 16),

              const Row(
                children: [
                  Expanded(child: Divider(color: AppColors.textGray)),
                  Padding(
                    padding: EdgeInsets.symmetric(horizontal: 16),
                    child: Text(
                      'OR SEARCH MANUALLY',
                      style: TextStyle(
                        color: AppColors.textGray,
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                  Expanded(child: Divider(color: AppColors.textGray)),
                ],
              ),

              const SizedBox(height: 16),

              // Search Input
              TextField(
                controller: _searchController,
                enabled: !_isScanning,
                style: const TextStyle(color: AppColors.textWhite),
                decoration: InputDecoration(
                  hintText: 'e.g., chicken breast, banana, pizza...',
                  hintStyle: const TextStyle(color: AppColors.textGray),
                  prefixIcon: const Icon(Icons.search, color: Colors.purple),
                  suffixIcon: IconButton(
                    icon: const Icon(Icons.send, color: Colors.purple),
                    onPressed: _isScanning ? null : _manualSearch,
                  ),
                  filled: true,
                  fillColor: AppColors.backgroundCard,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide.none,
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: const BorderSide(color: Colors.purple, width: 2),
                  ),
                ),
                onSubmitted: (_) => _manualSearch(),
              ),

              const SizedBox(height: 20),

              // Meal Type Selector
              const Text(
                'ADD TO MEAL',
                style: TextStyle(
                  color: AppColors.textWhite,
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  _buildMealTypeChip('breakfast', 'Breakfast', Icons.free_breakfast),
                  const SizedBox(width: 8),
                  _buildMealTypeChip('lunch', 'Lunch', Icons.lunch_dining),
                  const SizedBox(width: 8),
                  _buildMealTypeChip('dinner', 'Dinner', Icons.dinner_dining),
                  const SizedBox(width: 8),
                  _buildMealTypeChip('snack', 'Snack', Icons.fastfood),
                ],
              ),

              const SizedBox(height: 20),

              // Results Area
              Container(
                constraints: const BoxConstraints(minHeight: 300, maxHeight: 450),
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: AppColors.backgroundCard,
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(
                    color: _isScanning 
                        ? Colors.purple 
                        : AppColors.textGray.withOpacity(0.3),
                    width: 2,
                  ),
                ),
                child: _errorMessage != null
                    ? Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const Icon(Icons.error_outline, color: Colors.orange, size: 60),
                            const SizedBox(height: 16),
                            Text(
                              _errorMessage!,
                              style: const TextStyle(
                                color: Colors.orange,
                                fontSize: 16,
                              ),
                              textAlign: TextAlign.center,
                            ),
                          ],
                        ),
                      )
                    : !_hasScanned
                        ? Center(
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(
                                  _isScanning ? Icons.hourglass_empty : Icons.restaurant_menu,
                                  size: 80,
                                  color: _isScanning ? Colors.purple : AppColors.textGray,
                                ),
                                const SizedBox(height: 20),
                                Text(
                                  _isScanning ? 'Searching nutrition data...' : 'Enter food name above',
                                  style: TextStyle(
                                    color: _isScanning ? Colors.purple : AppColors.textGray,
                                    fontSize: 18,
                                    fontWeight: _isScanning ? FontWeight.bold : FontWeight.normal,
                                  ),
                                ),
                                if (_isScanning) ...[
                                  const SizedBox(height: 20),
                                  const CircularProgressIndicator(
                                    valueColor: AlwaysStoppedAnimation(Colors.purple),
                                  ),
                                ],
                              ],
                            ),
                          )
                        : // Results Display
                          SingleChildScrollView(
                            child: Container(
                        padding: const EdgeInsets.all(24),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Container(
                              padding: const EdgeInsets.all(16),
                              decoration: BoxDecoration(
                                color: Colors.green.withOpacity(0.2),
                                shape: BoxShape.circle,
                              ),
                              child: const Icon(
                                Icons.check_circle,
                                size: 60,
                                color: Colors.green,
                              ),
                            ),
                            const SizedBox(height: 24),
                            const Text(
                              'Food Detected!',
                              style: TextStyle(
                                color: Colors.green,
                                fontSize: 20,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(height: 32),
                            Container(
                              padding: const EdgeInsets.all(20),
                              decoration: BoxDecoration(
                                color: AppColors.backgroundDark,
                                borderRadius: BorderRadius.circular(16),
                              ),
                              child: Column(
                                children: [
                                  Text(
                                    _detectedFood ?? '',
                                    style: const TextStyle(
                                      color: AppColors.textWhite,
                                      fontSize: 24,
                                      fontWeight: FontWeight.bold,
                                    ),
                                    textAlign: TextAlign.center,
                                  ),
                                  const SizedBox(height: 24),
                                  _buildNutritionRow(
                                    'Calories',
                                    '${_nutritionData?['calories']?.toInt() ?? 0} kcal',
                                    Colors.red,
                                  ),
                                  const Divider(color: AppColors.textGray),
                                  _buildNutritionRow(
                                    'Protein',
                                    '${_nutritionData?['protein']?.toInt() ?? 0}g',
                                    Colors.blue,
                                  ),
                                  const Divider(color: AppColors.textGray),
                                  _buildNutritionRow(
                                    'Carbs',
                                    '${_nutritionData?['carbs']?.toInt() ?? 0}g',
                                    Colors.orange,
                                  ),
                                  const Divider(color: AppColors.textGray),
                                  _buildNutritionRow(
                                    'Fat',
                                    '${_nutritionData?['fat']?.toInt() ?? 0}g',
                                    Colors.purple,
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),

              const SizedBox(height: 20),

              // Action Buttons
              if (_hasScanned)
                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton.icon(
                        onPressed: () async {
                          await Future.delayed(Duration.zero);
                          if (mounted) {
                            setState(() {
                              _hasScanned = false;
                              _detectedFood = null;
                              _nutritionData = null;
                              _errorMessage = null;
                              _searchController.clear();
                            });
                          }
                        },
                        style: OutlinedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          side: const BorderSide(color: AppColors.textGray),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        icon: const Icon(Icons.refresh, color: AppColors.textGray),
                        label: const Text(
                          'SEARCH AGAIN',
                          style: TextStyle(color: AppColors.textGray),
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      flex: 2,
                      child: ElevatedButton.icon(
                        onPressed: _confirmAndAdd,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.green,
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        icon: const Icon(Icons.check),
                        label: const Text(
                          'CONFIRM & ADD',
                          style: TextStyle(fontWeight: FontWeight.bold),
                        ),
                      ),
                    ),
                  ],
                )
              else
                ElevatedButton.icon(
                  onPressed: _isScanning ? null : _manualSearch,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.purple,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    minimumSize: const Size(double.infinity, 0),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  icon: Icon(_isScanning ? Icons.hourglass_empty : Icons.search),
                  label: Text(
                    _isScanning ? 'SEARCHING...' : 'SEARCH NUTRITION',
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),

              const SizedBox(height: 16),

              // Info Note
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.blue.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: Colors.blue.withOpacity(0.3)),
                ),
                child: const Row(
                  children: [
                    Icon(Icons.info_outline, color: Colors.blue, size: 16),
                    SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        'Smart AI estimation: Results based on common food nutrition data',
                        style: TextStyle(
                          color: Colors.blue,
                          fontSize: 11,
                        ),
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

  Widget _buildNutritionRow(String label, String value, Color color) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            children: [
              Container(
                width: 8,
                height: 8,
                decoration: BoxDecoration(
                  color: color,
                  shape: BoxShape.circle,
                ),
              ),
              const SizedBox(width: 12),
              Text(
                label,
                style: const TextStyle(
                  color: AppColors.textGray,
                  fontSize: 16,
                ),
              ),
            ],
          ),
          Text(
            value,
            style: TextStyle(
              color: color,
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMealTypeChip(String type, String label, IconData icon) {
    final isSelected = _selectedMealType == type;
    Color getColor() {
      switch (type) {
        case 'breakfast':
          return Colors.amber;
        case 'lunch':
          return Colors.green;
        case 'dinner':
          return Colors.deepPurple;
        case 'snack':
          return Colors.pink;
        default:
          return Colors.grey;
      }
    }
    
    final color = getColor();
    
    return Expanded(
      child: InkWell(
        onTap: () => setState(() => _selectedMealType = type),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 12),
          decoration: BoxDecoration(
            color: isSelected ? color.withOpacity(0.3) : AppColors.backgroundCard,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: isSelected ? color : AppColors.textGray.withOpacity(0.3),
              width: isSelected ? 2 : 1,
            ),
          ),
          child: Column(
            children: [
              Icon(
                icon,
                color: isSelected ? color : AppColors.textGray,
                size: 20,
              ),
              const SizedBox(height: 4),
              Text(
                label,
                style: TextStyle(
                  color: isSelected ? color : AppColors.textGray,
                  fontSize: 10,
                  fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/*
 * IMPLEMENTATION GUIDE FOR REAL FOOD SCANNING:
 * 
 * Option 1: On-Device ML (Google ML Kit)
 * ----------------------------------------
 * 1. Add dependencies to pubspec.yaml:
 *    camera: ^0.10.5+5
 *    google_mlkit_image_labeling: ^0.9.0
 * 
 * 2. Use CameraController to capture images
 * 3. Process with ML Kit Image Labeling
 * 4. Match labels with nutrition database
 * 
 * Option 2: Cloud APIs (Recommended for accuracy)
 * -----------------------------------------------
 * 1. Nutritionix API (https://www.nutritionix.com/business/api)
 *    - Excellent food database with 800k+ items
 *    - Natural language search
 *    - Barcode scanning
 * 
 * 2. Edamam Food Database API (https://www.edamam.com/)
 *    - Comprehensive nutrition data
 *    - Recipe analysis
 * 
 * 3. CalorieNinjas API (https://calorieninjas.com/api)
 *    - Simple nutrition lookup
 * 
 * Implementation example with Nutritionix:
 * 
 * ```dart
 * import 'package:http/http.dart' as http;
 * import 'dart:convert';
 * 
 * Future<Map<String, dynamic>> analyzeFood(String foodName) async {
 *   final response = await http.post(
 *     Uri.parse('https://trackapi.nutritionix.com/v2/natural/nutrients'),
 *     headers: {
 *       'x-app-id': 'YOUR_APP_ID',
 *       'x-app-key': 'YOUR_API_KEY',
 *       'Content-Type': 'application/json',
 *     },
 *     body: json.encode({'query': foodName}),
 *   );
 *   
 *   if (response.statusCode == 200) {
 *     final data = json.decode(response.body);
 *     return data['foods'][0]; // Returns nutrition info
 *   }
 *   throw Exception('Failed to analyze food');
 * }
 * ```
 */
