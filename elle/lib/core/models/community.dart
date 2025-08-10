import 'package:flutter/material.dart';

enum ArticleCategory {
  health,
  contraception,
  menstruation,
  pregnancy,
  intimacy,
  nutrition,
  psychology,
  relationships,
}

extension ArticleCategoryExtension on ArticleCategory {
  String get id {
    switch (this) {
      case ArticleCategory.health:
        return 'health';
      case ArticleCategory.contraception:
        return 'contraception';
      case ArticleCategory.menstruation:
        return 'menstruation';
      case ArticleCategory.pregnancy:
        return 'pregnancy';
      case ArticleCategory.intimacy:
        return 'intimacy';
      case ArticleCategory.nutrition:
        return 'nutrition';
      case ArticleCategory.psychology:
        return 'psychology';
      case ArticleCategory.relationships:
        return 'relationships';
    }
  }
}

class ForumCategory {
  final String id;
  final String name;
  final IconData icon;
  final Color color;
  final String description;

  const ForumCategory({
    required this.id,
    required this.name,
    required this.icon,
    required this.color,
    required this.description,
  });

  // Static instances for predefined categories
  static const ForumCategory general = ForumCategory(
    id: 'general',
    name: 'Général',
    icon: Icons.forum,
    color: Colors.blue,
    description: 'Discussions générales',
  );

  static const ForumCategory health = ForumCategory(
    id: 'health',
    name: 'Santé',
    icon: Icons.favorite,
    color: Colors.red,
    description: 'Discussions sur la santé féminine',
  );

  static const ForumCategory relationships = ForumCategory(
    id: 'relationships',
    name: 'Relations',
    icon: Icons.people,
    color: Colors.orange,
    description: 'Relations et intimité',
  );

  static const ForumCategory pregnancy = ForumCategory(
    id: 'pregnancy',
    name: 'Grossesse',
    icon: Icons.pregnant_woman,
    color: Colors.pink,
    description: 'Questions sur la grossesse',
  );

  static const ForumCategory menstruation = ForumCategory(
    id: 'menstruation',
    name: 'Menstruation',
    icon: Icons.calendar_month,
    color: Colors.purple,
    description: 'Questions sur le cycle menstruel',
  );

  static const ForumCategory support = ForumCategory(
    id: 'support',
    name: 'Soutien',
    icon: Icons.support,
    color: Colors.green,
    description: 'Soutien et encouragement',
  );

  static const ForumCategory tips = ForumCategory(
    id: 'tips',
    name: 'Conseils',
    icon: Icons.tips_and_updates,
    color: Colors.amber,
    description: 'Conseils et astuces',
  );

  static List<ForumCategory> get values => [
    general,
    health,
    relationships,
    pregnancy,
    menstruation,
    support,
    tips,
  ];
}

enum UserRole {
  member,
  expert,
  moderator,
  admin,
}

class CommunityUser {
  final String id;
  final String username;
  final String? fullName;
  final String? profileImageUrl;
  final UserRole role;
  final String? expertise;
  final int reputation;
  final DateTime joinedAt;
  final bool isVerified;

  const CommunityUser({
    required this.id,
    required this.username,
    this.fullName,
    this.profileImageUrl,
    this.role = UserRole.member,
    this.expertise,
    this.reputation = 0,
    required this.joinedAt,
    this.isVerified = false,
  });

  String get displayName => fullName ?? username;

  CommunityUser copyWith({
    String? id,
    String? username,
    String? fullName,
    String? profileImageUrl,
    UserRole? role,
    String? expertise,
    int? reputation,
    DateTime? joinedAt,
    bool? isVerified,
  }) {
    return CommunityUser(
      id: id ?? this.id,
      username: username ?? this.username,
      fullName: fullName ?? this.fullName,
      profileImageUrl: profileImageUrl ?? this.profileImageUrl,
      role: role ?? this.role,
      expertise: expertise ?? this.expertise,
      reputation: reputation ?? this.reputation,
      joinedAt: joinedAt ?? this.joinedAt,
      isVerified: isVerified ?? this.isVerified,
    );
  }

  String get roleDisplayName {
    switch (role) {
      case UserRole.member:
        return 'Membre';
      case UserRole.expert:
        return 'Expert';
      case UserRole.moderator:
        return 'Modérateur';
      case UserRole.admin:
        return 'Admin';
    }
  }

