import 'package:flutter/material.dart';

class EventSearchBar extends StatefulWidget {
  final Function(String) onSearch;
  final Function(String) onCategoryChanged;
  final String searchQuery;
  final String selectedCategory;

  const EventSearchBar({
    Key? key,
    required this.onSearch,
    required this.onCategoryChanged,
    required this.searchQuery,
    required this.selectedCategory,
  }) : super(key: key);

  @override
  _EventSearchBarState createState() => _EventSearchBarState();
}

class _EventSearchBarState extends State<EventSearchBar> {
  final TextEditingController _searchController = TextEditingController();
  String _selectedCategory = 'ALL';

  final List<Map<String, String>> _categories = [
    {'code': 'ALL', 'name': 'All Categories'},
    {'code': 'OL', 'name': 'Olahraga'},
    {'code': 'SN', 'name': 'Seni'},
    {'code': 'MS', 'name': 'Musik'},
    {'code': 'CP', 'name': 'Cosplay'},
    {'code': 'LG', 'name': 'Lingkungan'},
    {'code': 'VL', 'name': 'Volunteer'},
    {'code': 'AK', 'name': 'Akademis'},
    {'code': 'KL', 'name': 'Kuliner'},
    {'code': 'PW', 'name': 'Pariwisata'},
    {'code': 'FS', 'name': 'Festival'},
    {'code': 'FM', 'name': 'Film'},
    {'code': 'FN', 'name': 'Fashion'},
    {'code': 'LN', 'name': 'Lainnya'},
  ];

  @override
  void initState() {
    super.initState();
    _searchController.text = widget.searchQuery;
    _selectedCategory = widget.selectedCategory;
    _searchController.addListener(() {
      if (_searchController.text.isEmpty) {
        setState(() {
          _selectedCategory = "ALL";
        });
        widget.onSearch(_searchController.text);
      }
    });
  }

  @override
  void didUpdateWidget(EventSearchBar oldWidget) {
    super.didUpdateWidget(oldWidget);
    // Update controller text when searchQuery changes
    if (widget.searchQuery != _searchController.text) {
      _searchController.text = widget.searchQuery;
    }
    if (widget.selectedCategory != _selectedCategory) {
      setState(() {
        _selectedCategory = widget.selectedCategory;
      });
    }
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.2),
            spreadRadius: 1,
            blurRadius: 5,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        children: [
          // Search TextField
          TextField(
            controller: _searchController,
            decoration: InputDecoration(
              hintText: 'Search events...',
              prefixIcon: Icon(Icons.search),
              suffixIcon: _searchController.text.isNotEmpty
                  ? IconButton(
                      icon: Icon(Icons.clear),
                      onPressed: () {
                        _searchController.clear();
                        widget.onSearch('');
                      },
                    )
                  : null,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10),
                borderSide: BorderSide(color: Colors.grey.shade300),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10),
                borderSide: BorderSide(color: Colors.blue),
              ),
              filled: true,
              fillColor: Colors.grey.shade50,
            ),
            onChanged: (value) {
              // Langsung trigger search saat text berubah
              widget.onSearch(value);
            },
          ),
          const SizedBox(height: 12),
          // Category Dropdown
          Container(
            width: double.infinity,
            child: DropdownButtonFormField<String>(
              value: _selectedCategory,
              decoration: InputDecoration(
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                  borderSide: BorderSide(color: Colors.grey.shade300),
                ),
                filled: true,
                fillColor: Colors.grey.shade50,
                contentPadding:
                    EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              ),
              items: _categories.map((category) {
                return DropdownMenuItem<String>(
                  value: category['code'],
                  child: Text(
                    category['name']!,
                    style: const TextStyle(fontSize: 14),
                  ),
                );
              }).toList(),
              onChanged: (value) {
                setState(() {
                  _selectedCategory = value ?? 'ALL';
                });
                widget.onCategoryChanged(value ?? 'ALL');
              },
            ),
          ),
        ],
      ),
    );
  }
}
