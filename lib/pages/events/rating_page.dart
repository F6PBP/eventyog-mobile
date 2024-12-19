import 'package:flutter/material.dart';
import 'package:pbp_django_auth/pbp_django_auth.dart';
import 'package:provider/provider.dart';

class RatingPage extends StatefulWidget {
  final String eventTitle;
  final String event_id;

  RatingPage({
    required this.eventTitle,
    required this.event_id,
  });

  @override
  _RatingPageState createState() => _RatingPageState();
}

class _RatingPageState extends State<RatingPage> {
  final _reviewController = TextEditingController();
  int _selectedRating = 1;
  double _averageRating = 0.0;
  List<dynamic> _userRatings = [];
  bool _hasUserRated = false;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _fetchRatings();
  }

  Future<void> _fetchRatings() async {
    final request = context.read<CookieRequest>();

    try {
      final response = await request
          .get('http://127.0.0.1:8000/api/yogevent/rate/${widget.event_id}/');

      if (mounted) {
        setState(() {
          _isLoading = false;
          _averageRating = (response['average_rating'] ?? 0).toDouble();
          _userRatings = response['ratings'] ?? [];

          // Check if user has already rated and set the values
          if (response['user_rating'] != null) {
            _hasUserRated = true;
            _selectedRating = response['user_rating']['rating'];
            _reviewController.text = response['user_rating']['review'];
          }
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isLoading = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error loading ratings: $e')),
        );
      }
    }
  }

  Future<void> _submitRating() async {
    if (_reviewController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Please write a review')),
      );
      return;
    }

    final request = context.read<CookieRequest>();

    try {
      // Format data as form-data
      Map<String, String> formData = {
        'rating': _selectedRating.toString(),
        'review': _reviewController.text,
      };

      final response = await request.post(
        'http://127.0.0.1:8000/api/yogevent/rate/${widget.event_id}/',
        formData,
      );

      if (response['status'] == 'success') {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(response['message'])),
        );
        Navigator.pop(context, {
          'average_rating': response['average_rating'],
          'last_review': {
            'rating': _selectedRating,
            'review': _reviewController.text,
          }
        });
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
              content: Text(response['error'] ?? 'Failed to submit rating')),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error submitting rating: $e')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return Scaffold(
        appBar: AppBar(title: Text('Rate ${widget.eventTitle}')),
        body: Center(child: CircularProgressIndicator()),
      );
    }

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
              if (_averageRating > 0) ...[
                Text(
                  'Average Rating: ${_averageRating.toStringAsFixed(1)} ⭐',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                SizedBox(height: 16),
              ],
              Text(
                _hasUserRated ? 'Update your rating:' : 'Add your rating:',
                style: TextStyle(fontSize: 16),
              ),
              DropdownButton<int>(
                value: _selectedRating,
                items: [1, 2, 3, 4, 5].map((int value) {
                  return DropdownMenuItem<int>(
                    value: value,
                    child: Text('$value ⭐'),
                  );
                }).toList(),
                onChanged: (newValue) {
                  setState(() {
                    _selectedRating = newValue!;
                  });
                },
              ),
              SizedBox(height: 16),
              TextField(
                controller: _reviewController,
                decoration: InputDecoration(
                  labelText: 'Write your review',
                  border: OutlineInputBorder(),
                ),
                maxLines: 3,
              ),
              SizedBox(height: 16),
              ElevatedButton(
                onPressed: _submitRating,
                child: Text(_hasUserRated ? 'Update Rating' : 'Submit Rating'),
                style: ElevatedButton.styleFrom(
                  minimumSize: Size(double.infinity, 50),
                ),
              ),
              if (_userRatings.isNotEmpty) ...[
                SizedBox(height: 24),
                Text(
                  'All Reviews',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                SizedBox(height: 8),
                ListView.builder(
                  shrinkWrap: true,
                  physics: NeverScrollableScrollPhysics(),
                  itemCount: _userRatings.length,
                  itemBuilder: (context, index) {
                    final rating = _userRatings[index];
                    return Card(
                      child: ListTile(
                        title: Row(
                          children: [
                            Text(rating['username']),
                            SizedBox(width: 8),
                            Text('${rating['rating']} ⭐'),
                          ],
                        ),
                        subtitle: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(rating['review']),
                            Text(
                              'Posted: ${DateTime.parse(rating['created_at']).toLocal().toString().split('.')[0]}',
                              style:
                                  TextStyle(fontSize: 12, color: Colors.grey),
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  @override
  void dispose() {
    _reviewController.dispose();
    super.dispose();
  }
}
