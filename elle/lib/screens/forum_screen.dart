import 'package:flutter/material.dart';
import 'package:flutter_staggered_animations/flutter_staggered_animations.dart';
import '../theme/app_theme.dart';
import '../core/models/community.dart';
import '../services/community_service.dart';
import '../widgets/community/forum_post_card.dart';
import '../widgets/community/category_tabs.dart';

class ForumScreen extends StatefulWidget {
  const ForumScreen({Key? key}) : super(key: key);

  @override
  State<ForumScreen> createState() => _ForumScreenState();
}

class _ForumScreenState extends State<ForumScreen>
    with TickerProviderStateMixin {
  late AnimationController _animationController;
  late TabController _tabController;
  
  // Remove instance since CommunityService has static methods
  List<ForumPost> _forumPosts = [];
  List<ForumCategory> _categories = [];
  bool _isLoading = true;
  String _selectedCategory = 'all';

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );
    
    _loadData();
  }

  Future<void> _loadData() async {
    try {
      final posts = await CommunityService.getForumPosts();
      final categories = await CommunityService.getForumCategories();
      
      setState(() {
        _forumPosts = posts;
        _categories = categories;
        _isLoading = false;
      });
      
      _animationController.forward();
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
    }
  }

  List<ForumPost> get filteredPosts {
    if (_selectedCategory == 'all') return _forumPosts;
    return _forumPosts.where((post) => post.category.id == _selectedCategory).toList();
  }

  @override
  void dispose() {
    _animationController.dispose();
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.backgroundColor,
      appBar: AppBar(
        title: Text(
          'Forum & Discussions',
          style: AppTheme.headerStyle.copyWith(fontSize: 20),
        ),
        backgroundColor: AppTheme.backgroundColor,
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.search),
            onPressed: () => _showSearchDialog(),
          ),
          IconButton(
            icon: const Icon(Icons.add),
            onPressed: () => _showCreatePostDialog(),
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : RefreshIndicator(
              onRefresh: _loadData,
              child: Column(
                children: [
                  // Category tabs
                  CategoryTabs(
                    categories: _categories,
                    selectedCategory: _selectedCategory,
                    onCategorySelected: (category) {
                      setState(() {
                        _selectedCategory = category;
                      });
                    },
                  ),
                  
                  // Forum posts list
                  Expanded(
                    child: AnimationLimiter(
                      child: ListView.builder(
                        padding: const EdgeInsets.all(16),
                        itemCount: filteredPosts.length,
                        itemBuilder: (context, index) {
                          return AnimationConfiguration.staggeredList(
                            position: index,
                            duration: const Duration(milliseconds: 375),
                            child: SlideAnimation(
                              verticalOffset: 50.0,
                              child: FadeInAnimation(
                                child: ForumPostCard(
                                  post: filteredPosts[index],
                                  onTap: () => _openPostDetail(filteredPosts[index]),
                                ),
                              ),
                            ),
                          );
                        },
                      ),
                    ),
                  ),
                ],
              ),
            ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showCreatePostDialog(),
        backgroundColor: AppTheme.primaryPink,
        child: const Icon(Icons.add, color: Colors.white),
      ),
    );
  }

  void _openPostDetail(ForumPost post) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => ForumPostDetailScreen(post: post),
      ),
    );
  }

  void _showSearchDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Rechercher', style: AppTheme.subHeaderStyle),
        content: TextField(
          decoration: InputDecoration(
            hintText: 'Rechercher dans le forum...',
            prefixIcon: const Icon(Icons.search),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
            ),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Annuler', style: AppTheme.bodyTextStyle),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context),
            style: AppTheme.primaryButtonStyle,
            child: Text('Rechercher', style: AppTheme.buttonTextStyle),
          ),
        ],
      ),
    );
  }

  void _showCreatePostDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Nouveau post', style: AppTheme.subHeaderStyle),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              decoration: InputDecoration(
                hintText: 'Titre de votre post...',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
            const SizedBox(height: 16),
            TextField(
              maxLines: 4,
              decoration: InputDecoration(
                hintText: 'Partagez votre question ou expérience...',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Annuler', style: AppTheme.bodyTextStyle),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Post publié avec succès!')),
              );
            },
            style: AppTheme.primaryButtonStyle,
            child: Text('Publier', style: AppTheme.buttonTextStyle),
          ),
        ],
      ),
    );
  }
}

class ForumPostDetailScreen extends StatelessWidget {
  final ForumPost post;

  const ForumPostDetailScreen({Key? key, required this.post}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.backgroundColor,
      appBar: AppBar(
        title: Text('Discussion', style: AppTheme.headerStyle.copyWith(fontSize: 20)),
        backgroundColor: AppTheme.backgroundColor,
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Post content
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(20),
              decoration: AppTheme.cardDecoration,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(post.title, style: AppTheme.subHeaderStyle),
                  const SizedBox(height: 12),
                  Text(post.content, style: AppTheme.bodyTextStyle),
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      CircleAvatar(
                        radius: 16,
                        backgroundColor: AppTheme.primaryPink,
                        child: Text(
                          post.author.displayName[0].toUpperCase(),
                          style: AppTheme.captionStyle.copyWith(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Text(post.author.displayName, style: AppTheme.captionStyle),
                      const Spacer(),
                      Icon(Icons.favorite, size: 16, color: AppTheme.primaryPink),
                      const SizedBox(width: 4),
                      Text('${post.likes}', style: AppTheme.captionStyle),
                    ],
                  ),
                ],
              ),
            ),
            
            const SizedBox(height: 24),
            
            // Comments section
            Text(
              'Commentaires (${post.comments})',
              style: AppTheme.subHeaderStyle.copyWith(fontSize: 16),
            ),
            
            const SizedBox(height: 16),
            
            // Sample comments
            ...List.generate(3, (index) => Container(
              margin: const EdgeInsets.only(bottom: 12),
              padding: const EdgeInsets.all(16),
              decoration: AppTheme.cardDecoration,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      CircleAvatar(
                        radius: 12,
                        backgroundColor: AppTheme.lightGray,
                        child: Text('U', style: AppTheme.captionStyle.copyWith(fontSize: 10)),
                      ),
                      const SizedBox(width: 8),
                      Text('Utilisateur ${index + 1}', style: AppTheme.captionStyle),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Merci pour ce partage très utile! Cela m\'a beaucoup aidée.',
                    style: AppTheme.bodyTextStyle,
                  ),
                ],
              ),
            )),
          ],
        ),
      ),
    );
  }
}