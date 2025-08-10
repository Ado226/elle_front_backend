import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../core/models/community.dart';

class CommunityService {
  static const String _articlesKey = 'community_articles';
  static const String _forumPostsKey = 'forum_posts';
  static const String _forumRepliesKey = 'forum_replies';
  static const String _articleCommentsKey = 'article_comments';
  static const String _likedArticlesKey = 'liked_articles';
  static const String _likedPostsKey = 'liked_posts';
  static const String _bookmarkedArticlesKey = 'bookmarked_articles';

  // Sample current user (in a real app, this would come from authentication)
  static final CommunityUser _currentUser = CommunityUser(
    id: 'current_user',
    username: 'elles_user',
    fullName: 'Utilisatrice Elles',
    role: UserRole.member,
    joinedAt: DateTime.now().subtract(const Duration(days: 30)),
    reputation: 150,
  );

  // Sample expert users
  static final List<CommunityUser> _experts = [
    CommunityUser(
      id: 'expert_1',
      username: 'dr_marie',
      fullName: 'Dr. Marie Ouédraogo',
      role: UserRole.expert,
      expertise: 'Gynécologie',
      joinedAt: DateTime.now().subtract(const Duration(days: 365)),
      reputation: 2500,
      isVerified: true,
    ),
    CommunityUser(
      id: 'expert_2',
      username: 'sage_femme_fatou',
      fullName: 'Fatou Sankara',
      role: UserRole.expert,
      expertise: 'Sage-femme',
      joinedAt: DateTime.now().subtract(const Duration(days: 300)),
      reputation: 1800,
      isVerified: true,
    ),
    CommunityUser(
      id: 'expert_3',
      username: 'psychologue_aminata',
      fullName: 'Aminata Traoré',
      role: UserRole.expert,
      expertise: 'Psychologie',
      joinedAt: DateTime.now().subtract(const Duration(days: 200)),
      reputation: 2100,
      isVerified: true,
    ),
  ];

