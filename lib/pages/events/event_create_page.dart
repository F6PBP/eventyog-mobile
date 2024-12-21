import 'package:dio/dio.dart';
import 'package:eventyog_mobile/const.dart';
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
    setState(() {
      isLoading = true;
    });
    try {
      final request = context.read<CookieRequest>();
      final dio = Dio();

      if (title.isEmpty || category == null || startTime == null) {
        throw Exception('Please fill in all required fields');
      }

      Map<String, dynamic> eventData = {
        'title': title,
        'description': description,
        'start_time': startTime!.toIso8601String(),
        'category': categoryMap[category],
      };

      if (endTime != null) {
        if (endTime!.isBefore(startTime!) ||
            endTime!.isAtSameMomentAs(startTime!)) {
          throw Exception('Event ends before it starts');
        }
        eventData['end_time'] = endTime!.toIso8601String();
      }

      if (imageUrl != null && imageUrl!.isNotEmpty) {
        if (!imageUrl!.toLowerCase().endsWith('.jpg') &&
            !imageUrl!.toLowerCase().endsWith('.jpeg') &&
            !imageUrl!.toLowerCase().endsWith('.png')) {
          throw Exception('Image URL must end with .jpg, .jpeg, or .png');
        }
        eventData['image_urls'] = imageUrl;
      }

      if (location != null && location!.isNotEmpty) {
        eventData['location'] = location;
      }

      final cookies = request.cookies;

      final response = await dio.post(
        '$fetchUrl/api/yogevent/create/',
        data: eventData,
        options: Options(
          headers: {
            'Content-Type': 'application/json',
            'Cookie': cookies,
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
    } on DioException catch (e) {
      String errorMessage;

      if (e.response != null) {
        // Handle specific HTTP status codes
        switch (e.response?.statusCode) {
          case 400:
            errorMessage = e.response?.data['error'] ?? 'Invalid input data';
            break;
          case 405:
            errorMessage = 'Invalid request method';
            break;
          case 500:
            errorMessage = 'Server error occurred';
            break;
          default:
            errorMessage = e.response?.data['error'] ?? 'An error occurred';
        }
      } else if (e.type == DioExceptionType.connectionTimeout) {
        errorMessage = 'Connection timed out';
      } else if (e.type == DioExceptionType.connectionError) {
        errorMessage = 'No internet connection';
      } else {
        errorMessage = 'An unexpected error occurred';
      }
      throw Exception(errorMessage);
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: ${e.toString()}')),
        );
      }
    } finally {
      setState(() {
        isLoading = false;
      });
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
        title: const Text('Create New Event',
            style: TextStyle(color: Colors.white)),
        backgroundColor: Theme.of(context).colorScheme.primary,
      ),
      body: Stack(
        children: [
          Form(
            key: _formKey,
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(16.0),
              child: Card(
                elevation: 2,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(20.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      SectionTitle('Event Details'),
                      const SizedBox(height: 20),
                      _buildTitleField(),
                      const SizedBox(height: 16),
                      _buildDescriptionField(),
                      const SizedBox(height: 24),
                      SectionTitle('Date & Time'),
                      const SizedBox(height: 16),
                      _buildDateTimePicker(true),
                      const SizedBox(height: 12),
                      _buildDateTimePicker(false),
                      const SizedBox(height: 24),
                      SectionTitle('Other Details'),
                      const SizedBox(height: 16),
                      _buildCategoryDropdown(),
                      const SizedBox(height: 16),
                      _buildLocationField(),
                      const SizedBox(height: 16),
                      _buildImageUrlField(),
                      const SizedBox(height: 32),
                      _buildSubmitButton(),
                      const SizedBox(height: 16),
                      Align(
                        alignment: Alignment.centerLeft,
                        child: Text(
                          '* Required fields',
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.grey.shade600,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTitleField() {
    return TextFormField(
      decoration: _fieldDecoration('Title *', 'Enter event title'),
      onChanged: (value) => title = value,
      validator: (value) {
        if (value == null || value.isEmpty) {
          return 'Title is required';
        }
        return null;
      },
    );
  }

  Widget _buildDescriptionField() {
    return TextFormField(
      maxLines: 3,
      decoration: _fieldDecoration('Description *', 'Enter event description'),
      onChanged: (value) => description = value,
      validator: (value) {
        if (value == null || value.isEmpty) {
          return 'Description is required';
        }
        return null;
      },
    );
  }

  InputDecoration _fieldDecoration(String label, String hint) {
    return InputDecoration(
      labelText: label,
      hintText: hint,
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
      ),
      filled: true,
      fillColor: Colors.grey.shade50,
    );
  }

  Widget _buildDateTimePicker(bool isStartTime) {
    return InkWell(
      onTap: () => _selectDateTime(context, isStartTime),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 16.0, horizontal: 12.0),
        decoration: BoxDecoration(
          border: Border.all(color: Colors.grey.shade300),
          borderRadius: BorderRadius.circular(8),
          color: Colors.grey.shade50,
        ),
        child: Row(
          children: [
            Icon(Icons.calendar_today, color: Theme.of(context).primaryColor),
            const SizedBox(width: 16),
            Expanded(
              child: isStartTime
                  ? Text(
                      startTime != null
                          ? 'Starts: ${DateFormat('MMM dd, yyyy HH:mm').format(startTime!)}'
                          : 'Select Start Time *',
                      style: TextStyle(fontSize: 16))
                  : Text(
                      endTime != null
                          ? 'Ends: ${DateFormat('MMM dd, yyyy HH:mm').format(endTime!)}'
                          : 'Select End Time (Optional)',
                      style: TextStyle(fontSize: 16)),
            ),
            if (endTime != null && !isStartTime)
              IconButton(
                icon: const Icon(Icons.clear),
                onPressed: () => setState(() => endTime = null),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildCategoryDropdown() {
    return DropdownButtonFormField<String>(
      decoration: _fieldDecoration('Category *', 'Select a category'),
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
    );
  }

  Widget _buildLocationField() {
    return TextFormField(
      decoration:
          _fieldDecoration('Location (Optional)', 'Enter event location'),
      onChanged: (value) =>
          setState(() => location = value.isEmpty ? null : value),
    );
  }

  Widget _buildImageUrlField() {
    return TextFormField(
      decoration: _fieldDecoration(
          'Image URL (Optional)', 'Enter image URL (.jpg, .jpeg, .png)'),
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
    );
  }

  Widget _buildSubmitButton() {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton(
        onPressed: isLoading
            ? null
            : () {
                if (_formKey.currentState!.validate()) {
                  if (startTime == null) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Start time is required')),
                    );
                    return;
                  }
                  createEvent();
                }
              },
        style: ElevatedButton.styleFrom(
          minimumSize: const Size(double.infinity, 50),
          backgroundColor: Theme.of(context).colorScheme.primary,
          padding: const EdgeInsets.symmetric(vertical: 16.0),
        ),
        child: isLoading
            ? const CircularProgressIndicator(color: Colors.white)
            : const Text(
                '+ Create Event',
                style: TextStyle(fontSize: 16, color: Colors.white),
              ),
      ),
    );
  }
}

class SectionTitle extends StatelessWidget {
  final String text;
  const SectionTitle(this.text, {Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Text(
      text,
      style: TextStyle(
        fontSize: 15,
        fontWeight: FontWeight.bold,
        color: Theme.of(context).primaryColor,
      ),
    );
  }
}
