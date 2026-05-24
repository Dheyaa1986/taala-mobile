import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:shimmer/shimmer.dart';

class CustomShimmerWidget extends StatelessWidget {
  const CustomShimmerWidget(
      {super.key,
      this.child,
      this.shape,
      this.height,
      this.width,
      this.radius,
      this.borderRadius,
      this.borderColor});
  final Widget? child;
  final double? height;
  final double? width;
  final double? radius;
  final BorderRadiusGeometry? borderRadius;
  final Color? borderColor;
  final BoxShape? shape;
  @override
  Widget build(BuildContext context) {
    return Shimmer.fromColors(
      baseColor: Colors.grey[200]!,
      highlightColor: Colors.grey[100]!,
      child: child ??
          CustomLoadingShimmerContainer(
              borderColor: borderColor,
              borderRadius: borderRadius,
              shape: shape,
              height: height,
              width: width,
              radius: radius),
    );
  }
}

class CustomLoadingShimmerContainer extends StatelessWidget {
  const CustomLoadingShimmerContainer(
      {super.key,
      required this.height,
      required this.width,
      this.shape,
      this.borderRadius,
      this.borderColor,
      required this.radius});
  final double? height;
  final double? width;
  final double? radius;
  final BorderRadiusGeometry? borderRadius;
  final BoxShape? shape;
  final Color? borderColor;
  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        border: borderColor != null ? Border.all(color: borderColor!) : null,
        shape: shape ?? BoxShape.rectangle,
        color: Theme.of(context).cardColor,
        borderRadius:
            shape != null ? null :borderRadius?? BorderRadius.circular(radius ?? 4.r),
      ),
      height: height,
      width: width,
    );
  }
}
