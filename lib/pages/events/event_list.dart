import 'package:eventyog_mobile/pages/events/event_detail.dart';
import 'package:flutter/material.dart';
import 'event_card.dart'; // Mengimpor EventCard

class Event {
  final String name;
  final String description;
  final String date;
  final String imageUrl;
  final String location;
  final List<String> speakers;

  Event({
    required this.name,
    required this.description,
    required this.date,
    required this.imageUrl,
    required this.location,
    required this.speakers,
  });
}

class EventList extends StatelessWidget {
  final List<Event> events = [
    Event(
      name: "Music Festival",
      description: "Experience live music like never before.",
      date: "10 December 2024",
      imageUrl: "https://example.com/music-festival.jpg",
      location: "Central Park",
      speakers: ["John Doe", "Jane Smith"],
    ),
    Event(
      name: "Art Exhibition",
      description: "Explore stunning artworks from renowned artists.",
      date: "15 December 2024",
      imageUrl: "https://example.com/art-exhibition.jpg",
      location: "Art Gallery",
      speakers: ["Alice Brown", "Bob White"],
    ),
    Event(
      name: "Tech Conference",
      description: "Join us for an insightful tech discussion.",
      date: "20 December 2024",
      imageUrl: "https://example.com/tech-conference.jpg",
      location: "Tech Hub",
      speakers: ["David Lee", "Chris Green"],
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Event List"),
      ),
      body: ListView.builder(
        itemCount: events.length,
        itemBuilder: (context, index) {
          final event = events[index];
          return EventCard(
            event: event,
            onTap: () {
              // Navigasi ke EventDetail ketika card ditekan
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => EventDetail(event: event),
                ),
              );
            },
          );
        },
      ),
    );
  }
}
