import 'package:eventyog_mobile/pages/events/components/event_card.dart';
import 'package:eventyog_mobile/pages/events/components/event_search_bar.dart';
import 'package:eventyog_mobile/widgets/BottomNavbar.dart';
import 'package:flutter/material.dart';
import 'package:pbp_django_auth/pbp_django_auth.dart';
import 'package:provider/provider.dart';

import '../../models/EventModel.dart';
import 'event_edit_page.dart';
import 'event_create_page.dart';

void main() {
  runApp(const EventApp());
}

class EventApp extends StatelessWidget {
  const EventApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Event List',
      theme: ThemeData(
        useMaterial3: true,
        colorScheme: ColorScheme.fromSwatch(
          primarySwatch: Colors.deepPurple,
        ).copyWith(secondary: Colors.deepPurple[400]),
      ),
      home: const EventListPage(),
    );
  }
}

class EventListPage extends StatefulWidget {
  const EventListPage({Key? key}) : super(key: key);

  @override
  _EventListPageState createState() => _EventListPageState();
}

class _EventListPageState extends State<EventListPage> {
  List<Event> events = [];
  List<Event> filteredEvents = [];
  bool isAdmin = false;
  bool isLoading = true;
  String searchQuery = '';
  String selectedCategory = 'ALL';

  @override
  void initState() {
    super.initState();
    Future.microtask(() async {
      await checkAdmin();
      await fetchEvents();
    });
  }

  Future<void> fetchEvents() async {
    setState(() {
      isLoading = true;
    });

    try {
      final request = context.read<CookieRequest>();
      final response = await request.get(
        'http://10.0.2.2:8000/api/yogevent/events/',
      );

      List jsonResponse = response;
      setState(() {
        events = jsonResponse.map((event) => Event.fromJson(event)).toList();
        filteredEvents = events;
        isLoading = false;
      });
      filterEvents();
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Failed to load events')),
        );
        setState(() {
          isLoading = false;
        });
      }
    }
  }

  void filterEvents() {
    setState(() {
      if (searchQuery.isEmpty && selectedCategory == 'ALL') {
        filteredEvents = events;
      } else {
        filteredEvents = events.where((event) {
          final matchesSearch = searchQuery.isEmpty ||
              event.fields.title
                  .toLowerCase()
                  .contains(searchQuery.toLowerCase());

          final matchesCategory = selectedCategory == 'ALL' ||
              event.fields.category == selectedCategory;

          return matchesSearch && matchesCategory;
        }).toList();
      }
    });
  }

  Future<void> checkAdmin() async {
    try {
      final request = context.read<CookieRequest>();
      final response = await request.get(
        'http://10.0.2.2:8000/api/yogevent/main/',
      );

      setState(() {
        isAdmin = response['is_admin'] ?? false;
      });
    } catch (e) {
      setState(() {
        isAdmin = false;
      });
    }
  }

  Future<void> deleteEvent(String eventId) async {
    try {
      final request = context.read<CookieRequest>();

      final response = await request.post(
        'http://10.0.2.2:8000/api/yogevent/delete/$eventId/',
        {},
      );

      if (response['status'] == 'success') {
        setState(() {
          events.removeWhere((event) => event.pk == eventId);
          filteredEvents.removeWhere((event) => event.pk == eventId);
        });
        filterEvents();

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Event berhasil dihapus!')),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
              content: Text('Gagal menghapus event: ${response['message']}')),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Terjadi kesalahan: $e')),
      );
    }
  }

  Future<void> _navigateToCreateEventPage() async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => EventFormPage()),
    );

    if (result == true) {
      fetchEvents();
    }
  }

  Future<void> _navigateToEditEventPage(Event event) async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => EditEventPage(event: event)),
    );

    if (result == true) {
      fetchEvents();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Event List', style: TextStyle(color: Colors.white)),
        backgroundColor: Theme.of(context).colorScheme.primary,
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _navigateToCreateEventPage,
        tooltip: 'Create Event',
        child: const Icon(Icons.add),
      ),
      bottomNavigationBar: AnimatedBottomNavigationBar(
        currentIndex: 1,
      ),
      body: RefreshIndicator(
        onRefresh: fetchEvents,
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            children: [
              EventSearchBar(
                onSearch: (query) {
                  setState(() {
                    searchQuery = query;
                  });
                  filterEvents();
                },
                onCategoryChanged: (category) {
                  setState(() {
                    selectedCategory = category;
                  });
                  filterEvents();
                },
                searchQuery: searchQuery,
                selectedCategory: selectedCategory,
              ),
              const SizedBox(height: 16.0),
              isLoading
                  ? const CircularProgressIndicator()
                  : filteredEvents.isEmpty
                      ? const Text(
                          'No events found',
                          style: TextStyle(
                            fontSize: 16,
                            color: Colors.grey,
                          ),
                        )
                      : GridView.builder(
                          shrinkWrap: true,
                          gridDelegate:
                              const SliverGridDelegateWithFixedCrossAxisCount(
                            crossAxisCount: 2,
                            mainAxisSpacing: 8,
                            crossAxisSpacing: 8,
                            childAspectRatio: 1,
                          ),
                          itemCount: filteredEvents.length,
                          itemBuilder: (context, index) {
                            final event = filteredEvents[index];
                            return Padding(
                              padding: const EdgeInsets.all(8.0),
                              child: EventCard(
                                event: event,
                                isAdmin: isAdmin,
                                onEdit: _navigateToEditEventPage,
                                onDelete: _showDeleteConfirmation,
                              ),
                            );
                          },
                        ),
            ],
          ),
        ),
      ),
    );
  }

  void _showDeleteConfirmation(Event event) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Event'),
        content: const Text('Are you sure you want to delete this event?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
              deleteEvent(event.pk);
            },
            child: const Text('Delete', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }
}