  // Sample articles data
  static final List<Article> _sampleArticles = [
    Article(
      id: '1',
      title: 'Comprendre votre cycle menstruel',
      content: '''Le cycle menstruel est un processus naturel qui se produit chaque mois chez les femmes en âge de procréer. Il est important de comprendre son fonctionnement pour mieux connaître votre corps.

## Les phases du cycle

### Phase folliculaire (Jours 1-14)
La phase folliculaire commence le premier jour des règles. Pendant cette phase, l'hormone FSH stimule les ovaires pour qu'ils produisent un ovule mature.

### Ovulation (Jour 14 environ)
L'ovulation se produit généralement au milieu du cycle. L'ovule mature est libéré de l'ovaire et peut être fécondé pendant 12 à 24 heures.

### Phase lutéale (Jours 15-28)
Après l'ovulation, la phase lutéale commence. Si l'ovule n'est pas fécondé, les niveaux d'hormones chutent et les règles commencent.

## Signes à surveiller

- Changements dans les pertes vaginales
- Douleurs pelviennes
- Changements d'humeur
- Sensibilité des seins

## Quand consulter un médecin

Il est important de consulter un professionnel de santé si vous remarquez :
- Des règles très irrégulières
- Des douleurs intenses
- Des saignements anormaux
- L'absence de règles pendant plusieurs mois

N'hésitez pas à tenir un journal de votre cycle pour mieux comprendre votre corps et identifier d'éventuelles anomalies.''',
      excerpt: 'Découvrez les différentes phases de votre cycle menstruel et apprenez à reconnaître les signes importants à surveiller.',
      category: ArticleCategory.menstruation,
      author: _experts[0],
      tags: ['cycle', 'menstruation', 'ovulation', 'santé'],
      views: 1250,
      likes: 89,
      commentsCount: 23,
      publishedAt: DateTime.now().subtract(const Duration(days: 7)),
      isFeatured: true,
      isExpertContent: true,
    ),
    Article(
      id: '2',
      title: 'Les méthodes de contraception modernes',
      content: '''Il existe aujourd'hui de nombreuses méthodes de contraception efficaces et sûres. Chaque méthode a ses avantages et ses inconvénients.

## Contraception hormonale

### La pilule contraceptive
La pilule combinée contient des œstrogènes et de la progestérone. Elle est efficace à plus de 99% lorsqu'elle est prise correctement.

### L'implant contraceptif
L'implant est un petit bâtonnet inséré sous la peau du bras. Il libère des hormones pendant 3 ans.

### Le stérilet hormonal
Le DIU hormonal est placé dans l'utérus et peut rester en place pendant 3 à 5 ans selon le modèle.

## Contraception de barrière

### Le préservatif
Le préservatif masculin et féminin offrent une double protection : contraception et prévention des IST.

### Le diaphragme
Le diaphragme est une coupelle en silicone qui se place dans le vagin avant le rapport sexuel.

## Méthodes naturelles

### La méthode symptothermique
Cette méthode combine l'observation de la température corporelle et de la glaire cervicale.

### Le retrait
Bien que moins fiable, le retrait reste une méthode utilisée par certains couples.

## Comment choisir ?

Le choix de la contraception dépend de plusieurs facteurs :
- Votre âge et votre situation
- Vos antécédents médicaux
- Votre vie sexuelle
- Vos préférences personnelles

Consultez toujours un professionnel de santé pour choisir la méthode qui vous convient le mieux.''',
      excerpt: 'Un guide complet des différentes méthodes de contraception disponibles pour vous aider à faire le bon choix.',
      category: ArticleCategory.contraception,
      author: _experts[1],
      tags: ['contraception', 'pilule', 'stérilet', 'préservatif'],
      views: 980,
      likes: 67,
      commentsCount: 15,
      publishedAt: DateTime.now().subtract(const Duration(days: 3)),
      isFeatured: false,
      isExpertContent: true,
    ),
    Article(
      id: '3',
      title: 'Gérer le stress et l\'anxiété au quotidien',
      content: '''Le stress et l'anxiété peuvent avoir un impact significatif sur votre santé physique et mentale. Voici des stratégies pour mieux les gérer.

## Comprendre le stress

Le stress est une réaction normale du corps face à une situation perçue comme menaçante ou difficile. Cependant, un stress chronique peut être néfaste.

## Techniques de relaxation

### La respiration profonde
Prenez le temps de respirer profondément pendant 5 à 10 minutes chaque jour.

### La méditation
La méditation peut aider à calmer l'esprit et réduire l'anxiété.

### L'exercice physique
L'activité physique régulière est un excellent moyen de réduire le stress.

## Gestion du temps

- Établissez des priorités
- Apprenez à dire non
- Organisez votre journée
- Prenez des pauses régulières

## Soutien social

N'hésitez pas à parler de vos préoccupations avec vos proches ou des professionnels.

## Quand demander de l'aide

Si le stress ou l'anxiété interfèrent avec votre vie quotidienne, il est important de consulter un professionnel de santé mentale.''',
      excerpt: 'Découvrez des techniques pratiques pour gérer le stress et l\'anxiété dans votre vie quotidienne.',
      category: ArticleCategory.psychology,
      author: _experts[2],
      tags: ['stress', 'anxiété', 'relaxation', 'bien-être'],
      views: 756,
      likes: 54,
      commentsCount: 18,
      publishedAt: DateTime.now().subtract(const Duration(days: 5)),
      isFeatured: false,
      isExpertContent: true,
    ),
    Article(
      id: '4',
      title: 'Nutrition pendant la grossesse',
      content: '''Une alimentation équilibrée pendant la grossesse est essentielle pour la santé de la mère et du bébé.

## Nutriments essentiels

### Acide folique
Important pour prévenir les malformations du tube neural. Présent dans les légumes verts, les légumineuses.

### Fer
Nécessaire pour prévenir l'anémie. Sources : viande rouge, épinards, lentilles.

### Calcium
Important pour le développement osseux du bébé. Sources : produits laitiers, sardines, brocolis.

### Oméga-3
Essentiels pour le développement du cerveau du bébé. Sources : poissons gras, noix, graines de lin.

## Aliments à éviter

- Alcool
- Poissons riches en mercure
- Viandes et œufs crus
- Fromages au lait cru
- Charcuterie

## Conseils pratiques

- Mangez de petits repas fréquents
- Hydratez-vous suffisamment
- Prenez vos suppléments
- Écoutez votre corps

Consultez toujours votre médecin ou sage-femme pour un suivi personnalisé.''',
      excerpt: 'Guide nutritionnel complet pour une grossesse saine et équilibrée.',
      category: ArticleCategory.pregnancy,
      author: _experts[1],
      tags: ['grossesse', 'nutrition', 'santé', 'alimentation'],
      views: 654,
      likes: 41,
      commentsCount: 12,
      publishedAt: DateTime.now().subtract(const Duration(days: 2)),
      isFeatured: false,
      isExpertContent: true,
    ),
    Article(
      id: '5',
      title: 'Communication dans le couple',
      content: '''Une communication saine est la base d'une relation épanouie. Voici comment améliorer le dialogue dans votre couple.

## Principes de base

### L'écoute active
- Accordez toute votre attention à votre partenaire
- Reformulez ce que vous avez compris
- Posez des questions pour clarifier

### L'expression des sentiments
- Utilisez le "je" plutôt que le "tu"
- Exprimez vos émotions clairement
- Évitez les accusations

## Gérer les conflits

### Choisir le bon moment
Évitez les discussions importantes quand vous êtes fatigués ou stressés.

### Rester respectueux
Même en désaccord, maintenez le respect mutuel.

### Chercher des solutions
Concentrez-vous sur la résolution plutôt que sur le problème.

## Maintenir l'intimité

- Partagez vos rêves et aspirations
- Exprimez votre gratitude
- Planifiez du temps de qualité ensemble
- Soyez affectueux au quotidien

## Demander de l'aide

Si la communication devient difficile, n'hésitez pas à consulter un thérapeute de couple.''',
      excerpt: 'Améliorez la communication dans votre couple avec ces conseils pratiques et bienveillants.',
      category: ArticleCategory.relationships,
      author: _experts[2],
      tags: ['couple', 'communication', 'relation', 'intimité'],
      views: 432,
      likes: 36,
      commentsCount: 9,
      publishedAt: DateTime.now().subtract(const Duration(days: 1)),
      isFeatured: false,
      isExpertContent: true,
    ),
  ];

