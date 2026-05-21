import 'package:flutter/material.dart';

class AppConstants {
  AppConstants._();

  // App info
  static const String appName = 'Prompt Hero';
  static const String appTagline = 'Curated Claude AI Prompts';
  static const String appVersion = '1.0.0';

  // Firestore collections
  static const String categoriesCollection = 'categories';
  static const String promptsCollection = 'prompts';
  static const String ratingsCollection = 'ratings';
  static const String requestsCollection = 'requests';
  static const String usersCollection = 'users';

  // User roles
  static const String roleAdmin = 'admin';
  static const String roleUser = 'user';

  // Request types
  static const String requestTypeCategory = 'category';
  static const String requestTypePrompt = 'prompt';

  // Request statuses
  static const String statusPending = 'pending';
  static const String statusApproved = 'approved';
  static const String statusRejected = 'rejected';

  // Limits
  static const int maxPromptsPerCategory = 15;
  static const int maxCategories = 50;
  static const int promptTextMaxLines = 3;

  // WhatsApp
  static const String whatsAppBaseUrl = 'https://wa.me/?text=';

  // Icon name to IconData mapping
  static const Map<String, IconData> categoryIcons = {
    'edit': Icons.edit_note_rounded,
    'business': Icons.business_center_rounded,
    'email': Icons.email_rounded,
    'code': Icons.code_rounded,
    'school': Icons.school_rounded,
    'science': Icons.science_rounded,
    'psychology': Icons.psychology_rounded,
    'campaign': Icons.campaign_rounded,
    'analytics': Icons.analytics_rounded,
    'brush': Icons.brush_rounded,
    'photo_camera': Icons.photo_camera_rounded,
    'movie': Icons.movie_rounded,
    'music_note': Icons.music_note_rounded,
    'fitness_center': Icons.fitness_center_rounded,
    'restaurant': Icons.restaurant_rounded,
    'travel_explore': Icons.travel_explore_rounded,
    'attach_money': Icons.attach_money_rounded,
    'health_and_safety': Icons.health_and_safety_rounded,
    'groups': Icons.groups_rounded,
    'star': Icons.star_rounded,
    'lightbulb': Icons.lightbulb_rounded,
    'chat': Icons.chat_bubble_rounded,
    'support': Icons.support_agent_rounded,
    'build': Icons.build_rounded,
    'search': Icons.manage_search_rounded,
  };

  static IconData getIcon(String? iconName) {
    return categoryIcons[iconName] ?? Icons.category_rounded;
  }

  // Default icon names list (for picker)
  static const List<String> availableIconNames = [
    'edit',
    'business',
    'email',
    'code',
    'school',
    'science',
    'psychology',
    'campaign',
    'analytics',
    'brush',
    'photo_camera',
    'movie',
    'music_note',
    'fitness_center',
    'restaurant',
    'travel_explore',
    'attach_money',
    'health_and_safety',
    'groups',
    'star',
    'lightbulb',
    'chat',
    'support',
    'build',
    'search',
  ];

