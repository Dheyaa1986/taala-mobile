import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:taal/core/app_config/app_strings.dart';
import 'package:taal/core/di/service_locator.dart';
import 'package:taal/core/extensions/space_extension.dart';
import 'package:taal/core/validations/validators.dart';
import 'package:taal/core/widgets/buttons/custom_button.dart';
import 'package:taal/core/widgets/fields/custom_text_field.dart';
import 'package:taal/features/home/provider/presentation/widgets/sheet_header.dart';
import 'package:taal/features/support/data/repository/support_ticket_repository.dart';

Future<void> showSupportTicketSheet(BuildContext context) {
  return showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
    ),
    builder: (_) => const SupportTicketSheet(),
  );
}

class SupportTicketSheet extends StatefulWidget {
  const SupportTicketSheet({super.key});

  @override
  State<SupportTicketSheet> createState() => _SupportTicketSheetState();
}

class _SupportTicketSheetState extends State<SupportTicketSheet> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _descriptionController = TextEditingController();
  String _type = 'complaint';
  bool _isSubmitting = false;

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _isSubmitting = true);

    final result = await getIt<SupportTicketRepository>().submitTicket(
      title: _titleController.text.trim(),
      description: _descriptionController.text.trim(),
      type: _type,
    );

    if (!mounted) return;
    setState(() => _isSubmitting = false);

    result.fold(
      (error) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(error.message)),
        );
      },
      (_) {
        context.pop();
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(AppStrings.supportTicketSent.tr())),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final maxHeight = MediaQuery.of(context).size.height * 0.9;

    return Padding(
      padding: EdgeInsets.only(
        left: 16.w,
        right: 16.w,
        top: 20.h,
        bottom: MediaQuery.of(context).viewInsets.bottom + 20.h,
      ),
      child: ConstrainedBox(
        constraints: BoxConstraints(maxHeight: maxHeight),
        child: SingleChildScrollView(
          child: Form(
            key: _formKey,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
            SheetHeader(title: AppStrings.submitSupportTicket.tr()),
            16.height,
            Row(
              children: [
                Expanded(
                  child: ChoiceChip(
                    label: Text(AppStrings.complaint.tr()),
                    selected: _type == 'complaint',
                    onSelected: (_) => setState(() => _type = 'complaint'),
                  ),
                ),
                8.width,
                Expanded(
                  child: ChoiceChip(
                    label: Text(AppStrings.request.tr()),
                    selected: _type == 'request',
                    onSelected: (_) => setState(() => _type = 'request'),
                  ),
                ),
              ],
            ),
            16.height,
            CustomTextField(
              controller: _titleController,
              label: AppStrings.supportTicketTitle.tr(),
              hint: AppStrings.supportTicketTitleHint.tr(),
              validator: CustomValidators.validateEmpty,
            ),
            16.height,
            CustomTextField(
              controller: _descriptionController,
              label: AppStrings.supportTicketDescription.tr(),
              hint: AppStrings.supportTicketDescriptionHint.tr(),
              maxLines: 4,
              validator: CustomValidators.validateEmpty,
            ),
            20.height,
                _isSubmitting
                    ? const CircularProgressIndicator()
                    : CustomButton(
                        text: AppStrings.send.tr(),
                        onTap: _submit,
                      ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
