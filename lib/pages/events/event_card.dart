import 'package:flutter/material.dart';
import 'event_detail.dart';

class EventCard extends StatelessWidget {
  final String title;
  final String description;
  final String imageUrl;
  final String startTime;
  final String endTime;
  final String location;
  final bool isAdmin;
  final VoidCallback onEdit;
  final VoidCallback onDelete;

  EventCard({
    required this.title,
    required this.description,
    required this.imageUrl,
    required this.startTime,
    required this.endTime,
    required this.location,
    required this.isAdmin,
    required this.onEdit,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      child: ListTile(
        leading:
            Image.network(imageUrl, width: 50, height: 50, fit: BoxFit.cover),
        title: Text(title),
        subtitle: Text(description),
        trailing: isAdmin
            ? Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  IconButton(
                    icon: Icon(Icons.edit),
                    onPressed: onEdit,
                  ),
                  IconButton(
                    icon: Icon(Icons.delete),
                    onPressed: onDelete,
                  ),
                ],
              )
            : null,
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => EventDetailPage(
                title: title,
                description: description,
                startTime: startTime,
                endTime: endTime,
                imageUrl: imageUrl,
                location: location,
              ),
            ),
          );
        },
      ),
    );
  }
}