  // Sample forum posts
  static final List<ForumPost> _samplePosts = [
    ForumPost(
      id: '1',
      title: 'Question sur les douleurs menstruelles',
      content: 'Bonjour, j\'ai des douleurs très fortes pendant mes règles. Est-ce normal ? Que puis-je faire pour les soulager ?',
      category: ForumCategory.health,
      author: _currentUser,
      tags: ['douleurs', 'règles', 'menstruation'],
      views: 156,
      likes: 12,
      repliesCount: 8,
      createdAt: DateTime.now().subtract(const Duration(hours: 6)),
      isExpertQuestion: true,
    ),
    ForumPost(
      id: '2',
      title: 'Conseils pour gérer le stress au travail',
      content: 'Je ressens beaucoup de stress au travail ces derniers temps. Avez-vous des conseils pour mieux gérer cette situation ?',
      category: ForumCategory.support,
      author: CommunityUser(
        id: 'user_2',
        username: 'marie_bf',
        role: UserRole.member,
        joinedAt: DateTime.now().subtract(const Duration(days: 45)),
        reputation: 75,
      ),
      tags: ['stress', 'travail', 'conseil'],
      views: 89,
      likes: 7,
      repliesCount: 5,
      createdAt: DateTime.now().subtract(const Duration(hours: 12)),
    ),
    ForumPost(
      id: '3',
      title: 'Partage d\'expérience : première grossesse',
      content: 'Je suis enceinte pour la première fois et j\'aimerais échanger avec d\'autres mamans sur cette expérience.',
      category: ForumCategory.pregnancy,
      author: CommunityUser(
        id: 'user_3',
        username: 'future_maman',
        role: UserRole.member,
        joinedAt: DateTime.now().subtract(const Duration(days: 20)),
        reputation: 45,
      ),
      tags: ['grossesse', 'première fois', 'expérience'],
      views: 134,
      likes: 15,
      repliesCount: 12,
      createdAt: DateTime.now().subtract(const Duration(days: 1)),
      isPinned: true,
    ),
  ];

  // Article operations
  static Future<List<Article>> getArticles({
    ArticleCategory? category,
    String? searchQuery,
    bool? featuredOnly,
    bool? expertOnly,
  }) async {
    await Future.delayed(const Duration(milliseconds: 500)); // Simulate API call

    var articles = List<Article>.from(_sampleArticles);

    if (category != null) {
      articles = articles.where((article) => article.category == category).toList();
    }

    if (searchQuery != null && searchQuery.isNotEmpty) {
      final query = searchQuery.toLowerCase();
      articles = articles.where((article) {
        return article.title.toLowerCase().contains(query) ||
               article.content.toLowerCase().contains(query) ||
               article.tags.any((tag) => tag.toLowerCase().contains(query));
      }).toList();
    }

    if (featuredOnly == true) {
      articles = articles.where((article) => article.isFeatured).toList();
    }

    if (expertOnly == true) {
      articles = articles.where((article) => article.isExpertContent).toList();
    }

    // Sort by publication date (newest first)
    articles.sort((a, b) => b.publishedAt.compareTo(a.publishedAt));

    return articles;
  }

