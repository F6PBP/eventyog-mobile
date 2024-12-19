import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:pbp_django_auth/pbp_django_auth.dart';
import 'package:provider/provider.dart';
import 'rating_page.dart';
import 'event.dart';

class EventDetailPage extends StatefulWidget {
  final Event event;

  EventDetailPage({required this.event});

  @override
  _EventDetailPageState createState() => _EventDetailPageState();
}

class _EventDetailPageState extends State<EventDetailPage> {
  double _averageRating = 0.0;
  List<dynamic> _ratings = [];
  bool _isLoadingRatings = true;
  bool _isLoadingTickets = true;
  List<dynamic> _ticketPrices = [];
  bool _hasUserTicket = false;
  bool _hasUserRated = false;
  Map<String, dynamic>? _userTicket;

  @override
  void initState() {
    super.initState();
    _initializeData();
  }

  Future<void> _initializeData() async {
    try {
      await Future.wait([
        _fetchRatings(),
        _fetchTickets(),
        _fetchUserTicketStatus(),
      ]);
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Text('Error loading data. Please try again.'),
            action: SnackBarAction(
              label: 'Retry',
              onPressed: () => _initializeData(),
            ),
          ),
        );
      }
    }
  }

  String _formatDateTime(DateTime? dateTime) {
    if (dateTime == null) {
      return 'Not specified';
    }
    return DateFormat('dd MMM yyyy, HH:mm').format(dateTime);
  }

  Widget _buildInfoRow(IconData icon, String text) {
    return Row(
      children: [
        Icon(icon, size: 20, color: Colors.grey),
        const SizedBox(width: 8),
        Expanded(
          child: Text(text, style: TextStyle(fontSize: 16)),
        ),
      ],
    );
  }

  Future<void> _fetchRatings() async {
    final request = context.read<CookieRequest>();
    try {
      final response = await request
          .get('http://127.0.0.1:8000/api/yogevent/rate/${widget.event.pk}/');

      if (mounted) {
        setState(() {
          _isLoadingRatings = false;
          _averageRating = (response['average_rating'] ?? 0).toDouble();
          _ratings = response['ratings'] ?? [];
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isLoadingRatings = false);
      }
    }
  }

  void _navigateToRatingPage() async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => RatingPage(
          eventTitle: widget.event.fields.title,
          event_id: widget.event.pk,
        ),
      ),
    );

    if (result != null) {
      await _fetchRatings();
      await _fetchUserTicketStatus();
    }
  }

  Future<void> _fetchTickets() async {
    final request = context.read<CookieRequest>();

    try {
      final response = await request.get(
          'http://127.0.0.1:8000/api/yogevent/tickets/${widget.event.pk}/');

      if (mounted) {
        setState(() {
          _isLoadingTickets = false;
          if (response is Map && response.containsKey('tickets')) {
            _ticketPrices = response['tickets'] ?? [];
          } else {
            _ticketPrices = [];
          }
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isLoadingTickets = false;
          _ticketPrices = [];
        });

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error loading tickets. Please try again later.'),
            action: SnackBarAction(
              label: 'Retry',
              onPressed: () {
                setState(() {
                  _isLoadingTickets = true;
                });
                _fetchTickets();
              },
            ),
          ),
        );
      }
    }
  }

  Future<void> _fetchUserTicketStatus() async {
    final request = context.read<CookieRequest>();
    try {
      final response = await request.get(
          'http://127.0.0.1:8000/api/yogevent/user-ticket/${widget.event.pk}/');
      if (mounted) {
        setState(() {
          _hasUserTicket = response['has_ticket'] ?? false;
          _userTicket = response['ticket'];
          _hasUserRated = response['has_rated'] ?? false;
        });
      }
    } catch (e) {
      print("Error fetching user ticket status: $e");
    }
  }

  Future<void> _addToCart(String ticketId) async {
    final request = context.read<CookieRequest>();

    try {
      final response = await request.post(
        'http://127.0.0.1:8000/api/yogevent/buy-ticket-flutter/',
        {
          'ticket_id': ticketId,
        },
      );

      if (response['status'] == true) {
        showDialog(
          context: context,
          builder: (BuildContext context) {
            return AlertDialog(
              title: Text('Success!'),
              content: Text(
                  response['message'] ?? 'Ticket added to cart successfully!'),
              actions: [
                TextButton(
                  onPressed: () {
                    Navigator.of(context).pop();
                    _fetchUserTicketStatus(); // Refresh status setelah sukses
                  },
                  child: Text('OK'),
                ),
              ],
            );
          },
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
              content:
                  Text(response['message'] ?? 'Failed to add ticket to cart')),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error adding ticket to cart: $e')),
      );
    }
  }

  Future<void> _deleteUserTicket() async {
    final request = context.read<CookieRequest>();
    // Cek apakah ada cart_id di ticket data
    if (_userTicket == null || _userTicket!['cart_id'] == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('No ticket found to delete')),
      );
      return;
    }

    try {
      final response = await request.post(
        'http://127.0.0.1:8000/api/yogevent/delete-user-ticket/',
        {
          'ticket_id': _userTicket!['cart_id'].toString(),
        },
      );

      if (response['status'] == true) {
        setState(() {
          _hasUserTicket = false;
          _userTicket = null;
        });

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
              content:
                  Text(response['message'] ?? 'Ticket deleted successfully')),
        );

        await _fetchUserTicketStatus();
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
              content: Text(response['message'] ?? 'Failed to delete ticket')),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error deleting ticket: $e')),
      );
    }
  }

  Widget _buildTicketSection() {
    if (_isLoadingTickets) {
      return Center(child: CircularProgressIndicator());
    }

    if (_ticketPrices.isEmpty) {
      return Card(
        margin: EdgeInsets.symmetric(vertical: 8),
        child: Padding(
          padding: EdgeInsets.all(16),
          child: Text(
            'Tidak tersedia ticket untuk event ini',
            style: TextStyle(
              color: Colors.grey[600],
              fontSize: 16,
            ),
          ),
        ),
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Available Tickets',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 8),
        ..._ticketPrices
            .map((ticket) => Card(
                  margin: EdgeInsets.symmetric(vertical: 4),
                  child: ListTile(
                    title: Text(ticket['name']),
                    subtitle: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          ticket['price'] == 0
                              ? 'Free'
                              : 'Rp ${NumberFormat('#,##0').format(ticket['price'])}',
                        ),
                        if (_hasUserTicket)
                          const Text(
                            'You already have a ticket for this event',
                            style: TextStyle(
                              color: Colors.blue,
                              fontSize: 12,
                            ),
                          ),
                      ],
                    ),
                    trailing: _hasUserTicket
                        ? Icon(Icons.check_circle, color: Colors.green)
                        : ElevatedButton(
                            onPressed: () =>
                                _addToCart(ticket['id'].toString()),
                            child: Text('Add to Cart'),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.blue,
                              foregroundColor: Colors.white,
                            ),
                          ),
                  ),
                ))
            .toList(),
      ],
    );
  }

  Widget _buildUserTicketSection() {
    if (!_hasUserTicket) return SizedBox.shrink();

    // Cek apakah tiket gratis atau berbayar
    final price = _userTicket?['price'] ?? 0;
    final isFreeTicker = price == 0;

    return Card(
      margin: EdgeInsets.symmetric(vertical: 8),
      child: Padding(
        padding: EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Your Ticket',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            // Tampilkan detail tiket
            Text(
              'Type: ${_userTicket?['name'] ?? 'Standard'}',
              style: TextStyle(fontSize: 16),
            ),
            Text(
              'Price: ${price == 0 ? 'Free' : 'Rp ${NumberFormat('#,##0').format(price)}'}',
              style: TextStyle(fontSize: 16),
            ),
            const SizedBox(height: 16),
            if (isFreeTicker)
              // Button untuk tiket gratis
              ElevatedButton(
                onPressed: _deleteUserTicket,
                child: Text('Delete Ticket'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.red,
                  foregroundColor: Colors.white,
                  minimumSize: Size(double.infinity, 50),
                ),
              )
            else
              // Button untuk tiket berbayar
              ElevatedButton(
                onPressed: () {
                  // Navigate to payment page
                  // Sesuaikan dengan route yang digunakan
                },
                child: Text('Complete Payment'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.green,
                  foregroundColor: Colors.white,
                  minimumSize: Size(double.infinity, 50),
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildReviewsSection() {
    if (_isLoadingRatings) {
      return const Center(child: CircularProgressIndicator());
    }

    bool showRatingButton = _ticketPrices.isNotEmpty;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Rating Summary
        Container(
          padding: const EdgeInsets.symmetric(vertical: 16),
          decoration: BoxDecoration(
            border: Border(
              bottom: BorderSide(color: Colors.grey.shade300),
            ),
          ),
          child: Row(
            children: [
              Expanded(
                child: Column(
                  children: [
                    Text(
                      _averageRating.toStringAsFixed(1),
                      style: const TextStyle(
                        fontSize: 36,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: List.generate(5, (index) {
                        return Icon(
                          index < _averageRating.floor()
                              ? Icons.star
                              : index < _averageRating
                                  ? Icons.star_half
                                  : Icons.star_outline,
                          color: Colors.amber,
                          size: 24,
                        );
                      }),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '${_ratings.length} ${_ratings.length == 1 ? 'review' : 'reviews'}',
                      style: TextStyle(color: Colors.grey),
                    ),
                  ],
                ),
              ),
              // Only show rating button if tickets are available
              if (showRatingButton) ...[
                const SizedBox(width: 16),
                Container(
                  width: 120,
                  child: ElevatedButton(
                    onPressed: () {
                      if (!_hasUserTicket) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: const Text(
                                'Please buy a ticket first to rate this event'),
                            action: SnackBarAction(
                              label: 'View Tickets',
                              onPressed: () {},
                            ),
                          ),
                        );
                        return;
                      }
                      if (_hasUserRated) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                              content:
                                  Text('You have already rated this event')),
                        );
                        return;
                      }
                      _navigateToRatingPage();
                    },
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(
                          vertical: 12, horizontal: 8),
                      backgroundColor: !_hasUserTicket
                          ? Colors.grey[300]
                          : _hasUserRated
                              ? Colors.grey
                              : Colors.blue,
                    ),
                    child: Text(
                      _hasUserRated ? 'Already Rated' : 'Rate Event',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        color: !_hasUserTicket || _hasUserRated
                            ? Colors.grey[700]
                            : Colors.white,
                      ),
                    ),
                  ),
                ),
              ],
            ],
          ),
        ),
        // Reviews List
        if (_ratings.isEmpty)
          const Padding(
            padding: EdgeInsets.all(16),
            child: Center(
              child: Text(
                'No reviews yet. Be the first to review!',
                style: TextStyle(color: Colors.grey),
              ),
            ),
          )
        else
          // Mengambil review terakhir saja
          Builder(
            builder: (context) {
              final latestRating = _ratings.last; // Mengambil rating terakhir
              return Card(
                margin: EdgeInsets.symmetric(vertical: 8, horizontal: 0),
                elevation: 0,
                child: Padding(
                  padding: EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          CircleAvatar(
                            backgroundColor: Colors.blue.shade100,
                            child: Text(
                              latestRating['username'][0].toUpperCase(),
                              style: TextStyle(
                                color: Colors.blue.shade900,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                          SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  latestRating['username'],
                                  style: const TextStyle(
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                Text(
                                  DateTime.parse(latestRating['created_at'])
                                      .toLocal()
                                      .toString()
                                      .split('.')[0],
                                  style: const TextStyle(
                                    fontSize: 12,
                                    color: Colors.grey,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          Row(
                            children: [
                              Text(
                                latestRating['rating'].toString(),
                                style: TextStyle(fontWeight: FontWeight.bold),
                              ),
                              Icon(Icons.star, color: Colors.amber, size: 16),
                            ],
                          ),
                        ],
                      ),
                      Padding(
                        padding: EdgeInsets.only(left: 48, top: 8),
                        child: Text(latestRating['review']),
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.event.fields.title),
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Event Image
            Container(
              width: double.infinity,
              height: 250, // Ukuran tetap untuk tinggi
              child: widget.event.fields.imageUrls != null &&
                      widget.event.fields.imageUrls!.isNotEmpty
                  ? Image.network(
                      widget.event.fields.imageUrls!,
                      width: double.infinity,
                      height: 250,
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) =>
                          Image.network(
                        "https://media-cldnry.s-nbcnews.com/image/upload/t_fit-760w,f_auto,q_auto:best/rockcms/2024-06/240602-concert-fans-stock-vl-1023a-9b4766.jpg",
                        width: double.infinity,
                        height: 250,
                        fit: BoxFit.cover,
                      ),
                    )
                  : Image.network(
                      "https://media-cldnry.s-nbcnews.com/image/upload/t_fit-760w,f_auto,q_auto:best/rockcms/2024-06/240602-concert-fans-stock-vl-1023a-9b4766.jpg",
                      width: double.infinity,
                      height: 250,
                      fit: BoxFit.cover,
                    ),
            ),

            Padding(
              padding: EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Event Title
                  Text(
                    widget.event.fields.title,
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  SizedBox(height: 16),

                  // Event Details
                  Text(
                    widget.event.fields.description,
                    style: TextStyle(fontSize: 16),
                  ),
                  SizedBox(height: 16),

                  // Event Info
                  _buildInfoRow(Icons.calendar_today,
                      'Start: ${_formatDateTime(widget.event.fields.startTime)}'),
                  SizedBox(height: 8),
                  _buildInfoRow(Icons.calendar_today,
                      'End: ${_formatDateTime(widget.event.fields.endTime)}'),
                  SizedBox(height: 8),
                  _buildInfoRow(Icons.location_on,
                      widget.event.fields.location ?? 'Location not specified'),
                  SizedBox(height: 16),

                  // Ticket Button
                  // Replace the ticket button with the new ticket section
                  _buildTicketSection(),
                  SizedBox(height: 16),
                  _buildUserTicketSection(),
                  SizedBox(height: 16),

                  // Reviews Section Header
                  Text(
                    'Reviews & Ratings',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  SizedBox(height: 16),

                  // Reviews Section
                  _buildReviewsSection(),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
