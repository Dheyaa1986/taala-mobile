import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:taal/core/app_config/app_strings.dart';
import 'package:taal/design_system/theme/taala_tokens.dart';
import 'package:taal/core/di/service_locator.dart';
import 'package:taal/core/widgets/appbar/logo_skip_appbar.dart';
import 'package:taal/features/app_info/data/model/app_public_info_model.dart';
import 'package:taal/features/app_info/data/repository/app_public_info_repository.dart';

class LegalDocumentScreen extends StatefulWidget {
  const LegalDocumentScreen({
    super.key,
    required this.documentType,
  });

  final LegalDocumentType documentType;

  @override
  State<LegalDocumentScreen> createState() => _LegalDocumentScreenState();
}

class _LegalDocumentScreenState extends State<LegalDocumentScreen> {
  AppPublicInfoModel? _info;
  bool _loading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    final result = await getIt<AppPublicInfoRepository>().getPublicInfo();
    if (!mounted) return;
    result.fold(
      (error) => setState(() {
        _loading = false;
        _error = error.message;
      }),
      (info) => setState(() {
        _loading = false;
        _info = info;
      }),
    );
  }

  String get _title {
    switch (widget.documentType) {
      case LegalDocumentType.terms:
        return AppStrings.termsAndConditions.tr();
      case LegalDocumentType.privacy:
        return AppStrings.privacyPolicy.tr();
    }
  }

  String? _content(BuildContext context) {
    final info = _info;
    if (info == null) return null;
    final lang = context.locale.languageCode;
    switch (widget.documentType) {
      case LegalDocumentType.terms:
        return info.termsForLocale(lang);
      case LegalDocumentType.privacy:
        return info.privacyForLocale(lang);
    }
  }

  @override
  Widget build(BuildContext context) {
    final content = _content(context);

    return Scaffold(
      appBar: CustomAppBar.backAppBar(
        title: _title,
        centerTitle: true,
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : _error != null
              ? Center(
                  child: Padding(
                    padding: REdgeInsets.all(24),
                    child: Text(
                      _error!,
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        color: TaalaTokens.of(context).error,
                        fontSize: 14.sp,
                      ),
                    ),
                  ),
                )
              : SingleChildScrollView(
                  padding: REdgeInsets.all(16),
                  child: SelectableText(
                    (content == null || content.trim().isEmpty)
                        ? AppStrings.legalDocumentEmpty.tr()
                        : content,
                    style: TextStyle(
                      fontSize: 14.sp,
                      height: 1.6,
                      color: TaalaTokens.of(context).textPrimary,
                    ),
                  ),
                ),
    );
  }
}
