import 'package:flutter/material.dart';
import 'package:eventyog_mobile/pages/events/event_card.dart';
import 'package:eventyog_mobile/pages/events/event_form.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class EventListPage extends StatefulWidget {
  final bool isAdmin;

  EventListPage({required this.isAdmin});

  @override
  _EventListPageState createState() => _EventListPageState();
}

class _EventListPageState extends State<EventListPage> {
  List<Map<String, dynamic>> events = [];

  @override
  void initState() {
    super.initState();
    fetchEvents();
  }

  Future<void> fetchEvents() async {
    final response =
        await http.get(Uri.parse('http://your-django-api-url/events/'));

    if (response.statusCode == 200) {
      List jsonResponse = json.decode(response.body);
      setState(() {
        events =
            jsonResponse.map((event) => event as Map<String, dynamic>).toList();
      });
    } else {
      print("a");
      throw Exception('Failed to load events');
    }
  }

  void _addEvent(Map<String, dynamic> newEvent) {
    setState(() {
      events.add(newEvent);
    });
  }

  void _editEvent(int index, Map<String, dynamic> updatedEvent) {
    setState(() {
      events[index] = updatedEvent;
    });
  }

  void _deleteEvent(int index) {
    setState(() {
      events.removeAt(index);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Event List'),
        actions: widget.isAdmin
            ? [
                IconButton(
                  icon: Icon(Icons.add),
                  onPressed: () async {
                    final newEvent = await Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => EventFormPage()),
                    );
                    if (newEvent != null) {
                      _addEvent(newEvent);
                    }
                  },
                ),
              ]
            : null,
      ),
      body: ListView.builder(
        itemCount: events.length,
        itemBuilder: (context, index) {
          final event = events[index];
          return EventCard(
            title: event['title'],
            description: event['description'],
            imageUrl: event['imageUrl'],
            startTime: event['startTime'],
            endTime: event['endTime'],
            location: event['location'],
            isAdmin: widget.isAdmin,
            onEdit: () async {
              final updatedEvent = await Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => EventFormPage(event: event),
                ),
              );
              if (updatedEvent != null) {
                _editEvent(index, updatedEvent);
              }
            },
            onDelete: () {
              _deleteEvent(index);
            },
          );
        },
      ),
    );
  }
}
