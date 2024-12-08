import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

// Halaman ini merupakan contoh tampilan forum yang terinspirasi dari layout HTML yang diberikan.
// Di sini kita hanya fokus pada desain antar muka (UI) saja, tanpa adanya fungsi.
// Nantinya fungsi untuk fetch data, search, dll. dapat ditambahkan kemudian.
// Komentar diberikan untuk membantu memahami struktur dan styling.

// Catatan: 
// - Pada contoh ini, kita hanya menggunakan contoh data statis untuk daftar post dan top creators.
// - Pastikan untuk menyesuaikan tema, font, dan style sesuai kebutuhan aplikasi kalian.
// - Gunakan widget ini di main.dart sebagai contoh pengganti home page untuk melihat tampilannya.

class ForumPage extends StatelessWidget {
  const ForumPage({super.key});

  @override
  Widget build(BuildContext context) {
    // Contoh data statis: daftar post forum
    final forumPosts = [
      {
        "id": 1,
        "title": "Flutter State Management: Provider vs Bloc",
        "user": "JohnDoe",
        "profile_picture":
            "https://via.placeholder.com/150", // Gambar placeholder
        "created_at": "2 hours",
        "content":
            "Diskusi tentang pengalaman menggunakan Provider dan Bloc dalam state management di Flutter.",
        "totalLike": 10,
        "totalDislike": 2,
        "comment_count": 5,
      },
      {
        "id": 2,
        "title": "Perbandingan React Native vs Flutter",
        "user": "JaneSmith",
        "profile_picture":
            "https://via.placeholder.com/150", // Gambar placeholder
        "created_at": "5 hours",
        "content":
            "Mari bahas kelebihan dan kekurangan antara React Native dan Flutter.",
        "totalLike": 20,
        "totalDislike": 1,
        "comment_count": 8,
      },
      {
        "id": 3,
        "title": "Membuat UI Responsif di Flutter",
        "user": "DevGuru",
        "profile_picture":
            "https://via.placeholder.com/150", // Gambar placeholder
        "created_at": "1 day",
        "content":
            "Bagaimana cara membuat layout yang responsif untuk berbagai ukuran layar?",
        "totalLike": 15,
        "totalDislike": 0,
        "comment_count": 10,
      },
    ];

    // Contoh data statis: top creators
    final topCreators = [
      {
        "username": "JohnDoe",
        "profile_picture":
            "https://via.placeholder.com/150", // Gambar placeholder
        "total": 30,
      },
      {
        "username": "JaneSmith",
        "profile_picture":
            "https://via.placeholder.com/150", // Gambar placeholder
        "total": 25,
      },
      {
        "username": "DevGuru",
        "profile_picture":
            "https://via.placeholder.com/150", // Gambar placeholder
        "total": 20,
      },
    ];

    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Container(
          // Menggunakan padding agar konten tidak menempel di pinggir layar
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
          child: LayoutBuilder(
            builder: (context, constraints) {
              // Kita akan membuat layout responsive.
              // Jika lebar layar >= 1000px, layout akan menampilkan dua kolom (post di kiri, top creators di kanan).
              // Jika lebar < 1000px, top creators akan ditampilkan di bawah daftar post.

              final isLargeScreen = constraints.maxWidth >= 1000;

              return Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Judul halaman
                  Text(
                    "Community Forum",
                    style: GoogleFonts.catamaran(
                      fontSize: 32,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 20),

                  // Search Bar dan Button "Add Post"
                  Row(
                    children: [
                      // Search Bar sebagai contoh TextField
                      Expanded(
                        flex: isLargeScreen ? 1 : 2,
                        child: TextField(
                          decoration: InputDecoration(
                            hintText: "Search posts ...",
                            prefixIcon: const Icon(Icons.search),
                            contentPadding: const EdgeInsets.all(12),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 16),
                      // Tombol Add Post
                      ElevatedButton.icon(
                        onPressed: () {
                          // Action untuk membuka modal Add Post akan diimplementasikan nanti
                        },
                        icon: const Icon(Icons.add),
                        label: const Text("Add Post"),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.deepPurple,
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(
                              horizontal: 20, vertical: 12),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 24),

                  // Konten utama: daftar post dan top creators
                  Expanded(
                    child: isLargeScreen
                        ? Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              // Bagian daftar post
                              Expanded(
                                flex: 3,
                                child: _buildPostsList(forumPosts),
                              ),
                              const SizedBox(width: 40),
                              // Bagian top creators
                              SizedBox(
                                width: 300,
                                child: _buildTopCreators(topCreators),
                              ),
                            ],
                          )
                        : Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              // Bagian daftar post
                              Expanded(child: _buildPostsList(forumPosts)),
                              const SizedBox(height: 40),
                              // Bagian top creators
                              _buildTopCreators(topCreators),
                            ],
                          ),
                  )
                ],
              );
            },
          ),
        ),
      ),
    );
  }

  // Widget untuk membangun daftar post forum
  Widget _buildPostsList(List<Map<String, dynamic>> forumPosts) {
    return Container(
      // Memberikan overflow scroll jika konten panjang
      padding: const EdgeInsets.only(right: 10),
      child: ListView.builder(
        itemCount: forumPosts.length,
        itemBuilder: (context, index) {
          final post = forumPosts[index];
          return InkWell(
            onTap: () {
              // Fungsi navigasi ke halaman detail post akan diimplementasikan nanti
            },
            child: Container(
              margin: const EdgeInsets.only(bottom: 16),
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.grey[100],
                borderRadius: BorderRadius.circular(12),
                boxShadow: const [
                  BoxShadow(
                    color: Colors.black12,
                    blurRadius: 5,
                    spreadRadius: 2,
                    offset: Offset(0, 3),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Judul post
                  Text(
                    post["title"],
                    style: GoogleFonts.catamaran(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),

                  // Informasi user dan waktu
                  Row(
                    children: [
                      CircleAvatar(
                        backgroundImage:
                            NetworkImage(post["profile_picture"]),
                        radius: 16,
                      ),
                      const SizedBox(width: 8),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            "by ${post["user"]}",
                            style: const TextStyle(fontSize: 14),
                          ),
                          Text(
                            "${post["created_at"]} ago",
                            style: const TextStyle(
                                fontSize: 12, color: Colors.grey),
                          ),
                        ],
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),

                  // Konten post
                  Text(
                    post["content"],
                    style: const TextStyle(fontSize: 14),
                  ),
                  const SizedBox(height: 12),

                  // Info likes, dislikes, dan comments
                  Row(
                    children: [
                      Row(
                        children: [
                          const Icon(Icons.thumb_up, size: 16),
                          const SizedBox(width: 4),
                          Text("${post["totalLike"]}"),
                        ],
                      ),
                      const SizedBox(width: 16),
                      Row(
                        children: [
                          const Icon(Icons.thumb_down, size: 16),
                          const SizedBox(width: 4),
                          Text("${post["totalDislike"]}"),
                        ],
                      ),
                      const SizedBox(width: 16),
                      Row(
                        children: [
                          const Icon(Icons.comment, size: 16),
                          const SizedBox(width: 4),
                          Text("${post["comment_count"]}"),
                        ],
                      ),
                    ],
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  // Widget untuk menampilkan top creators
  Widget _buildTopCreators(List<Map<String, dynamic>> topCreators) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          "Top Creators",
          style: GoogleFonts.catamaran(
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 16),
        Column(
          children: topCreators.map((creator) {
            return Container(
              margin: const EdgeInsets.only(bottom: 12),
              child: Row(
                children: [
                  CircleAvatar(
                    backgroundImage: NetworkImage(creator["profile_picture"]),
                    radius: 20,
                  ),
                  const SizedBox(width: 12),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        creator["username"],
                        style: const TextStyle(fontWeight: FontWeight.w600),
                      ),
                      Text(
                        "${creator["total"]} posts",
                        style: const TextStyle(fontSize: 12, color: Colors.grey),
                      ),
                    ],
                  ),
                ],
              ),
            );
          }).toList(),
        )
      ],
    );
  }
}