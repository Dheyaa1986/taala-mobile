import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../app_config/app_colors.dart';

class AnimatedFavButton extends StatefulWidget {
  const AnimatedFavButton({super.key});

  @override
  _AnimatedFavButtonState createState() => _AnimatedFavButtonState();
}

class _AnimatedFavButtonState extends State<AnimatedFavButton> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;
  bool isFav = false;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
      lowerBound: 0.7,
      upperBound: 1.5,
    );

    _scaleAnimation = Tween<double>(begin: 0.7, end: 1.2).animate(
      CurvedAnimation(
        parent: _controller,
        curve: Curves.easeOut,
      ),
    );
  }

  void _toggleFav() {
    setState(() {
      isFav = !isFav;
    });

    _controller.forward().then((_) => _controller.reverse());
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: _toggleFav,
      child: ScaleTransition(
        scale: _scaleAnimation,
        child: Center(
          child: Container(
            padding: const EdgeInsets.all(6),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(6.r),
              color: AppColors.iconButtonBG.withOpacity(0.5),
            ),
            child:Center(
              child: Icon(
               Icons.favorite ,
                color: isFav ? Colors.red : Colors.white,
                size: 20.r,
              ),
            ),
          ),
        ) ,
      ),
    );
  }
}