  String get roleEmoji {
    switch (role) {
      case UserRole.member:
        return '👤';
      case UserRole.expert:
        return '🩺';
      case UserRole.moderator:
        return '🛡️';
      case UserRole.admin:
        return '👑';
    }
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'username': username,
      'fullName': fullName,
      'profileImageUrl': profileImageUrl,
      'role': role.name,
      'expertise': expertise,
      'reputation': reputation,
      'joinedAt': joinedAt.toIso8601String(),
      'isVerified': isVerified,
    };
  }

  factory CommunityUser.fromJson(Map<String, dynamic> json) {
    return CommunityUser(
      id: json['id'] as String,
      username: json['username'] as String,
      fullName: json['fullName'] as String?,
      profileImageUrl: json['profileImageUrl'] as String?,
      role: UserRole.values.firstWhere(
        (e) => e.name == json['role'],
        orElse: () => UserRole.member,
      ),
      expertise: json['expertise'] as String?,
      reputation: json['reputation'] as int? ?? 0,
      joinedAt: DateTime.parse(json['joinedAt'] as String),
      isVerified: json['isVerified'] as bool? ?? false,
    );
  }
}

class Article {
  final String id;
  final String title;
  final String content;
  final String excerpt;
  final String? imageUrl;
  final ArticleCategory category;
  final CommunityUser author;
  final List<String> tags;
  final int views;
  final int likes;
  final int commentsCount;
  final DateTime publishedAt;
  final DateTime? updatedAt;
  final bool isFeatured;
  final bool isExpertContent;

  const Article({
    required this.id,
    required this.title,
    required this.content,
    required this.excerpt,
    this.imageUrl,
    required this.category,
    required this.author,
    this.tags = const [],
    this.views = 0,
    this.likes = 0,
    this.commentsCount = 0,
    required this.publishedAt,
    this.updatedAt,
    this.isFeatured = false,
    this.isExpertContent = false,
  });

  Article copyWith({
    String? id,
    String? title,
    String? content,
    String? excerpt,
    String? imageUrl,
    ArticleCategory? category,
    CommunityUser? author,
    List<String>? tags,
    int? views,
    int? likes,
    int? commentsCount,
    DateTime? publishedAt,
    DateTime? updatedAt,
    bool? isFeatured,
    bool? isExpertContent,
  }) {
    return Article(
      id: id ?? this.id,
      title: title ?? this.title,
      content: content ?? this.content,
      excerpt: excerpt ?? this.excerpt,
      imageUrl: imageUrl ?? this.imageUrl,
      category: category ?? this.category,
      author: author ?? this.author,
      tags: tags ?? this.tags,
      views: views ?? this.views,
      likes: likes ?? this.likes,
      commentsCount: commentsCount ?? this.commentsCount,
      publishedAt: publishedAt ?? this.publishedAt,
      updatedAt: updatedAt ?? this.updatedAt,
      isFeatured: isFeatured ?? this.isFeatured,
      isExpertContent: isExpertContent ?? this.isExpertContent,
    );
  }

  String get categoryDisplayName {
    switch (category) {
      case ArticleCategory.health:
        return 'Santé';
      case ArticleCategory.contraception:
        return 'Contraception';
      case ArticleCategory.menstruation:
        return 'Menstruation';
      case ArticleCategory.pregnancy:
        return 'Grossesse';
      case ArticleCategory.intimacy:
        return 'Intimité';
      case ArticleCategory.nutrition:
        return 'Nutrition';
      case ArticleCategory.psychology:
        return 'Psychologie';
      case ArticleCategory.relationships:
        return 'Relations';
      default:
        return 'Autre';
    }
  }

  String get categoryEmoji {
    switch (category) {
      case ArticleCategory.health:
        return '🏥';
      case ArticleCategory.contraception:
        return '🛡️';
      case ArticleCategory.menstruation:
        return '🩸';
      case ArticleCategory.pregnancy:
        return '🤱';
      case ArticleCategory.intimacy:
        return '💕';
      case ArticleCategory.nutrition:
        return '🥗';
      case ArticleCategory.psychology:
        return '🧠';
      case ArticleCategory.relationships:
        return '👫';
      default:
        return '❓';
    }
  }

