import 'package:flutter/material.dart';
import '../../../core/theme/colors.dart';
import '../../../core/theme/typography.dart';
import '../../../core/utils/responsive.dart';
import '../../reviews/models/review_model.dart';
import 'models/contact_message_model.dart';
import 'services/moderation_service.dart';
import 'widgets/review_moderation_card.dart';
import 'widgets/contact_message_card.dart';

class ModerationPage extends StatefulWidget {
  const ModerationPage({super.key});

  @override
  State<ModerationPage> createState() => _ModerationPageState();
}

class _ModerationPageState extends State<ModerationPage> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final ModerationService _service = ModerationService();

  List<ReviewModel> _reviews = [];
  List<ContactMessageModel> _messages = [];
  bool _isLoadingReviews = true;
  bool _isLoadingMessages = true;
  String? _errorReviews;
  String? _errorMessages;

  String _reviewSortBy = 'date';
  String _reviewOrder = 'desc';

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _loadReviews();
    _loadMessages();
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  Future<void> _loadReviews() async {
    setState(() {
      _isLoadingReviews = true;
      _errorReviews = null;
    });
    try {
      final reviews = await _service.getReviews(
        sortBy: _reviewSortBy,
        order: _reviewOrder,
      );
      setState(() {
        _reviews = reviews;
        _isLoadingReviews = false;
      });
    } catch (e) {
      setState(() {
        _errorReviews = e.toString();
        _isLoadingReviews = false;
      });
    }
  }

  Future<void> _loadMessages() async {
    setState(() {
      _isLoadingMessages = true;
      _errorMessages = null;
    });
    try {
      final messages = await _service.getContactMessages();
      setState(() {
        _messages = messages;
        _isLoadingMessages = false;
      });
    } catch (e) {
      setState(() {
        _errorMessages = e.toString();
        _isLoadingMessages = false;
      });
    }
  }

  Future<void> _moderateReview(int reviewId, String status) async {
    try {
      await _service.moderateReview(reviewId: reviewId, status: status);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Avis ${status == "APPROVED" ? "approuvé" : "rejeté"}'), backgroundColor: Colors.green),
      );
      _loadReviews();
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(e.toString().replaceAll('Exception: ', '')), backgroundColor: Colors.red),
      );
    }
  }

  Future<void> _updateMessageStatus(int messageId, String status) async {
    try {
      await _service.updateMessageStatus(messageId: messageId, status: status);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Statut mis à jour'), backgroundColor: Colors.green),
      );
      _loadMessages();
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(e.toString().replaceAll('Exception: ', '')), backgroundColor: Colors.red),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: Column(
        children: [
          Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  Colors.white,
                  AppColors.primary.withValues(alpha: 0.05),
                ],
              ),
            ),
            padding: EdgeInsets.only(
              top: MediaQuery.of(context).padding.top + 16,
              left: context.horizontalPadding,
              right: context.horizontalPadding,
              bottom: 0,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [AppColors.primary, AppColors.primary.withValues(alpha: 0.8)],
                        ),
                        borderRadius: BorderRadius.circular(12),
                        boxShadow: [
                          BoxShadow(
                            color: AppColors.primary.withValues(alpha: 0.3),
                            blurRadius: 8,
                            offset: const Offset(0, 4),
                          ),
                        ],
                      ),
                      child: const Icon(Icons.admin_panel_settings, color: Colors.white, size: 28),
                    ),
                    const SizedBox(width: 16),
                    Text(
                      'Modération',
                      style: AppTextStyles.displayTitle.copyWith(
                        fontSize: 28,
                        color: AppColors.textPrimary,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                TabBar(
                  controller: _tabController,
                  labelColor: AppColors.primary,
                  unselectedLabelColor: AppColors.textSecondary,
                  indicatorColor: AppColors.primary,
                  labelStyle: AppTextStyles.subtitle.copyWith(fontWeight: FontWeight.w600),
                  tabs: const [
                    Tab(text: 'Avis clients'),
                    Tab(text: 'Messages contact'),
                  ],
                ),
              ],
            ),
          ),
          Expanded(
            child: TabBarView(
              controller: _tabController,
              children: [
                _buildReviewsTab(),
                _buildMessagesTab(),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildReviewsTab() {
    return Column(
      children: [
        Container(
          decoration: BoxDecoration(
            color: Colors.white,
            border: Border(
              bottom: BorderSide(color: AppColors.glassBorder, width: 1),
            ),
          ),
          padding: EdgeInsets.all(context.horizontalPadding),
          child: Row(
            children: [
              Expanded(
                child: DropdownButtonFormField<String>(
                  value: _reviewSortBy,
                  decoration: InputDecoration(
                    labelText: 'Trier par',
                    labelStyle: AppTextStyles.caption.copyWith(color: AppColors.primary),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide(color: AppColors.glassBorder),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide(color: AppColors.glassBorder),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide(color: AppColors.primary, width: 2),
                    ),
                    filled: true,
                    fillColor: AppColors.glassFill,
                  ),
                  items: const [
                    DropdownMenuItem(value: 'date', child: Text('Date')),
                    DropdownMenuItem(value: 'rating', child: Text('Note')),
                  ],
                  onChanged: (value) {
                    setState(() => _reviewSortBy = value!);
                    _loadReviews();
                  },
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: DropdownButtonFormField<String>(
                  value: _reviewOrder,
                  decoration: InputDecoration(
                    labelText: 'Ordre',
                    labelStyle: AppTextStyles.caption.copyWith(color: AppColors.primary),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide(color: AppColors.glassBorder),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide(color: AppColors.glassBorder),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide(color: AppColors.primary, width: 2),
                    ),
                    filled: true,
                    fillColor: AppColors.glassFill,
                  ),
                  items: const [
                    DropdownMenuItem(value: 'asc', child: Text('Croissant')),
                    DropdownMenuItem(value: 'desc', child: Text('Décroissant')),
                  ],
                  onChanged: (value) {
                    setState(() => _reviewOrder = value!);
                    _loadReviews();
                  },
                ),
              ),
            ],
          ),
        ),
        Expanded(
          child: _isLoadingReviews
              ? const Center(child: CircularProgressIndicator())
              : _errorReviews != null
                  ? Center(child: Text(_errorReviews!, style: const TextStyle(color: Colors.red)))
                  : _reviews.isEmpty
                      ? const Center(child: Text('Aucun avis'))
                      : ListView.separated(
                          padding: EdgeInsets.all(context.horizontalPadding),
                          itemCount: _reviews.length,
                          separatorBuilder: (context, index) => SizedBox(height: context.fluidValue(minValue: 12, maxValue: 16)),
                          itemBuilder: (context, index) {
                            final review = _reviews[index];
                            return ReviewModerationCard(
                              review: review,
                              onModerate: (status) => _moderateReview(review.id, status),
                            );
                          },
                        ),
        ),
      ],
    );
  }

  Widget _buildMessagesTab() {
    return _isLoadingMessages
        ? const Center(child: CircularProgressIndicator())
        : _errorMessages != null
            ? Center(child: Text(_errorMessages!, style: const TextStyle(color: Colors.red)))
            : _messages.isEmpty
                ? const Center(child: Text('Aucun message'))
                : ListView.separated(
                    padding: EdgeInsets.all(context.horizontalPadding),
                    itemCount: _messages.length,
                    separatorBuilder: (context, index) => SizedBox(height: context.fluidValue(minValue: 12, maxValue: 16)),
                    itemBuilder: (context, index) {
                      final message = _messages[index];
                      return ContactMessageCard(
                        message: message,
                        onUpdateStatus: (status) => _updateMessageStatus(message.id, status),
                      );
                    },
                  );
  }
}