  static Future<Article?> getArticleById(String articleId) async {
    await Future.delayed(const Duration(milliseconds: 200));
    
    try {
      return _sampleArticles.firstWhere((article) => article.id == articleId);
    } catch (e) {
      return null;
    }
  }

  static Future<List<Article>> getFeaturedArticles() async {
    return getArticles(featuredOnly: true);
  }

  static Future<List<Article>> getExpertArticles() async {
    return getArticles(expertOnly: true);
  }

  // Forum operations
  static Future<List<ForumPost>> getForumPosts({
    ForumCategory? category,
    String? searchQuery,
    bool? pinnedOnly,
    bool? expertQuestions,
  }) async {
    await Future.delayed(const Duration(milliseconds: 500));

    var posts = List<ForumPost>.from(_samplePosts);

    if (category != null) {
      posts = posts.where((post) => post.category == category).toList();
    }

    if (searchQuery != null && searchQuery.isNotEmpty) {
      final query = searchQuery.toLowerCase();
      posts = posts.where((post) {
        return post.title.toLowerCase().contains(query) ||
               post.content.toLowerCase().contains(query) ||
               post.tags.any((tag) => tag.toLowerCase().contains(query));
      }).toList();
    }

    if (pinnedOnly == true) {
      posts = posts.where((post) => post.isPinned).toList();
    }

    if (expertQuestions == true) {
      posts = posts.where((post) => post.isExpertQuestion).toList();
    }

    // Sort by pinned first, then by creation date
    posts.sort((a, b) {
      if (a.isPinned && !b.isPinned) return -1;
      if (!a.isPinned && b.isPinned) return 1;
      return b.createdAt.compareTo(a.createdAt);
    });

    return posts;
  }

  static Future<ForumPost?> getForumPostById(String postId) async {
    await Future.delayed(const Duration(milliseconds: 200));
    
    try {
      return _samplePosts.firstWhere((post) => post.id == postId);
    } catch (e) {
      return null;
    }
  }

  static Future<List<ForumCategory>> getForumCategories() async {
    await Future.delayed(const Duration(milliseconds: 200));
    
    // Return sample forum categories
    return [
      ForumCategory(
        id: 'health',
        name: 'Santé',
        icon: Icons.favorite,
        color: Colors.red,
        description: 'Discussions sur la santé féminine',
      ),
      ForumCategory(
        id: 'cycle',
        name: 'Cycle',
        icon: Icons.calendar_month,
        color: Colors.purple,
        description: 'Questions sur le cycle menstruel',
      ),
      ForumCategory(
        id: 'contraception',
        name: 'Contraception',
        icon: Icons.medical_services,
        color: Colors.blue,
        description: 'Méthodes contraceptives',
      ),
      ForumCategory(
        id: 'nutrition',
        name: 'Nutrition',
        icon: Icons.restaurant,
        color: Colors.green,
        description: 'Alimentation et nutrition',
      ),
      ForumCategory(
        id: 'wellness',
        name: 'Bien-être',
        icon: Icons.spa,
        color: Colors.teal,
        description: 'Bien-être et lifestyle',
      ),
      ForumCategory(
        id: 'relationships',
        name: 'Relations',
        icon: Icons.people,
        color: Colors.orange,
        description: 'Relations et intimité',
      ),
    ];
  }