  // Seed data (shown in README, not auto-written to DB)
  static const List<Map<String, dynamic>> sampleCategories = [
    {
      'name': 'Writing & Content Creation',
      'description': 'Prompts for blog posts, articles, storytelling, and creative writing',
      'iconName': 'edit',
      'gradientIndex': 0,
      'prompts': [
        {
          'title': 'Viral Blog Post Outline',
          'text':
              'Create a detailed blog post outline for the topic: [TOPIC]. The post should be optimized for SEO, include a compelling headline, introduction hook, 5-7 main sections with subpoints, and a strong call-to-action conclusion. Target audience: [AUDIENCE]. Tone: [TONE].',
        },
        {
          'title': 'Engaging Social Media Caption',
          'text':
              'Write 5 engaging social media captions for [PLATFORM] about [TOPIC/PRODUCT]. Each caption should: include a hook in the first line, tell a mini-story or share a surprising fact, use relevant emojis, end with a question or CTA, and include hashtag suggestions. Keep each under [CHARACTER_LIMIT] characters.',
        },
        {
          'title': 'Story with Vivid Characters',
          'text':
              'Write a short story (500-800 words) in the genre of [GENRE] featuring [NUMBER] main characters. Setting: [SETTING]. The story must include: a compelling opening scene, at least one unexpected plot twist, vivid sensory descriptions, authentic dialogue, and a satisfying ending that leaves the reader thinking.',
        },
        {
          'title': 'Product Description Writer',
          'text':
              'Write a persuasive product description for [PRODUCT NAME] targeting [TARGET AUDIENCE]. Include: a headline that highlights the key benefit, 3-4 bullet points of key features (framed as benefits), a short paragraph that paints a picture of the customer using the product, social proof placeholder, and a clear CTA.',
        },
        {
          'title': 'Newsletter Introduction Hook',
          'text':
              'Write 3 different opening paragraphs for a newsletter about [TOPIC]. Each should use a different hook technique: (1) a shocking statistic, (2) a relatable anecdote, (3) a provocative question. Each opening should be 2-3 sentences and immediately make the reader want to continue.',
        },
      ],
    },
    {
      'name': 'Business Strategy',
      'description': 'Strategic frameworks for growth, planning, and competitive analysis',
      'iconName': 'business',
      'gradientIndex': 1,
      'prompts': [
        {
          'title': 'SWOT Analysis Generator',
          'text':
              'Conduct a comprehensive SWOT analysis for [COMPANY/PRODUCT] in the [INDUSTRY] industry. For each quadrant (Strengths, Weaknesses, Opportunities, Threats), provide 4-6 specific, actionable points with brief explanations. Then suggest 3 strategic priorities that emerge from the analysis. Context: [ADDITIONAL CONTEXT].',
        },
        {
          'title': 'Go-to-Market Strategy',
          'text':
              'Develop a go-to-market strategy for [PRODUCT/SERVICE] launching in [MARKET/REGION]. Include: target customer segments with personas, value proposition, pricing strategy with rationale, distribution channels, marketing and sales approach, key metrics to track, and a 90-day launch roadmap. Budget constraints: [BUDGET].',
        },
        {
          'title': 'Competitive Analysis Framework',
          'text':
              'Analyze the competitive landscape for [COMPANY] in [MARKET]. Identify the top 5 competitors and for each provide: market positioning, key strengths, notable weaknesses, pricing approach, and unique differentiators. Then identify 3 market gaps that [COMPANY] could exploit and recommend a differentiation strategy.',
        },
        {
          'title': 'OKR Goal Setting',
          'text':
              'Help me create quarterly OKRs (Objectives and Key Results) for [TEAM/DEPARTMENT] at [COMPANY]. Our annual goal is [ANNUAL GOAL]. Create 3 objectives, each with 3-4 measurable key results. Ensure key results are specific, time-bound, and ambitious yet achievable. Also suggest 2-3 initiatives to achieve each objective.',
        },
        {
          'title': 'Business Model Canvas',
          'text':
              'Fill out a Business Model Canvas for [BUSINESS IDEA]. For each of the 9 sections — Customer Segments, Value Propositions, Channels, Customer Relationships, Revenue Streams, Key Resources, Key Activities, Key Partnerships, Cost Structure — provide detailed, specific content. Then identify the 3 biggest risks and 3 biggest opportunities.',
        },
      ],
    },
    {
      'name': 'Email & Communication',
      'description': 'Professional templates for every email scenario',
      'iconName': 'email',
      'gradientIndex': 2,
      'prompts': [
        {
          'title': 'Cold Outreach Email',
          'text':
              'Write a cold outreach email to [RECIPIENT NAME] at [COMPANY]. My name is [YOUR NAME] from [YOUR COMPANY]. The purpose is [PURPOSE]. Keep it under 150 words. Include: a personalized opening referencing something specific about them, a clear value proposition, a specific ask (not a vague "let\'s connect"), and a P.S. line. Tone: professional yet warm.',
        },
        {
          'title': 'Follow-Up Email Sequence',
          'text':
              'Write a 3-email follow-up sequence for [SCENARIO - e.g., sales proposal, job application, partnership inquiry]. Email 1 (Day 3): Brief, adds new value. Email 2 (Day 7): Different angle, social proof. Email 3 (Day 14): Final attempt, clear close. Each email should be under 100 words, have a unique subject line, and feel natural, not desperate.',
        },
        {
          'title': 'Difficult Conversation Email',
          'text':
              'Help me write a professional email to [RECIPIENT] about [DIFFICULT SITUATION - e.g., missed deadline, poor performance, complaint]. The email should: acknowledge the issue without being accusatory, explain the impact clearly, propose a specific solution or next step, maintain a professional and constructive tone, and end with a clear action item.',
        },
        {
          'title': 'Partnership Proposal Email',
          'text':
              'Write a compelling partnership proposal email to [COMPANY NAME]. We are [YOUR COMPANY] and we want to propose [PARTNERSHIP TYPE]. Include: why this partnership makes sense for both parties, what we bring to the table, what we\'re asking for, specific metrics or outcomes we expect, and a clear next step. Keep it under 200 words.',
        },
        {
          'title': 'Executive Summary Email',
          'text':
              'Rewrite the following information as a crisp executive summary email to [AUDIENCE - e.g., board, investors, leadership team]. Original content: [PASTE CONTENT HERE]. The email should: lead with the key insight or decision needed, use bullet points for clarity, be scannable in under 60 seconds, and end with a clear recommendation or ask. Maximum 250 words.',
        },
      ],
    },
  ];
}
