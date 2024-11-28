// ignore_for_file: use_build_context_synchronously

import 'package:api_app/services/api_services.dart';
import 'package:flutter/material.dart';

class DogScreen extends StatefulWidget {
  const DogScreen({super.key});

  @override
  State<DogScreen> createState() => _DogScreenState();
}

class _DogScreenState extends State<DogScreen> {
  final ApiService apiService = ApiService();
  List<String> _breeds = [];
  List<String> _images = [];
  bool _isLoading = false;
  String _selectedBreed = '';

  @override
  void initState() {
    super.initState();
    _fetchBreeds();
  }

  Future<void> _fetchBreeds() async {
    setState(() => _isLoading = true);
    try {
      final breeds = await apiService.fetchDogBreeds();
      setState(() => _breeds = breeds);
    } catch (error) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('An issue has been detected. Please retry.')),
      );
      debugPrint('Error: $error');
    } finally {
      setState(() => _isLoading = false);
    }
  }

  Future<void> _fetchImages(String breed) async {
    setState(() {
      _isLoading = true;
      _selectedBreed = breed;
    });
    try {
      final images = await apiService.fetchDogImages(breed);
      setState(() => _images = images);
    } catch (error) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('An issue has been detected. Please retry.')),
      );
      debugPrint('Error: $error');
    } finally {
      setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Dog Breeds'),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Dropdown for breed selection
            Text(
              'Select a Dog Breed:',
              style: Theme.of(context).textTheme.headlineSmall?.copyWith(fontSize: 18),
            ),
            const SizedBox(height: 8),
            Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.black),
              ),
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 12),
                child: DropdownButton<String>(
                  value: _selectedBreed.isNotEmpty ? _selectedBreed : null,
                  hint: const Text('Select a breed'),
                  isExpanded: true,
                  underline: const SizedBox(),
                  items: _breeds.map((breed) {
                    return DropdownMenuItem(
                      value: breed,
                      child: Text(breed),
                    );
                  }).toList(),
                  onChanged: (value) {
                    if (value != null) _fetchImages(value);
                  },
                ),
              ),
            ),
            const SizedBox(height: 16),

            // Display dog images or a placeholder text
            Expanded(
              child: _images.isEmpty
                  ? const Center(child: Text('No images available'))
                  : GridView.builder(
                padding: const EdgeInsets.all(8.0),
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  crossAxisSpacing: 8.0,
                  mainAxisSpacing: 8.0,
                ),
                itemCount: _images.length,
                itemBuilder: (context, index) {
                  return Card(
                    elevation: 5,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(12),
                      child: Image.network(
                        _images[index],
                        fit: BoxFit.cover,
                        loadingBuilder: (context, child, loadingProgress) {
                          if (loadingProgress == null) {
                            return child;
                          } else {
                            return Center(
                              child: CircularProgressIndicator(
                                value: loadingProgress.expectedTotalBytes != null
                                    ? loadingProgress.cumulativeBytesLoaded /
                                    (loadingProgress.expectedTotalBytes ?? 1)
                                    : null,
                              ),
                            );
                          }
                        },
                      ),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
