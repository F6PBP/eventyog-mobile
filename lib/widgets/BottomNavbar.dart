import 'package:eventyog_mobile/pages/auth/profile.dart';
import 'package:eventyog_mobile/pages/forum/forum.dart';
import 'package:eventyog_mobile/pages/friends/friend_list.dart';
import 'package:eventyog_mobile/pages/home/index.dart';
import 'package:eventyog_mobile/pages/events/event_list_page.dart';
import 'package:flutter/material.dart';

class AnimatedBottomNavigationBar extends StatelessWidget {
  final int currentIndex;

  const AnimatedBottomNavigationBar({
    Key? key,
    required this.currentIndex,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final List<IconData> icons = [
      Icons.home,
      Icons.event,
      Icons.forum,
      Icons.people,
      Icons.person,
    ];
    final List<String> labels = [
      'Home',
      'Events',
      'Forum',
      'Friends',
      'Profile',
    ];

    final List<Widget> pages = [
      const HomePage(),
      const EventListPage(),
      const ForumPage(),
      const FriendListPage(),
      ProfilePage(),
    ];

    return BottomNavigationBar(
      type: BottomNavigationBarType.fixed,
      selectedFontSize: 12.0,
      unselectedFontSize: 12.0,
      items: List.generate(icons.length, (index) {
        bool isSelected = currentIndex == index;
        return BottomNavigationBarItem(
          icon: AnimatedContainer(
            duration: const Duration(milliseconds: 300),
            padding: isSelected
                ? const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0)
                : const EdgeInsets.all(0),
            decoration: BoxDecoration(
              color: isSelected
                  ? Colors.deepPurple.withOpacity(0.1)
                  : Colors.transparent,
              borderRadius: BorderRadius.circular(16.0),
            ),
            child: Icon(
              icons[index],
              color: isSelected ? Colors.deepPurple : Colors.grey,
            ),
          ),
          label: labels[index],
        );
      }),
      currentIndex: currentIndex,
      selectedItemColor: Colors.deepPurple,
      unselectedItemColor: Colors.grey,
      onTap: (index) {
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => pages[index]),
        );
      },
    );
  }
}
