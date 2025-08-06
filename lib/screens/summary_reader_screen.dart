import 'package:flutter/material.dart';
import '../models/book_models.dart';

class SummaryReaderScreen extends StatefulWidget {
  final InternalBookItem book;

  const SummaryReaderScreen({super.key, required this.book});

  @override
  State<SummaryReaderScreen> createState() => _SummaryReaderScreenState();
}

class _SummaryReaderScreenState extends State<SummaryReaderScreen> {
  bool _isLoading = true;
  String? _introduction;
  String? _finalThoughts;
  List<SummaryChapter> _chapters = [];
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _loadSummary();
  }

  Future<void> _loadSummary() async {
    // TODO: Replace with actual API call to fetch summary
    // For now, using mock data
    await Future.delayed(const Duration(seconds: 1));

    setState(() {
      _isLoading = false;
      _introduction =
          '''
This comprehensive summary provides an in-depth analysis of "${widget.book.title}" by ${widget.book.authors.join(', ')}. The book explores fundamental concepts that have shaped our understanding of the subject matter, presenting complex ideas in an accessible manner while maintaining academic rigor.

Through careful examination of the author's arguments and supporting evidence, this summary distills the key insights and practical applications that readers can take away from the original work. Whether you're approaching this material for the first time or seeking to deepen your existing knowledge, this summary serves as both an introduction and a comprehensive review.
''';

      _chapters = [
        SummaryChapter(
          id: '1',
          name: 'Chapter 1: The Foundation',
          content: '''
The opening chapter establishes the foundational principles that underpin the entire work. The author begins by presenting the core concepts that will be developed throughout the book, setting the stage for the more complex discussions that follow.

Key themes introduced in this chapter include the historical context of the subject matter, the current state of understanding in the field, and the gaps in knowledge that the author seeks to address. This chapter serves as both an introduction for newcomers and a refresher for those already familiar with the basic concepts.

The author's approach is characterized by clear explanations of complex ideas, supported by relevant examples and case studies. This methodical approach ensures that readers from various backgrounds can engage with the material effectively.
''',
          order: 1,
          createdAt: DateTime.now(),
          updatedAt: DateTime.now(),
        ),
        SummaryChapter(
          id: '2',
          name: 'Chapter 2: Core Concepts',
          content: '''
Building upon the foundation established in the first chapter, this section delves deeper into the central concepts that form the backbone of the author's argument. Here, we encounter the theoretical framework that will be applied throughout the remainder of the work.

The chapter explores the relationships between different elements of the subject matter, revealing how seemingly disparate concepts are actually interconnected. This synthesis of ideas provides readers with a more comprehensive understanding of the topic.

Practical applications of these concepts are also discussed, demonstrating how theoretical knowledge can be applied in real-world situations. This balance between theory and practice makes the material more engaging and relevant to readers' everyday experiences.
''',
          order: 2,
          createdAt: DateTime.now(),
          updatedAt: DateTime.now(),
        ),
        SummaryChapter(
          id: '3',
          name: 'Chapter 3: Advanced Applications',
          content: '''
The third chapter represents a significant advancement in complexity, as the author explores more sophisticated applications of the concepts introduced earlier. This section challenges readers to think more critically about the subject matter and consider its broader implications.

Advanced techniques and methodologies are presented, along with detailed explanations of their theoretical underpinnings. The author provides numerous examples to illustrate these concepts, making abstract ideas more concrete and accessible.

This chapter also addresses common misconceptions and potential pitfalls that readers might encounter when applying these concepts. By anticipating and addressing these challenges, the author helps readers develop a more nuanced understanding of the material.
''',
          order: 3,
          createdAt: DateTime.now(),
          updatedAt: DateTime.now(),
        ),
      ];

      _finalThoughts =
          '''
As we conclude our exploration of "${widget.book.title}", it becomes clear that the author has provided not just a collection of facts and theories, but a comprehensive framework for understanding the subject matter. The journey through these chapters has revealed the depth and complexity of the topic while also demonstrating its practical relevance.

The key insights presented throughout this summary offer readers valuable tools for approaching similar subjects in the future. The author's systematic approach to presenting complex information serves as a model for effective communication in any field.

Looking forward, the concepts and methodologies discussed in this work have significant implications for future research and practical applications. The author's contributions to the field will likely influence how we think about and approach these topics for years to come.

This summary serves as both a comprehensive review of the original work and a springboard for further exploration. Readers are encouraged to return to the source material with this enhanced understanding, ready to discover new insights and applications that may not have been apparent on first reading.
''';
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        title: Text('Summary', style: TextStyle(fontWeight: FontWeight.bold)),
        backgroundColor: Colors.white,
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.black),
      ),
      body: _isLoading
          ? const Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  CircularProgressIndicator(),
                  SizedBox(height: 16),
                  Text('Loading summary...'),
                ],
              ),
            )
          : _errorMessage != null
          ? Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.error, size: 64, color: Colors.red[300]),
                  const SizedBox(height: 16),
                  Text(
                    _errorMessage!,
                    style: TextStyle(color: Colors.red[700]),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            )
          : SingleChildScrollView(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Book header
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(12),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.grey.withOpacity(0.1),
                          spreadRadius: 1,
                          blurRadius: 3,
                          offset: const Offset(0, 1),
                        ),
                      ],
                    ),
                    child: Row(
                      children: [
                        // Book cover
                        Container(
                          width: 80,
                          height: 120,
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(8),
                            color: Colors.grey[200],
                          ),
                          child: widget.book.imageUrl != null
                              ? ClipRRect(
                                  borderRadius: BorderRadius.circular(8),
                                  child: Image.network(
                                    widget.book.imageUrl!,
                                    fit: BoxFit.cover,
                                    errorBuilder: (context, error, stackTrace) {
                                      return Container(
                                        decoration: BoxDecoration(
                                          borderRadius: BorderRadius.circular(
                                            8,
                                          ),
                                          color: Colors.grey[300],
                                        ),
                                        child: const Icon(
                                          Icons.book,
                                          size: 40,
                                          color: Colors.grey,
                                        ),
                                      );
                                    },
                                  ),
                                )
                              : Container(
                                  decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(8),
                                    color: Colors.grey[300],
                                  ),
                                  child: const Icon(
                                    Icons.book,
                                    size: 40,
                                    color: Colors.grey,
                                  ),
                                ),
                        ),
                        const SizedBox(width: 16),

                        // Book info
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                widget.book.title,
                                style: const TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              if (widget.book.authors.isNotEmpty) ...[
                                const SizedBox(height: 4),
                                Text(
                                  'by ${widget.book.authors.join(', ')}',
                                  style: TextStyle(
                                    fontSize: 14,
                                    color: Colors.grey[600],
                                  ),
                                ),
                              ],
                              const SizedBox(height: 8),
                              Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 8,
                                  vertical: 4,
                                ),
                                decoration: BoxDecoration(
                                  color: Colors.green[100],
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: Text(
                                  'Summary',
                                  style: TextStyle(
                                    fontSize: 12,
                                    color: Colors.green[700],
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 24),

                  // Introduction
                  if (_introduction != null) ...[
                    Text(
                      'Introduction',
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: Colors.grey[800],
                      ),
                    ),
                    const SizedBox(height: 16),
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(12),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.grey.withOpacity(0.1),
                            spreadRadius: 1,
                            blurRadius: 3,
                            offset: const Offset(0, 1),
                          ),
                        ],
                      ),
                      child: Text(
                        _introduction!,
                        style: TextStyle(
                          fontSize: 16,
                          color: Colors.grey[700],
                          height: 1.6,
                        ),
                      ),
                    ),
                    const SizedBox(height: 24),
                  ],

                  // Chapters
                  Text(
                    'Chapters',
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: Colors.grey[800],
                    ),
                  ),
                  const SizedBox(height: 16),

                  ..._chapters
                      .map(
                        (chapter) => Container(
                          margin: const EdgeInsets.only(bottom: 16),
                          padding: const EdgeInsets.all(20),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(12),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.grey.withOpacity(0.1),
                                spreadRadius: 1,
                                blurRadius: 3,
                                offset: const Offset(0, 1),
                              ),
                            ],
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                chapter.name,
                                style: TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.grey[800],
                                ),
                              ),
                              const SizedBox(height: 16),
                              Text(
                                chapter.content,
                                style: TextStyle(
                                  fontSize: 16,
                                  color: Colors.grey[700],
                                  height: 1.6,
                                ),
                              ),
                            ],
                          ),
                        ),
                      )
                      .toList(),

                  const SizedBox(height: 24),

                  // Final Thoughts
                  if (_finalThoughts != null) ...[
                    Text(
                      'Final Thoughts',
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: Colors.grey[800],
                      ),
                    ),
                    const SizedBox(height: 16),
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(12),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.grey.withOpacity(0.1),
                            spreadRadius: 1,
                            blurRadius: 3,
                            offset: const Offset(0, 1),
                          ),
                        ],
                      ),
                      child: Text(
                        _finalThoughts!,
                        style: TextStyle(
                          fontSize: 16,
                          color: Colors.grey[700],
                          height: 1.6,
                        ),
                      ),
                    ),
                  ],

                  const SizedBox(height: 40),
                ],
              ),
            ),
    );
  }
}

// Mock SummaryChapter class - replace with actual model when API is ready
class SummaryChapter {
  final String id;
  final String name;
  final String content;
  final int order;
  final DateTime createdAt;
  final DateTime updatedAt;

  SummaryChapter({
    required this.id,
    required this.name,
    required this.content,
    required this.order,
    required this.createdAt,
    required this.updatedAt,
  });
}
