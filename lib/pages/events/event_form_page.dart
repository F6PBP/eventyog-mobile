import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:pbp_django_auth/pbp_django_auth.dart';
import 'package:provider/provider.dart';

class EventFormPage extends StatefulWidget {
  @override
  _EventFormPageState createState() => _EventFormPageState();
}

class _EventFormPageState extends State<EventFormPage> {
  final _formKey = GlobalKey<FormState>();
  String title = '';
  String description = '';
  DateTime? startTime;
  DateTime? endTime; // Boleh null
  String? imageUrl; // Boleh null
  String? location; // Boleh null
  String? category;
  bool isLoading = false;

  final List<String> categories = [
    'Olahraga',
    'Seni',
    'Musik',
    'Cosplay',
    'Lingkungan',
    'Volunteer',
    'Akademis',
    'Kuliner',
    'Pariwisata',
    'Festival',
    'Film',
    'Fashion',
    'Lainnya'
  ];

  final Map<String, String> categoryMap = {
    'Olahraga': 'OL',
    'Seni': 'SN',
    'Musik': 'MS',
    'Cosplay': 'CP',
    'Lingkungan': 'LG',
    'Volunteer': 'VL',
    'Akademis': 'AK',
    'Kuliner': 'KL',
    'Pariwisata': 'PW',
    'Festival': 'FS',
    'Film': 'FM',
    'Fashion': 'FN',
    'Lainnya': 'LN',
  };