  String get readingTime {
    final words = content.split(' ').length;
    final minutes = (words / 200).ceil(); // Average reading speed: 200 words/minute
    return '$minutes min de lecture';
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'content': content,
      'excerpt': excerpt,
      'imageUrl': imageUrl,
      'category': category.id,
      'author': author.toJson(),
      'tags': tags,
      'views': views,
      'likes': likes,
      'commentsCount': commentsCount,
      'publishedAt': publishedAt.toIso8601String(),
      'updatedAt': updatedAt?.toIso8601String(),
      'isFeatured': isFeatured,
      'isExpertContent': isExpertContent,
    };
  }

  factory Article.fromJson(Map<String, dynamic> json) {
    return Article(
      id: json['id'] as String,
      title: json['title'] as String,
      content: json['content'] as String,
      excerpt: json['excerpt'] as String,
      imageUrl: json['imageUrl'] as String?,
      category: ArticleCategory.values.firstWhere(
        (e) => e.name == json['category'],
        orElse: () => ArticleCategory.health,
      ),
      author: CommunityUser.fromJson(json['author'] as Map<String, dynamic>),
      tags: List<String>.from(json['tags'] as List? ?? []),
      views: json['views'] as int? ?? 0,
      likes: json['likes'] as int? ?? 0,
      commentsCount: json['commentsCount'] as int? ?? 0,
      publishedAt: DateTime.parse(json['publishedAt'] as String),
      updatedAt: json['updatedAt'] != null 
          ? DateTime.parse(json['updatedAt'] as String)
          : null,
      isFeatured: json['isFeatured'] as bool? ?? false,
      isExpertContent: json['isExpertContent'] as bool? ?? false,
    );
  }
}

class ForumPost {
  final String id;
  final String title;
  final String content;
  final ForumCategory category;
  final CommunityUser author;
  final List<String> tags;
  final int views;
  final int likes;
  final int repliesCount;
  final DateTime createdAt;
  final DateTime? updatedAt;
  final bool isPinned;
  final bool isClosed;
  final bool isExpertQuestion;

  const ForumPost({
    required this.id,
    required this.title,
    required this.content,
    required this.category,
    required this.author,
    this.tags = const [],
    this.views = 0,
    this.likes = 0,
    this.repliesCount = 0,
    required this.createdAt,
    this.updatedAt,
    this.isPinned = false,
    this.isClosed = false,
    this.isExpertQuestion = false,
  });

  int get comments => repliesCount;

  ForumPost copyWith({
    String? id,
    String? title,
    String? content,
    ForumCategory? category,
    CommunityUser? author,
    List<String>? tags,
    int? views,
    int? likes,
    int? repliesCount,
    DateTime? createdAt,
    DateTime? updatedAt,
    bool? isPinned,
    bool? isClosed,
    bool? isExpertQuestion,
  }) {
    return ForumPost(
      id: id ?? this.id,
      title: title ?? this.title,
      content: content ?? this.content,
      category: category ?? this.category,
      author: author ?? this.author,
      tags: tags ?? this.tags,
      views: views ?? this.views,
      likes: likes ?? this.likes,
      repliesCount: repliesCount ?? this.repliesCount,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      isPinned: isPinned ?? this.isPinned,
      isClosed: isClosed ?? this.isClosed,
      isExpertQuestion: isExpertQuestion ?? this.isExpertQuestion,
    );
  }

  String get categoryDisplayName {
    switch (category) {
      case ForumCategory.general:
        return 'Général';
      case ForumCategory.health:
        return 'Santé';
      case ForumCategory.relationships:
        return 'Relations';
      case ForumCategory.pregnancy:
        return 'Grossesse';
      case ForumCategory.menstruation:
        return 'Menstruation';
      case ForumCategory.support:
        return 'Soutien';
      case ForumCategory.tips:
        return 'Conseils';
      default:
        return 'Autre';
    }
  }

  String get categoryEmoji {
    switch (category) {
      case ForumCategory.general:
        return '💬';
      case ForumCategory.health:
        return '🏥';
      case ForumCategory.relationships:
        return '👫';
      case ForumCategory.pregnancy:
        return '🤱';
      case ForumCategory.menstruation:
        return '🩸';
      case ForumCategory.support:
        return '🤗';
      case ForumCategory.tips:
        return '💡';
      default:
        return '❓';
    }
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'content': content,
      'category': category.id,
      'author': author.toJson(),
      'tags': tags,
      'views': views,
      'likes': likes,
      'repliesCount': repliesCount,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt?.toIso8601String(),
      'isPinned': isPinned,
      'isClosed': isClosed,
      'isExpertQuestion': isExpertQuestion,
    };
  }

  factory ForumPost.fromJson(Map<String, dynamic> json) {
    return ForumPost(
      id: json['id'] as String,
      title: json['title'] as String,
      content: json['content'] as String,
      category: ForumCategory.values.firstWhere(
        (e) => e.id == json['category'],
        orElse: () => ForumCategory.general,
      ),
      author: CommunityUser.fromJson(json['author'] as Map<String, dynamic>),
      tags: List<String>.from(json['tags'] as List? ?? []),
      views: json['views'] as int? ?? 0,
      likes: json['likes'] as int? ?? 0,
      repliesCount: json['repliesCount'] as int? ?? 0,
      createdAt: DateTime.parse(json['createdAt'] as String),
      updatedAt: json['updatedAt'] != null 
          ? DateTime.parse(json['updatedAt'] as String)
          : null,
      isPinned: json['isPinned'] as bool? ?? false,
      isClosed: json['isClosed'] as bool? ?? false,
      isExpertQuestion: json['isExpertQuestion'] as bool? ?? false,
    );
  }
}

