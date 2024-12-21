import 'package:eventyog_mobile/pages/auth/profile.dart';
import 'package:eventyog_mobile/pages/cart/MyCart.dart';
import 'package:eventyog_mobile/pages/events/event_list_page.dart';
import 'package:eventyog_mobile/pages/forum/forum.dart';
import 'package:eventyog_mobile/pages/friends/friend_list.dart';
import 'package:eventyog_mobile/pages/home/index.dart';
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
      MyCartPage()
      // ProfilePage(),
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
                : const EdgeInsets.all(8.0),
            decoration: BoxDecoration(
              color: isSelected
                  ? Theme.of(context).colorScheme.primary.withOpacity(0.1)
                  : Colors.transparent,
              borderRadius: BorderRadius.circular(16.0),
            ),
            child: Icon(
              icons[index],
              color: isSelected
                  ? Theme.of(context).colorScheme.primary
                  : Colors.grey,
              size: isSelected ? 24.0 : 20.0,
            ),
          ),
          label: labels[index],
        );
      }),
      currentIndex: currentIndex,
      selectedItemColor: Theme.of(context).colorScheme.primary,
      unselectedItemColor: Colors.grey,
      onTap: (index) {
        Navigator.pushReplacement(
          context,
          PageRouteBuilder(
            pageBuilder: (context, animation1, animation2) => pages[index],
            transitionDuration: Duration.zero,
            reverseTransitionDuration: Duration.zero,
          ),
        );
      },
    );
  }
}
