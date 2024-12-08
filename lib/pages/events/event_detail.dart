import 'package:flutter/material.dart';

class EventDetail extends StatelessWidget {
  final Event event;

  EventDetail({required this.event});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(event.name),
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Image.network(
              event.imageUrl,
              height: 250,
              width: double.infinity,
              fit: BoxFit.cover,
            ),
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Text(
                event.name,
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              child: Text(
                event.date,
                style: TextStyle(
                  fontSize: 16,
                  color: Colors.grey[600],
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Text(
                event.description,
                style: TextStyle(
                  fontSize: 16,
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              child: Text(
                "Location: ${event.location}",
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            Padding(
              padding:
                  const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
              child: Text(
                "Speakers: ${event.speakers.join(", ")}",
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: ElevatedButton(
                onPressed: () {
                  // Logic to register or show interest
                  print('Registered for ${event.name}');
                },
                child: Text("Register Now"),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class Event {
  final String name;
  final String description;
  final String date;
  final String imageUrl;
  final String location; // New field
  final List<String> speakers; // New field

  Event({
    required this.name,
    required this.description,
    required this.date,
    required this.imageUrl,
    required this.location, // Added location parameter
    required this.speakers, // Added speakers parameter
  });
}
