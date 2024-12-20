import 'package:carousel_slider/carousel_slider.dart';
import 'package:eventyog_mobile/pages/home/widgets/event_card.dart';
import 'package:eventyog_mobile/pages/home/widgets/upcoming_card.dart';
import 'package:eventyog_mobile/widgets/BottomNavbar.dart';
import 'package:flutter/material.dart';
import 'package:pbp_django_auth/pbp_django_auth.dart';
import 'package:provider/provider.dart';

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    final request = context.watch<CookieRequest>();

    print(request.jsonData);

    // Example registered events data
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
      backgroundColor: Colors.white,
      bottomNavigationBar: AnimatedBottomNavigationBar(
        currentIndex: 0,
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 10),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 20),
              // Header Section
              Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const SizedBox(height: 30),
                        Text(
                          "Hello, ${request.jsonData['username']}",
                          style: const TextStyle(
                            fontSize: 22,
                            fontWeight: FontWeight.bold,
                            color: Colors.black,
                          ),
                        ),
                        const SizedBox(height: 5),
                        const Text(
                          "Let's explore events around you.",
                          style: TextStyle(
                            fontSize: 16,
                            color: Colors.grey,
                          ),
                        ),
                      ],
                    ),
                  ),
                  CircleAvatar(
                    radius: 25,
                    backgroundColor: Colors.white,
                    backgroundImage: NetworkImage(request.jsonData['imageUrl']),
                  )
                ],
              ),
              const SizedBox(height: 30),

              // Featured Events Carousel
              const Text(
                'Featured Events',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 10),
              CarouselSlider(
                options: CarouselOptions(
                  height: 200.0,
                  autoPlay: true,
                  enlargeCenterPage: true,
                ),
                items: [1, 2, 3, 4, 5].map((i) {
                  return Builder(
                    builder: (BuildContext context) {
                      return Container(
                        width: MediaQuery.of(context).size.width * 0.8,
                        margin: const EdgeInsets.symmetric(horizontal: 5),
                        decoration: BoxDecoration(
                          color: Theme.of(context).primaryColor,
                          borderRadius: BorderRadius.circular(15),
                        ),
                        child: Center(
                          child: Text(
                            'Event $i',
                            style: const TextStyle(
                              fontSize: 16.0,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                          ),
                        ),
                      );
                    },
                  );
                }).toList(),
              ),
              const SizedBox(height: 30),

              // Upcoming Events Section
              const Text(
                'Upcoming Events',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 10),
              GridView.builder(
                shrinkWrap: true,
                gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount:
                      MediaQuery.of(context).size.width < 450 ? 1 : 2,
                  crossAxisSpacing: 15.0,
                  mainAxisSpacing: 15.0,
                  childAspectRatio: 0.7,
                ),
                itemCount: 4,
                itemBuilder: (BuildContext context, int index) {
                  return EventCard(
                    title: "Event ${index + 1}",
                    description: "Discover amazing events happening now!",
                    imageUrl:
                        "https://encrypted-tbn0.gstatic.com/images?q=tbn:ANd9GcTN6Z5fsxwmKCixCZiS1rkUE55tBKpjBBMpyA&s",
                  );
                },
              ),
              const SizedBox(height: 30),

              // Registered Events Section
              const Text(
                'Registered Events',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 10),
              ListView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: registeredEvents.length,
                itemBuilder: (BuildContext context, int index) {
                  final event = registeredEvents[index];
                  return UpcomingCard(
                      title: event['title']!,
                      description: event['description']!,
                      date: event['date']!,
                      time: event['time']!);
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}