  // Like operations
  static Future<List<String>> getLikedArticles() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      return prefs.getStringList(_likedArticlesKey) ?? [];
    } catch (e) {
      return [];
    }
  }

  static Future<bool> toggleArticleLike(String articleId) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final likedArticles = await getLikedArticles();
      
      if (likedArticles.contains(articleId)) {
        likedArticles.remove(articleId);
      } else {
        likedArticles.add(articleId);
      }
      
      return await prefs.setStringList(_likedArticlesKey, likedArticles);
    } catch (e) {
      return false;
    }
  }

  static Future<bool> isArticleLiked(String articleId) async {
    final likedArticles = await getLikedArticles();
    return likedArticles.contains(articleId);
  }

  static Future<List<String>> getLikedPosts() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      return prefs.getStringList(_likedPostsKey) ?? [];
    } catch (e) {
      return [];
    }
  }

  static Future<bool> togglePostLike(String postId) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final likedPosts = await getLikedPosts();
      
      if (likedPosts.contains(postId)) {
        likedPosts.remove(postId);
      } else {
        likedPosts.add(postId);
      }
      
      return await prefs.setStringList(_likedPostsKey, likedPosts);
    } catch (e) {
      return false;
    }
  }

  static Future<bool> isPostLiked(String postId) async {
    final likedPosts = await getLikedPosts();
    return likedPosts.contains(postId);
  }

  // Bookmark operations
  static Future<List<String>> getBookmarkedArticles() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      return prefs.getStringList(_bookmarkedArticlesKey) ?? [];
    } catch (e) {
      return [];
    }
  }

  static Future<bool> toggleArticleBookmark(String articleId) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final bookmarkedArticles = await getBookmarkedArticles();
      
      if (bookmarkedArticles.contains(articleId)) {
        bookmarkedArticles.remove(articleId);
      } else {
        bookmarkedArticles.add(articleId);
      }
      
      return await prefs.setStringList(_bookmarkedArticlesKey, bookmarkedArticles);
    } catch (e) {
      return false;
    }
  }

  static Future<bool> isArticleBookmarked(String articleId) async {
    final bookmarkedArticles = await getBookmarkedArticles();
    return bookmarkedArticles.contains(articleId);
  }

  // User operations
  static CommunityUser getCurrentUser() {
    return _currentUser;
  }

  static Future<List<CommunityUser>> getExperts() async {
    await Future.delayed(const Duration(milliseconds: 200));
    return _experts;
  }

  // Comment operations (simplified for demo)
  static Future<List<ArticleComment>> getArticleComments(String articleId) async {
    await Future.delayed(const Duration(milliseconds: 300));
    
    // Return sample comments for demo
    return [
      ArticleComment(
        id: '1',
        articleId: articleId,
        content: 'Merci pour cet article très informatif !',
        author: _currentUser,
        likes: 5,
        createdAt: DateTime.now().subtract(const Duration(hours: 2)),
      ),
      ArticleComment(
        id: '2',
        articleId: articleId,
        content: 'J\'ai appris beaucoup de choses, très utile.',
        author: CommunityUser(
          id: 'user_4',
          username: 'lectrice_assidue',
          role: UserRole.member,
          joinedAt: DateTime.now().subtract(const Duration(days: 60)),
          reputation: 120,
        ),
        likes: 3,
        createdAt: DateTime.now().subtract(const Duration(hours: 4)),
      ),
    ];
  }

  // Forum reply operations (simplified for demo)
  static Future<List<ForumReply>> getForumReplies(String postId) async {
    await Future.delayed(const Duration(milliseconds: 300));
    
    // Return sample replies for demo
    return [
      ForumReply(
        id: '1',
        postId: postId,
        content: 'Les douleurs menstruelles peuvent être normales, mais il est important de consulter si elles sont très intenses.',
        author: _experts[0],
        likes: 15,
        createdAt: DateTime.now().subtract(const Duration(hours: 1)),
        isExpertReply: true,
        isAcceptedAnswer: true,
      ),
      ForumReply(
        id: '2',
        postId: postId,
        content: 'Je recommande aussi de tenir un journal de vos symptômes pour mieux comprendre votre cycle.',
        author: _experts[1],
        likes: 8,
        createdAt: DateTime.now().subtract(const Duration(minutes: 30)),
        isExpertReply: true,
      ),
    ];
  }

  // Utility methods
  static String formatTimeAgo(DateTime dateTime) {
    final now = DateTime.now();
    final difference = now.difference(dateTime);

    if (difference.inDays > 0) {
      return 'il y a ${difference.inDays} jour${difference.inDays > 1 ? 's' : ''}';
    } else if (difference.inHours > 0) {
      return 'il y a ${difference.inHours} heure${difference.inHours > 1 ? 's' : ''}';
    } else if (difference.inMinutes > 0) {
      return 'il y a ${difference.inMinutes} minute${difference.inMinutes > 1 ? 's' : ''}';
    } else {
      return 'à l\'instant';
    }
  }

  static String generateId() {
    final timestamp = DateTime.now().millisecondsSinceEpoch;
    return 'item_${timestamp}_${(timestamp % 10000).toString().padLeft(4, '0')}';
  }
}