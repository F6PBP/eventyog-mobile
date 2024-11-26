import 'package:carousel_slider/carousel_slider.dart';
import 'package:eventyog_mobile/pages/home/widgets/event_card.dart';
import 'package:eventyog_mobile/widgets/BottomNavbar.dart';
import 'package:flutter/material.dart';

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    final List<Widget> _children = [
      const HomePage(),
      const HomePage(),
      const HomePage(),
      const HomePage(),
    ];

    return Scaffold(
      bottomNavigationBar: AnimatedBottomNavigationBar(
        currentIndex: 0,
      ),
      body: Padding(
        padding: EdgeInsets.all(30),
        child: SingleChildScrollView(
          child: Column(
            children: [
              Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Hello, Andrew!'),
                        Text("Let's look for some events!"),
                      ],
                    ),
                  ),
                  CircleAvatar(
                    radius: 20,
                    backgroundImage:
                        NetworkImage('https://example.com/profile_picture.png'),
                  )
                ],
              ),
              SizedBox(height: 20),
              CarouselSlider(
                options: CarouselOptions(height: 300.0),
                items: [1, 2, 3, 4, 5].map((i) {
                  return Builder(
                    builder: (BuildContext context) {
                      return Container(
                          width: MediaQuery.of(context).size.width,
                          decoration: BoxDecoration(color: Colors.amber),
                          child: Text(
                            'text $i',
                            style: TextStyle(fontSize: 16.0),
                          ));
                    },
                  );
                }).toList(),
              ),
              SizedBox(height: 20),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Upcoming Events',
                      style:
                          TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                  GridView.builder(
                    shrinkWrap: true,
                    physics: NeverScrollableScrollPhysics(),
                    gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 1,
                      crossAxisSpacing: 10.0,
                      mainAxisSpacing: 10.0,
                    ),
                    itemCount: 4,
                    itemBuilder: (BuildContext context, int index) {
                      return EventCard(
                        title: "HELLO!",
                        description: "HELLO!",
                        imageUrl:
                            "https://encrypted-tbn0.gstatic.com/images?q=tbn:ANd9GcTN6Z5fsxwmKCixCZiS1rkUE55tBKpjBBMpyA&s",
                      );
                    },
                  )
                ],
              )
            ],
          ),
        ),
      ),
    );
  }
}