class ForumReply {
  final String id;
  final String postId;
  final String content;
  final CommunityUser author;
  final int likes;
  final DateTime createdAt;
  final DateTime? updatedAt;
  final bool isExpertReply;
  final bool isAcceptedAnswer;
  final String? parentReplyId;

  const ForumReply({
    required this.id,
    required this.postId,
    required this.content,
    required this.author,
    this.likes = 0,
    required this.createdAt,
    this.updatedAt,
    this.isExpertReply = false,
    this.isAcceptedAnswer = false,
    this.parentReplyId,
  });

  ForumReply copyWith({
    String? id,
    String? postId,
    String? content,
    CommunityUser? author,
    int? likes,
    DateTime? createdAt,
    DateTime? updatedAt,
    bool? isExpertReply,
    bool? isAcceptedAnswer,
    String? parentReplyId,
  }) {
    return ForumReply(
      id: id ?? this.id,
      postId: postId ?? this.postId,
      content: content ?? this.content,
      author: author ?? this.author,
      likes: likes ?? this.likes,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      isExpertReply: isExpertReply ?? this.isExpertReply,
      isAcceptedAnswer: isAcceptedAnswer ?? this.isAcceptedAnswer,
      parentReplyId: parentReplyId ?? this.parentReplyId,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'postId': postId,
      'content': content,
      'author': author.toJson(),
      'likes': likes,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt?.toIso8601String(),
      'isExpertReply': isExpertReply,
      'isAcceptedAnswer': isAcceptedAnswer,
      'parentReplyId': parentReplyId,
    };
  }

  factory ForumReply.fromJson(Map<String, dynamic> json) {
    return ForumReply(
      id: json['id'] as String,
      postId: json['postId'] as String,
      content: json['content'] as String,
      author: CommunityUser.fromJson(json['author'] as Map<String, dynamic>),
      likes: json['likes'] as int? ?? 0,
      createdAt: DateTime.parse(json['createdAt'] as String),
      updatedAt: json['updatedAt'] != null 
          ? DateTime.parse(json['updatedAt'] as String)
          : null,
      isExpertReply: json['isExpertReply'] as bool? ?? false,
      isAcceptedAnswer: json['isAcceptedAnswer'] as bool? ?? false,
      parentReplyId: json['parentReplyId'] as String?,
    );
  }
}

class ArticleComment {
  final String id;
  final String articleId;
  final String content;
  final CommunityUser author;
  final int likes;
  final DateTime createdAt;
  final DateTime? updatedAt;
  final String? parentCommentId;

  const ArticleComment({
    required this.id,
    required this.articleId,
    required this.content,
    required this.author,
    this.likes = 0,
    required this.createdAt,
    this.updatedAt,
    this.parentCommentId,
  });

  ArticleComment copyWith({
    String? id,
    String? articleId,
    String? content,
    CommunityUser? author,
    int? likes,
    DateTime? createdAt,
    DateTime? updatedAt,
    String? parentCommentId,
  }) {
    return ArticleComment(
      id: id ?? this.id,
      articleId: articleId ?? this.articleId,
      content: content ?? this.content,
      author: author ?? this.author,
      likes: likes ?? this.likes,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      parentCommentId: parentCommentId ?? this.parentCommentId,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'articleId': articleId,
      'content': content,
      'author': author.toJson(),
      'likes': likes,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt?.toIso8601String(),
      'parentCommentId': parentCommentId,
    };
  }

  factory ArticleComment.fromJson(Map<String, dynamic> json) {
    return ArticleComment(
      id: json['id'] as String,
      articleId: json['articleId'] as String,
      content: json['content'] as String,
      author: CommunityUser.fromJson(json['author'] as Map<String, dynamic>),
      likes: json['likes'] as int? ?? 0,
      createdAt: DateTime.parse(json['createdAt'] as String),
      updatedAt: json['updatedAt'] != null 
          ? DateTime.parse(json['updatedAt'] as String)
          : null,
      parentCommentId: json['parentCommentId'] as String?,
    );
  }
}