import 'package:flutter/material.dart';

class RatingPage extends StatefulWidget {
  final String eventTitle;

  RatingPage({required this.eventTitle});

  @override
  _RatingPageState createState() => _RatingPageState();
}

class _RatingPageState extends State<RatingPage> {
  final _reviewController = TextEditingController();
  int _selectedRating = 1;
  Map<String, dynamic>? _lastRating;
  double _averageRating = 0.0;
  int _ratingCount = 0;
  int _ratingSum = 0;

  void _submitRating() {
    final review = _reviewController.text;

    setState(() {
      _lastRating = {
        'rating': _selectedRating,
        'review': review,
      };
      _ratingSum += _selectedRating;
      _ratingCount += 1;
      _averageRating = _ratingSum / _ratingCount;
      _selectedRating = 1;
      _reviewController.clear();
    });

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Rating submitted successfully')),
    );

    Navigator.pop(context, _averageRating);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Rate ${widget.eventTitle}'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              DropdownButton<int>(
                value: _selectedRating,
                items: [1, 2, 3, 4, 5].map((int value) {
                  return DropdownMenuItem<int>(
                    value: value,
                    child: Text(value.toString()),
                  );
                }).toList(),
                onChanged: (newValue) {
                  setState(() {
                    _selectedRating = newValue!;
                  });
                },
              ),
              TextField(
                controller: _reviewController,
                decoration: InputDecoration(labelText: 'Review'),
              ),
              SizedBox(height: 16),
              ElevatedButton(
                onPressed: _submitRating,
                child: Text('Submit Rating'),
              ),
              SizedBox(height: 16),
              Text('Average Rating: ${_averageRating.toStringAsFixed(2)} / 5',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
              SizedBox(height: 16),
              if (_lastRating != null) ...[
                Text('Last Rating:', style: TextStyle(fontSize: 18)),
                ListTile(
                  title: Text('Rating: ${_lastRating!['rating']}'),
                  subtitle: Text('Review: ${_lastRating!['review']}'),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}
