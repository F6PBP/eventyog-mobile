import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'rating_page.dart';

class EventDetailPage extends StatefulWidget {
  final String title;
  final String description;
  final String startTime;
  final String endTime;
  final String imageUrl;
  final String location;

  EventDetailPage({
    required this.title,
    required this.description,
    required this.startTime,
    required this.endTime,
    required this.imageUrl,
    required this.location,
  });

  @override
  _EventDetailPageState createState() => _EventDetailPageState();
}

class _EventDetailPageState extends State<EventDetailPage> {
  bool _ticketBought = false;
  double _averageRating = 0.0;

  String _formatDateTime(String dateTime) {
    final date = DateTime.parse(dateTime);
    return DateFormat('yyyy-MM-dd HH:mm').format(date);
  }

  void _buyTicket() {
    setState(() {
      _ticketBought = true;
    });

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Ticket bought successfully')),
    );
  }

  void _navigateToRatingPage() async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => RatingPage(eventTitle: widget.title),
      ),
    );

    if (result != null && result is double) {
      setState(() {
        _averageRating = result;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Image.network(widget.imageUrl),
              SizedBox(height: 8),
              Text('Title: ${widget.title}',
                  style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
              SizedBox(height: 8),
              Text('Description:', style: TextStyle(fontSize: 18)),
              SizedBox(height: 4),
              Text(widget.description, style: TextStyle(fontSize: 16)),
              SizedBox(height: 8),
              Text('Start DateTime: ${_formatDateTime(widget.startTime)}',
                  style: TextStyle(fontSize: 18)),
              SizedBox(height: 8),
              Text('End DateTime: ${_formatDateTime(widget.endTime)}',
                  style: TextStyle(fontSize: 18)),
              SizedBox(height: 8),
              Text('Location: ${widget.location}',
                  style: TextStyle(fontSize: 18)),
              SizedBox(height: 16),
              Text('Average Rating: ${_averageRating.toStringAsFixed(2)} / 5',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
              SizedBox(height: 16),
              ElevatedButton(
                onPressed: _ticketBought ? null : _buyTicket,
                child: Text(_ticketBought ? 'Ticket Bought' : 'Buy Ticket'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: _ticketBought ? Colors.grey : Colors.blue,
                ),
              ),
              SizedBox(height: 16),
              ElevatedButton(
                onPressed: _navigateToRatingPage,
                child: Text('Rate Event'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
