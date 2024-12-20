import 'dart:convert';
import 'package:eventyog_mobile/pages/events/event.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:pbp_django_auth/pbp_django_auth.dart';
import 'package:provider/provider.dart';

class EditEventPage extends StatefulWidget {
  final Event event;

  EditEventPage({required this.event});

  @override
  _EditEventPageState createState() => _EditEventPageState();
}

class _EditEventPageState extends State<EditEventPage> {
  final _formKey = GlobalKey<FormState>();
  late String title;
  late String description;
  DateTime? startTime;
  DateTime? endTime;
  String? imageUrl;
  String? location;
  String? category;

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

  @override
  void initState() {
    super.initState();
    title = widget.event.fields.title;
    description = widget.event.fields.description;
    imageUrl = widget.event.fields.imageUrls;
    location = widget.event.fields.location;

    // Konversi dari kode kategori (SN) ke nama lengkap (Seni)
    String categoryCode = widget.event.fields.category; // misal 'SN'
    category = categoryMap.entries
        .firstWhere((entry) => entry.value == categoryCode,
            orElse: () => MapEntry(categories[0], categoryMap[categories[0]]!))
        .key;

    startTime = widget.event.fields.startTime;
    endTime = widget.event.fields.endTime;
  }

  bool _validateImageUrl(String? url) {
    if (url == null || url.isEmpty) return true;
    return url.toLowerCase().endsWith('.jpg') ||
        url.toLowerCase().endsWith('.jpeg') ||
        url.toLowerCase().endsWith('.png');
  }

  bool _validateDateTime() {
    if (startTime == null) return false;
    if (endTime != null && startTime!.isAfter(endTime!)) return false;
    return true;
  }

  void _showErrorDialog(String message) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Error'),
        content: Text(message),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: Text('OK'),
          ),
        ],
      ),
    );
  }

  Future<void> updateEvent() async {
    if (!_validateImageUrl(imageUrl)) {
      _showErrorDialog(
          'Thumbnail must be a valid image URL (.jpg, .jpeg, .png).');
      return;
    }

    if (title.isEmpty) {
      _showErrorDialog('Title is required');
      return;
    }

    if (category == null) {
      _showErrorDialog('Category is required');
      return;
    }

    if (startTime == null) {
      _showErrorDialog('Start time is required');
      return;
    }

    if (endTime != null && startTime!.isAfter(endTime!)) {
      _showErrorDialog('Event berakhir sebelum dimulai');
      return;
    }
    final formattedStartTime = startTime?.toIso8601String();
    final formattedEndTime = endTime?.toIso8601String();

    Map<String, dynamic> eventData = {
      'title': title,
      'description': description,
      'start_time': formattedStartTime,
      'end_time': formattedEndTime,
      'image_urls': imageUrl,
      'location': location,
      'category': categoryMap[category],
    };

    try {
      final request = context.read<CookieRequest>();

      // Mengirim eventData sebagai json dengan method post dari CookieRequest
      final response = await request.postJson(
          'http://10.0.2.2:8000/api/yogevent/update/${widget.event.pk}/',
          jsonEncode(eventData) // Encode eventData menjadi JSON string
          );

      if (response['status'] == 'success') {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Event updated successfully!')),
        );
        Navigator.pop(context, true);
      } else {
        _showErrorDialog(response['message'] ?? 'Failed to update event');
      }
    } catch (e, stackTrace) {
      _showErrorDialog('Failed to connect to server');
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
        title: const Text('Edit Event'),
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
                        initialValue: title,
                        decoration: InputDecoration(
                          labelText: 'Title *',
                          hintText: 'Enter event title',
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                          filled: true,
                          fillColor: Colors.grey.shade50,
                        ),
                        onChanged: (value) => setState(() => title = value),
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
                        initialValue: description,
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
                        onChanged: (value) =>
                            setState(() => description = value),
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
                        initialValue: location,
                        decoration: InputDecoration(
                          labelText: 'Location (Optional)',
                          hintText: 'Enter event location',
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                          filled: true,
                          fillColor: Colors.grey.shade50,
                        ),
                        onChanged: (value) => setState(() => location = value),
                      ),
                      const SizedBox(height: 16),

                      // Image URL Field
                      TextFormField(
                        initialValue: imageUrl,
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
                            if (!_validateImageUrl(value)) {
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
                              onPressed: () {
                                if (_formKey.currentState!.validate() &&
                                    _validateDateTime()) {
                                  updateEvent();
                                } else if (!_validateDateTime()) {
                                  _showErrorDialog(
                                      'Event end time must be after start time');
                                }
                              },
                              style: ElevatedButton.styleFrom(
                                padding:
                                    const EdgeInsets.symmetric(vertical: 16),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(8),
                                ),
                              ),
                              child: const Text(
                                'Update Event',
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
