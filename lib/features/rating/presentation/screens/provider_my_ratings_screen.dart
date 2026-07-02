import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:taal/core/app_config/app_strings.dart';
import 'package:taal/core/di/service_locator.dart';
import 'package:taal/core/extensions/space_extension.dart';
import 'package:taal/core/widgets/appbar/logo_skip_appbar.dart';
import 'package:taal/features/profile/data/repository/profile_repository.dart';
import 'package:taal/features/rating/data/models/provider_ratings_model.dart';
import 'package:taal/features/rating/data/models/review_model.dart';
import 'package:taal/features/rating/presentation/widgets/provider_rating_view.dart';

class ProviderMyRatingsScreen extends StatefulWidget {
  const ProviderMyRatingsScreen({super.key});

  @override
  State<ProviderMyRatingsScreen> createState() =>
      _ProviderMyRatingsScreenState();
}

class _ProviderMyRatingsScreenState extends State<ProviderMyRatingsScreen> {
  final _scrollController = ScrollController();
  ProviderRatingsModel? _summary;
  final List<ReviewModel> _reviews = [];
  int _currentPage = 1;
  int _totalPages = 1;
  bool _loading = true;
  bool _loadingMore = false;
  String? _error;

  @override
  void initState() {
    super.initState();
    _loadRatings(reset: true);
    _scrollController.addListener(_onScroll);
  }

  @override
  void dispose() {
    _scrollController
      ..removeListener(_onScroll)
      ..dispose();
    super.dispose();
  }

  void _onScroll() {
    if (_loadingMore || _currentPage >= _totalPages) return;
    if (_scrollController.position.pixels >=
        _scrollController.position.maxScrollExtent - 200) {
      _loadRatings();
    }
  }

  Future<void> _loadRatings({bool reset = false}) async {
    if (reset) {
      setState(() {
        _loading = true;
        _error = null;
        _currentPage = 1;
        _totalPages = 1;
        _reviews.clear();
        _summary = null;
      });
    } else {
      if (_loadingMore || _currentPage >= _totalPages) return;
      setState(() => _loadingMore = true);
    }

    final page = reset ? 1 : _currentPage + 1;
    final result = await getIt<ProfileRepository>().getMyProviderRatings(
      page: page,
      limit: 10,
    );

    if (!mounted) return;

    result.fold(
      (error) {
        setState(() {
          _loading = false;
          _loadingMore = false;
          _error = error.message;
        });
      },
      (pageModel) {
        setState(() {
          _summary = pageModel.summary;
          if (reset) {
            _reviews
              ..clear()
              ..addAll(pageModel.reviews);
          } else {
            _reviews.addAll(pageModel.reviews);
          }
          _currentPage = pageModel.currentPage;
          _totalPages = pageModel.totalPages;
          _loading = false;
          _loadingMore = false;
          _error = null;
        });
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CustomAppBar.backAppBar(
        title: AppStrings.myRatings.tr(),
        centerTitle: true,
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : _error != null
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(_error!),
                      16.height,
                      TextButton(
                        onPressed: () => _loadRatings(reset: true),
                        child: Text(AppStrings.retry.tr()),
                      ),
                    ],
                  ),
                )
              : RefreshIndicator(
                  onRefresh: () => _loadRatings(reset: true),
                  child: ProviderRatingView(
                    scrollController: _scrollController,
                    summary: _summary ??
                        const ProviderRatingsModel(
                          totalRatings: 0,
                          totalReviews: 0,
                          ratings: [0, 0, 0, 0, 0],
                        ),
                    reviews: _reviews,
                    isLoadingMore: _loadingMore,
                  ),
                ),
    );
  }
}