  Future<void> createEvent() async {
    try {
      final request = context.read<CookieRequest>();
      final dio = Dio();

      Map<String, dynamic> eventData = {
        'title': title,
        'description': description,
        'start_time': startTime!.toIso8601String(),
        'category': categoryMap[category],
      };

      // Tambahkan end_time jika ada
      if (endTime != null) {
        // Validasi end_time harus setelah start_time
        if (endTime!.isBefore(startTime!)) {
          throw Exception('Event ends before it starts');
        }
        eventData['end_time'] = endTime!.toIso8601String();
      }

      // Validasi dan tambahkan image_urls jika ada
      if (imageUrl != null && imageUrl!.isNotEmpty) {
        if (!imageUrl!.toLowerCase().endsWith('.jpg') &&
            !imageUrl!.toLowerCase().endsWith('.jpeg') &&
            !imageUrl!.toLowerCase().endsWith('.png')) {
          throw Exception('Image URL must end with .jpg, .jpeg, or .png');
        }
        eventData['image_urls'] = imageUrl;
      }

      // Tambahkan location jika ada
      if (location != null && location!.isNotEmpty) {
        eventData['location'] = location;
      }

      // Ambil cookies dari CookieRequest
      final cookies = request.cookies;

      final response = await dio.post(
        'http://10.0.2.2:8000/api/yogevent/create/',
        data: eventData,
        options: Options(
          headers: {
            'Content-Type': 'application/json',
            'Cookie': cookies, // Sertakan cookies untuk autentikasi
            'X-Requested-With': 'XMLHttpRequest'
          },
        ),
      );

      if (response.data['status'] == 'success') {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Event created successfully!')),
          );
          Navigator.pop(context, true);
        }
      } else {
        throw Exception(response.data['error'] ?? 'Failed to create event');
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: ${e.toString()}')),
        );
      }
    }
  }

  Future<void> _selectDateTime(BuildContext context, bool isStartTime) async {
    final DateTime? pickedDate = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(2000),
      lastDate: DateTime(2100),
    );

    if (pickedDate != null) {
      final TimeOfDay? pickedTime = await showTimePicker(
        context: context,
        initialTime: TimeOfDay.now(),
      );

      if (pickedTime != null) {
        final DateTime pickedDateTime = DateTime(
          pickedDate.year,
          pickedDate.month,
          pickedDate.day,
          pickedTime.hour,
          pickedTime.minute,
        );

        setState(() {
          if (isStartTime) {
            startTime = pickedDateTime;
          } else {
            endTime = pickedDateTime;
          }
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Create Event'),
        elevation: 0,
      ),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Theme.of(context).primaryColor.withOpacity(0.05),
              Colors.white,
            ],
          ),
        ),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Form(
            key: _formKey,
            child: SingleChildScrollView(
              child: Card(
                elevation: 0,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(20.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      // Event Details Section
                      const Text(
                        'Event Details',
                        style: TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 20),

                      // Title Field
                      TextFormField(
                        decoration: InputDecoration(
                          labelText: 'Title *',
                          hintText: 'Enter event title',
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                          filled: true,
                          fillColor: Colors.grey.shade50,
                        ),
                        onChanged: (value) => title = value,
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Title is required';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 16),

                      // Description Field
                      TextFormField(
                        maxLines: 3,
                        decoration: InputDecoration(
                          labelText: 'Description *',
                          hintText: 'Enter event description',
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                          filled: true,
                          fillColor: Colors.grey.shade50,
                        ),
                        onChanged: (value) => description = value,
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Description is required';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 24),

                      // Date & Time Section
                      const Text(
                        'Date & Time',
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 16),

                      // Start Time
                      InkWell(
                        onTap: () => _selectDateTime(context, true),
                        child: Container(
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            border: Border.all(color: Colors.grey.shade300),
                            borderRadius: BorderRadius.circular(8),
                            color: Colors.grey.shade50,
                          ),
                          child: Row(
                            children: [
                              Icon(Icons.calendar_today,
                                  color: Theme.of(context).primaryColor),
                              const SizedBox(width: 16),
                              Expanded(
                                child: Text(
                                  startTime != null
                                      ? 'Starts: ${DateFormat('MMM dd, yyyy HH:mm').format(startTime!)}'
                                      : 'Select Start Time *',
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(height: 12),

                      // End Time
                      InkWell(
                        onTap: () => _selectDateTime(context, false),
                        child: Container(
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            border: Border.all(color: Colors.grey.shade300),
                            borderRadius: BorderRadius.circular(8),
                            color: Colors.grey.shade50,
                          ),
                          child: Row(
                            children: [
                              Icon(Icons.calendar_today,
                                  color: Theme.of(context).primaryColor),
                              const SizedBox(width: 16),
                              Expanded(
                                child: Text(
                                  endTime != null
                                      ? 'Ends: ${DateFormat('MMM dd, yyyy HH:mm').format(endTime!)}'
                                      : 'Select End Time (Optional)',
                                ),
                              ),
                              if (endTime != null)
                                IconButton(
                                  icon: const Icon(Icons.clear),
                                  onPressed: () =>
                                      setState(() => endTime = null),
                                ),
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(height: 24),

                      // Event Details Section
                      const Text(
                        'Event Details',
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 16),

                      // Category Dropdown
                      DropdownButtonFormField<String>(
                        decoration: InputDecoration(
                          labelText: 'Category *',
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                          filled: true,
                          fillColor: Colors.grey.shade50,
                        ),
                        value: category,
                        hint: const Text('Select a category'),
                        items: categories.map((String cat) {
                          return DropdownMenuItem<String>(
                            value: cat,
                            child: Text(cat),
                          );
                        }).toList(),
                        onChanged: (value) => setState(() => category = value),
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Category is required';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 16),

                      // Location Field
                      TextFormField(
                        decoration: InputDecoration(
                          labelText: 'Location (Optional)',
                          hintText: 'Enter event location',
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                          filled: true,
                          fillColor: Colors.grey.shade50,
                        ),
                        onChanged: (value) => setState(
                            () => location = value.isEmpty ? null : value),
                      ),
                      const SizedBox(height: 16),

                      // Image URL Field
                      TextFormField(
                        decoration: InputDecoration(
                          labelText: 'Image URL (Optional)',
                          hintText: 'Enter image URL (.jpg, .jpeg, .png)',
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                          filled: true,
                          fillColor: Colors.grey.shade50,
                        ),
                        onChanged: (value) => setState(() => imageUrl = value),
                        validator: (value) {
                          if (value != null && value.isNotEmpty) {
                            if (!(value.toLowerCase().endsWith('.jpg') ||
                                value.toLowerCase().endsWith('.jpeg') ||
                                value.toLowerCase().endsWith('.png'))) {
                              return 'Image URL must end with .jpg, .jpeg, or .png';
                            }
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 24),

                      // Submit Button
                      Container(
                        width: double.infinity,
                        child: Column(
                          children: [
                            ElevatedButton(
                              onPressed: isLoading
                                  ? null
                                  : () {
                                      if (_formKey.currentState!.validate()) {
                                        if (startTime == null) {
                                          ScaffoldMessenger.of(context)
                                              .showSnackBar(
                                            const SnackBar(
                                                content: Text(
                                                    'Start time is required')),
                                          );
                                          return;
                                        }
                                        createEvent();
                                      }
                                    },
                              style: ElevatedButton.styleFrom(
                                padding:
                                    const EdgeInsets.symmetric(vertical: 16),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(8),
                                ),
                              ),
                              child: isLoading
                                  ? const CircularProgressIndicator(
                                      color: Colors.white)
                                  : const Text(
                                      'Create Event',
                                      style: TextStyle(fontSize: 16),
                                    ),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              '* Required fields',
                              style: TextStyle(
                                fontSize: 12,
                                color: Colors.grey.shade600,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
