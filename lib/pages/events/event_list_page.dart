import 'package:eventyog_mobile/pages/events/event_card.dart';
import 'package:eventyog_mobile/pages/events/event_seatch_bar.dart';
import 'package:flutter/material.dart';
import 'package:pbp_django_auth/pbp_django_auth.dart';
import 'package:provider/provider.dart';
import 'event.dart';
import 'event_form_page.dart';
import 'event_edit_page.dart';

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
        'http://127.0.0.1:8000/api/yogevent/events/',
      );

      List jsonResponse = response;
      setState(() {
        events = jsonResponse.map((event) => Event.fromJson(event)).toList();
        filteredEvents =
            events; // Inisialisasi filteredEvents dengan semua events
        isLoading = false;
      });
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
        'http://127.0.0.1:8000/api/yogevent/main/',
      );

      setState(() {
        // Pastikan mengambil status admin yang benar dari response
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
        'http://127.0.0.1:8000/api/yogevent/delete/$eventId/',
        {}, // empty body karena kita tidak perlu mengirim data
      );

      if (response['status'] == 'success') {
        setState(() {
          // Update kedua list events dan filteredEvents
          events.removeWhere((event) => event.pk == eventId);
          filteredEvents.removeWhere((event) => event.pk == eventId);
        });

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

  // Di dalam _EventListPageState class
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Event List'),
        actions: [
          if (isAdmin)
            IconButton(
              icon: const Icon(Icons.add),
              onPressed: _navigateToCreateEventPage,
            ),
        ],
      ),
      body: Column(
        children: [
          // Search Bar
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

          // Event Grid
          Expanded(
            child: isLoading
                ? Center(child: CircularProgressIndicator())
                : filteredEvents.isEmpty
                    ? const Center(
                        child: Text(
                          'No events found',
                          style: TextStyle(
                            fontSize: 16,
                            color: Colors.grey,
                          ),
                        ),
                      )
                    : Padding(
                        padding: EdgeInsets.all(8.0),
                        child: GridView.builder(
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
                            return EventCard(
                              event: event,
                              isAdmin: isAdmin,
                              onEdit: _navigateToEditEventPage,
                              onDelete: _showDeleteConfirmation,
                            );
                          },
                        ),
                      ),
          ),
        ],
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
