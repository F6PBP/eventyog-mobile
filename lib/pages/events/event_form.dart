import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class EventFormPage extends StatefulWidget {
  final Map<String, dynamic>? event;

  const EventFormPage({super.key, this.event});

  @override
  State<EventFormPage> createState() => _EventFormPageState();
}

class _EventFormPageState extends State<EventFormPage> {
  final _formKey = GlobalKey<FormState>();
  late String _title;
  late String _description;
  final List<String> _categories = [
    'OLAHRAGA',
    'SENI',
    'MUSIK',
    'COSPLAY',
    'LINGKUNGAN',
    'VOLUNTEER',
    'AKADEMIS',
    'KULINER',
    'PARIWISATA',
    'FESTIVAL',
    'FILM',
    'FASHION',
    'LAINNYA'
  ];
  late DateTime _startTime;
  late DateTime _endTime;
  late String _location;
  late String _imageUrls;
  String? _selectedCategory;
  bool _isEndTimeInvalid = false;

  final TextEditingController _startTimeController = TextEditingController();
  final TextEditingController _endTimeController = TextEditingController();

  @override
  void initState() {
    super.initState();
    if (widget.event != null) {
      _title = widget.event!['title'];
      _description = widget.event!['description'];
      _startTime = DateTime.parse(widget.event!['startTime']);
      _endTime = DateTime.parse(widget.event!['endTime']);
      _location = widget.event!['location'];
      _imageUrls = widget.event!['imageUrl'];
      _selectedCategory = widget.event!['category'];
    } else {
      _title = "";
      _description = "";
      _startTime = DateTime.now();
      _endTime = DateTime.now().add(Duration(hours: 1));
      _location = "";
      _imageUrls = "";
      _selectedCategory = null;
    }
    _startTimeController.text = _formatDateTime(_startTime);
    _endTimeController.text = _formatDateTime(_endTime);
  }

  String _formatDateTime(DateTime dateTime) {
    return DateFormat('yyyy-MM-dd HH:mm').format(dateTime);
  }

  Future<void> _selectDateTime(BuildContext context, bool isStartTime) async {
    final DateTime? pickedDate = await showDatePicker(
      context: context,
      initialDate: isStartTime ? _startTime : _endTime,
      firstDate: DateTime(2000),
      lastDate: DateTime(2101),
    );
    if (pickedDate != null) {
      final TimeOfDay? pickedTime = await showTimePicker(
        context: context,
        initialTime:
            TimeOfDay.fromDateTime(isStartTime ? _startTime : _endTime),
      );
      if (pickedTime != null) {
        setState(() {
          final newDateTime = DateTime(
            pickedDate.year,
            pickedDate.month,
            pickedDate.day,
            pickedTime.hour,
            pickedTime.minute,
          );
          if (isStartTime) {
            _startTime = newDateTime;
            _startTimeController.text = _formatDateTime(newDateTime);
          } else {
            _endTime = newDateTime;
            _endTimeController.text = _formatDateTime(newDateTime);
          }
          _isEndTimeInvalid = _endTime.isBefore(_startTime) ||
              _endTime.isAtSameMomentAs(_startTime);
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Event Form'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: ListView(
            children: <Widget>[
              TextFormField(
                initialValue: _title,
                decoration: InputDecoration(labelText: 'Title'),
                onChanged: (value) {
                  setState(() {
                    _title = value;
                  });
                },
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter a title';
                  }
                  return null;
                },
              ),
              TextFormField(
                initialValue: _description,
                decoration: InputDecoration(labelText: 'Description'),
                onChanged: (value) {
                  setState(() {
                    _description = value;
                  });
                },
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter a description';
                  }
                  return null;
                },
              ),
              TextFormField(
                controller: _startTimeController,
                decoration: InputDecoration(
                  labelText: 'Start Time',
                  suffixIcon: Icon(Icons.calendar_today),
                ),
                readOnly: true,
                onTap: () => _selectDateTime(context, true),
              ),
              TextFormField(
                controller: _endTimeController,
                decoration: InputDecoration(
                  labelText: 'End Time',
                  suffixIcon: Icon(Icons.calendar_today),
                ),
                readOnly: true,
                onTap: () => _selectDateTime(context, false),
              ),
              if (_isEndTimeInvalid)
                Text(
                  'Acara berakhir sebelum dimulai',
                  style: TextStyle(color: Colors.red),
                ),
              DropdownButtonFormField<String>(
                decoration: InputDecoration(labelText: 'Category'),
                value: _selectedCategory,
                items: _categories.map((String category) {
                  return DropdownMenuItem<String>(
                    value: category,
                    child: Text(category),
                  );
                }).toList(),
                onChanged: (String? newValue) {
                  setState(() {
                    _selectedCategory = newValue;
                  });
                },
                validator: (value) =>
                    value == null ? 'Please select a category' : null,
              ),
              TextFormField(
                initialValue: _location,
                decoration: InputDecoration(labelText: 'Location'),
                onChanged: (value) {
                  setState(() {
                    _location = value;
                  });
                },
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter a location';
                  }
                  return null;
                },
              ),
              TextFormField(
                initialValue: _imageUrls,
                decoration: InputDecoration(labelText: 'Image URLs'),
                onChanged: (value) {
                  setState(() {
                    _imageUrls = value;
                  });
                },
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter image URLs';
                  }
                  return null;
                },
              ),
              SizedBox(height: 20),
              ElevatedButton(
                onPressed: () {
                  if (_formKey.currentState!.validate() && !_isEndTimeInvalid) {
                    final updatedEvent = {
                      'title': _title,
                      'description': _description,
                      'imageUrl': _imageUrls,
                      'startTime': _startTime.toIso8601String(),
                      'endTime': _endTime.toIso8601String(),
                      'location': _location,
                      'category': _selectedCategory,
                    };
                    Navigator.pop(context, updatedEvent);
                  }
                },
                child: Text('Submit'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
