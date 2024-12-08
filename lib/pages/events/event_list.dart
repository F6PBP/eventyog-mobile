import 'package:flutter/material.dart';

class EventList extends StatelessWidget {
  final List<Event> events = [
    Event(
      name: "Music Festival",
      description: "Experience live music like never before.",
      date: "10 December 2024",
      imageUrl: "https://example.com/music-festival.jpg",
    ),
    Event(
      name: "Art Exhibition",
      description: "Explore stunning artworks from renowned artists.",
      date: "15 December 2024",
      imageUrl: "https://example.com/art-exhibition.jpg",
    ),
    Event(
      name: "Tech Conference",
      description: "Join us for an insightful tech discussion.",
      date: "20 December 2024",
      imageUrl: "https://example.com/tech-conference.jpg",
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Event List"),
      ),
      body: ListView.builder(
        itemCount: events.length,
        itemBuilder: (context, index) {
          final event = events[index];
          return Card(
            margin: EdgeInsets.all(10),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Image.network(
                  event.imageUrl,
                  height: 200,
                  width: double.infinity,
                  fit: BoxFit.cover,
                ),
                Padding(
                  padding: const EdgeInsets.all(10.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        event.name,
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      SizedBox(height: 5),
                      Text(
                        event.date,
                        style: TextStyle(
                          color: Colors.grey[600],
                        ),
                      ),
                      SizedBox(height: 10),
                      Text(
                        event.description,
                        style: TextStyle(
                          fontSize: 14,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}

class Event {
  final String name;
  final String description;
  final String date;
  final String imageUrl;

  Event({
    required this.name,
    required this.description,
    required this.date,
    required this.imageUrl,
  });
}

void main() {
  runApp(MaterialApp(
    debugShowCheckedModeBanner: false,
    home: EventList(),
  ));
}
