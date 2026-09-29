import 'package:cached_network_image/cached_network_image.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:taal/core/app_config/app_strings.dart';
import 'package:taal/core/app_config/app_urls.dart';
import 'package:taal/core/di/service_locator.dart';
import 'package:taal/core/extensions/space_extension.dart';
import 'package:taal/core/helpers/api_error_message.dart';
import 'package:taal/core/widgets/appbar/logo_skip_appbar.dart';
import 'package:taal/design_system/theme/taala_tokens.dart';
import 'package:taal/features/usage_guides/data/models/usage_guide_model.dart';
import 'package:taal/features/usage_guides/data/repository/usage_guides_repository.dart';
import 'package:url_launcher/url_launcher.dart';

class UsageGuidesScreen extends StatefulWidget {
  const UsageGuidesScreen({super.key});

  @override
  State<UsageGuidesScreen> createState() => _UsageGuidesScreenState();
}

class _UsageGuidesScreenState extends State<UsageGuidesScreen> {
  bool _loading = true;
  String? _error;
  List<UsageGuideModel> _guides = const [];
  String? _expandedId;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    setState(() {
      _loading = true;
      _error = null;
    });
    final result = await getIt<UsageGuidesRepository>().fetchGuides();
    if (!mounted) return;
    result.fold(
      (error) => setState(() {
        _loading = false;
        _error = error.displayMessage;
      }),
      (data) => setState(() {
        _loading = false;
        _guides = data.items;
      }),
    );
  }

  Future<void> _openVideo(String? url) async {
    final trimmed = url?.trim();
    if (trimmed == null || trimmed.isEmpty) return;
    final uri = Uri.tryParse(trimmed);
    if (uri == null) return;
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    }
  }

  String _imageUrl(String? path) {
    if (path == null || path.isEmpty) return '';
    if (path.startsWith('http')) return path;
    return AppUrls.imageLink(path);
  }

  @override
  Widget build(BuildContext context) {
    final tokens = TaalaTokens.of(context);
    final lang = context.locale.languageCode;

    return Scaffold(
      appBar: CustomAppBar.backAppBar(
        title: AppStrings.usageGuidesTitle.tr(),
        centerTitle: true,
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : _error != null
              ? Center(
                  child: Padding(
                    padding: REdgeInsets.all(24),
                    child: Text(
                      ApiErrorMessage.resolve(_error),
                      textAlign: TextAlign.center,
                      style: TextStyle(color: tokens.error),
                    ),
                  ),
                )
              : _guides.isEmpty
                  ? Center(
                      child: Padding(
                        padding: REdgeInsets.all(24),
                        child: Text(
                          AppStrings.usageGuidesEmpty.tr(),
                          textAlign: TextAlign.center,
                          style: TextStyle(color: tokens.textSecondary),
                        ),
                      ),
                    )
                  : ListView.separated(
                      padding: REdgeInsets.fromLTRB(16, 16, 16, 24),
                      itemCount: _guides.length + 1,
                      separatorBuilder: (_, __) => 12.height,
                      itemBuilder: (context, index) {
                        if (index == 0) {
                          return Text(
                            AppStrings.usageGuidesSubtitle.tr(),
                            style: TextStyle(
                              fontSize: 13.sp,
                              color: tokens.textSecondary,
                              height: 1.5,
                            ),
                          );
                        }
                        final guide = _guides[index - 1];
                        final expanded = _expandedId == guide.id;
                        final thumb = guide.thumbnailImageUrl;

                        return Material(
                          color: tokens.surfaceMuted,
                          borderRadius: BorderRadius.circular(14.r),
                          child: InkWell(
                            borderRadius: BorderRadius.circular(14.r),
                            onTap: () => setState(
                              () => _expandedId =
                                  expanded ? null : guide.id,
                            ),
                            child: Padding(
                              padding: REdgeInsets.all(14),
                              child: Column(
                                crossAxisAlignment:
                                    CrossAxisAlignment.stretch,
                                children: [
                                  Row(
                                    children: [
                                      Expanded(
                                        child: Text(
                                          guide.titleForLocale(lang),
                                          style: TextStyle(
                                            fontWeight: FontWeight.w700,
                                            fontSize: 15.sp,
                                            color: tokens.textPrimary,
                                          ),
                                        ),
                                      ),
                                      Icon(
                                        expanded
                                            ? Icons.expand_less
                                            : Icons.expand_more,
                                        color: tokens.textSecondary,
                                      ),
                                    ],
                                  ),
                                  if (expanded) ...[
                                    12.height,
                                    if (thumb != null) ...[
                                      ClipRRect(
                                        borderRadius:
                                            BorderRadius.circular(10.r),
                                        child: AspectRatio(
                                          aspectRatio: 16 / 9,
                                          child: Stack(
                                            fit: StackFit.expand,
                                            children: [
                                              CachedNetworkImage(
                                                imageUrl: _imageUrl(thumb),
                                                fit: BoxFit.cover,
                                                errorWidget: (_, __, ___) =>
                                                    ColoredBox(
                                                  color: tokens.surface,
                                                  child: Icon(
                                                    Icons
                                                        .play_circle_outline,
                                                    size: 48.r,
                                                    color: tokens.primary,
                                                  ),
                                                ),
                                              ),
                                              if (guide.videoUrl?.isNotEmpty ==
                                                  true)
                                                Material(
                                                  color: Colors.black26,
                                                  child: InkWell(
                                                    onTap: () => _openVideo(
                                                      guide.videoUrl,
                                                    ),
                                                    child: Center(
                                                      child: Icon(
                                                        Icons
                                                            .play_circle_fill,
                                                        size: 56.r,
                                                        color: Colors.white,
                                                      ),
                                                    ),
                                                  ),
                                                ),
                                            ],
                                          ),
                                        ),
                                      ),
                                      10.height,
                                    ],
                                    if (guide.bodyForLocale(lang) != null)
                                      Text(
                                        guide.bodyForLocale(lang)!,
                                        style: TextStyle(
                                          fontSize: 14.sp,
                                          height: 1.55,
                                          color: tokens.textSecondary,
                                        ),
                                      ),
                                    if (guide.videoUrl?.isNotEmpty == true) ...[
                                      12.height,
                                      OutlinedButton.icon(
                                        onPressed: () =>
                                            _openVideo(guide.videoUrl),
                                        icon: const Icon(Icons.play_arrow),
                                        label: Text(
                                          AppStrings.usageGuidesWatchVideo
                                              .tr(),
                                        ),
                                      ),
                                    ],
                                  ],
                                ],
                              ),
                            ),
                          ),
                        );
                      },
                    ),
    );
  }
}
