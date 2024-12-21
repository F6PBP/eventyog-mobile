import 'package:carousel_slider/carousel_slider.dart';
import 'package:eventyog_mobile/const.dart';
import 'package:eventyog_mobile/models/EventModel.dart';
import 'package:eventyog_mobile/pages/cart/MyCart.dart';
import 'package:eventyog_mobile/pages/events/event_list_page.dart';
import 'package:eventyog_mobile/pages/home/widgets/event_card.dart';
import 'package:eventyog_mobile/widgets/BottomNavbar.dart';
import 'package:flutter/material.dart';
import 'package:pbp_django_auth/pbp_django_auth.dart';
import 'package:provider/provider.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  bool isLoading = true;
  List<Event> upcomingEvents = [];

  @override
  void initState() {
    super.initState();
    fetchUpcomingEvents();
  }

  Future<void> fetchUpcomingEvents() async {
    setState(() {
      isLoading = true;
    });

    try {
      final request = context.read<CookieRequest>();
      final response =
          await request.get('$fetchUrl/api/yogevent/upcoming-events/');

      List<dynamic> jsonResponse = response as List<dynamic>;

      setState(() {
        upcomingEvents = jsonResponse
            .map((eventJson) =>
                Event.fromJson(eventJson as Map<String, dynamic>))
            .toList();
        isLoading = false;
      });
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Failed to fetch events. Please try again.'),
          ),
        );
        setState(() {
          isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final request = context.watch<CookieRequest>();
    final theme = Theme.of(context);

    final List<Map<String, String>> registeredEvents = [
      {
        "title": "Music Festival 2024",
        "date": "2024-12-15",
        "time": "18:00",
        "description": "An amazing night of music and fun.",
      },
      {
        "title": "Tech Conference",
        "date": "2024-12-20",
        "time": "10:00",
        "description": "Explore the latest in technology.",
      },
      {
        "title": "Art Expo",
        "date": "2024-12-25",
        "time": "14:00",
        "description": "A showcase of brilliant artworks.",
      },
    ];

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      bottomNavigationBar: const AnimatedBottomNavigationBar(currentIndex: 0),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header Section
              const SizedBox(height: 40),
              Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          "Hello, ${request.jsonData['username']}",
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 5),
                        Text(
                          "Let's explore events around you.",
                          style: TextStyle(
                            fontSize: 14,
                            color: Colors.grey,
                          ),
                        ),
                      ],
                    ),
                  ),
                  CircleAvatar(
                    radius: 25,
                    backgroundImage: NetworkImage(
                      request.jsonData['imageUrl'] ?? '',
                    ),
                  )
                ],
              ),
              const SizedBox(height: 20),

              // Featured Events Carousel
              SectionHeader(
                title: 'Featured Events',
                onTap: () {
                  Navigator.pushReplacement(context,
                      MaterialPageRoute(builder: (context) => EventListPage()));
                },
              ),
              const SizedBox(height: 10),
              CarouselSlider(
                options: CarouselOptions(
                  height: 224.0,
                  autoPlay: true,
                  enlargeCenterPage: true,
                  viewportFraction: 0.85,
                ),
                items: upcomingEvents.take(5).map((event) {
                  return Builder(
                    builder: (BuildContext context) {
                      return EventCard(event: event);
                    },
                  );
                }).toList(),
              ),
              const SizedBox(height: 20),

              // Upcoming Events Section
              SectionHeader(
                title: 'Upcoming Events',
                onTap: () {
                  Navigator.pushReplacement(context,
                      MaterialPageRoute(builder: (context) => EventListPage()));
                },
              ),
              isLoading
                  ? const Center(child: CircularProgressIndicator())
                  : upcomingEvents.isEmpty
                      ? const Center(
                          child: Text(
                            'No events available',
                            style: TextStyle(
                              fontSize: 16,
                              color: Colors.grey,
                            ),
                          ),
                        )
                      : GridView.builder(
                          shrinkWrap: true,
                          physics: const NeverScrollableScrollPhysics(),
                          gridDelegate:
                              const SliverGridDelegateWithFixedCrossAxisCount(
                            crossAxisCount: 2,
                            crossAxisSpacing: 5.0,
                            mainAxisSpacing: 5.0,
                            childAspectRatio: 0.8,
                          ),
                          itemCount: upcomingEvents.length,
                          itemBuilder: (BuildContext context, int index) {
                            return EventCard(event: upcomingEvents[index]);
                          },
                        ),
            ],
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.push(
              context, MaterialPageRoute(builder: (context) => MyCartPage()));
        },
        child: const Icon(Icons.shopping_cart),
      ),
    );
  }
}

class SectionHeader extends StatelessWidget {
  final String title;
  final VoidCallback? onTap;

  const SectionHeader({required this.title, this.onTap, Key? key})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          title,
          style: const TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
        if (onTap != null)
          TextButton(
            onPressed: onTap,
            child: const Text(
              'See All',
              style: TextStyle(color: Colors.blue),
            ),
          ),
      ],
    );
  }
}
