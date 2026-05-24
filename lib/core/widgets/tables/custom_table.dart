import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class CustomTable extends StatelessWidget {
  final CustomTableRow headers;
  final List<CustomTableRow> rows;
  final Border? border;
  final BorderRadiusGeometry? borderRadius;
  final Color? backgroundColor, rowSeparatorColor, columnSeparatorColor;
  final double? rowSeparatorHeight, columnSeparatorWidth;
  final bool showRowSeparator, showColumnSeparator;
  const CustomTable({
    super.key,
    required this.headers,
    required this.rows,
    this.border,
    this.borderRadius,
    this.backgroundColor,
    this.rowSeparatorColor,
    this.columnSeparatorColor,
    this.rowSeparatorHeight,
    this.columnSeparatorWidth,
    this.showRowSeparator = false,
    this.showColumnSeparator = false,
  })
  // : assert(headers.cells.isNotEmpty, 'Headers must have at least one cell'),
  //   assert(
  //       rows.isNotEmpty &&
  //           rows
  //                   .where((e) => e.cells.length == headers.cells.length)
  //                   .length <
  //               rows.length,
  //       'Rows must have the same number of cells as headers')
  ;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: backgroundColor,
        border: border,
        borderRadius: borderRadius,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          CustomTableRow(
            cells: headers.cells,
            color: headers.color,
            cellHeight: headers.cellHeight,
            alignment: headers.alignment,
            showSeparator: showColumnSeparator,
            separatorWidth: columnSeparatorWidth,
            separatorColor: columnSeparatorColor,
          ),
          if (showRowSeparator)
            Divider(
              color: rowSeparatorColor,
              height: rowSeparatorHeight,
            ),
          ...rows.map(
            (e) => Column(
              children: [
                CustomTableRow(
                  cells: e.cells,
                  color: e.color,
                  cellHeight: e.cellHeight,
                  alignment: e.alignment,
                  showSeparator: showColumnSeparator,
                  separatorWidth: columnSeparatorWidth,
                  separatorColor: columnSeparatorColor,
                ),
                if (showRowSeparator && e != rows.last)
                  Divider(
                    color: rowSeparatorColor,
                    height: rowSeparatorHeight,
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class CustomTableRow extends StatelessWidget {
  final List<CustomTableCell> cells;
  final Color? color;
  final double? cellHeight, separatorWidth;
  final bool showSeparator;
  final Color? separatorColor;
  final AlignmentGeometry? alignment;
  const CustomTableRow({
    super.key,
    required this.cells,
    this.color,
    this.cellHeight,
    this.alignment,
    this.showSeparator = false,
    this.separatorWidth,
    this.separatorColor,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      color: color,
      height: cellHeight ?? 58.h,
      child: Row(
        children: [
          for (var i = 0; i < cells.length; i++) ...[
            Expanded(
              child: Align(
                alignment: alignment ?? Alignment.center,
                child: cells[i],
              ),
            ),
            if (showSeparator && i != cells.length - 1)
              VerticalDivider(
                color: separatorColor,
                width: separatorWidth,
              ),
          ],
        ],
      ),
    );
  }
}

class CustomTableCell extends StatelessWidget {
  final Widget content;
  const CustomTableCell({super.key, required this.content});

  @override
  Widget build(BuildContext context) {
    return FittedBox(fit: BoxFit.scaleDown, child: content);
  }
}
