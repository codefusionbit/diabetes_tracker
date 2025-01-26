import 'dart:math' as math;
import 'package:diabetes_tracking/codefusionbit.dart';

class HorizontalListView extends StatefulWidget {
  /// The `HorizontalListView` widget allows you to create a horizontal list view
  /// with customizable properties such as the number of items per row, spacing
  /// between items, and scroll control. You can populate the list either by
  /// providing a predefined list of children or by using a builder function to
  /// create each item dynamically.
  ///
  /// [crossAxisCount] specifies the number of items to display per row.
  /// [crossAxisSpacing] sets the spacing between items in the same row.
  /// [controller] is an optional scroll controller to control the scroll behavior.
  /// [alignment] defines the alignment of items within the rows (default is center).
  /// [children] is a list of child widgets
  ///
  /// Example usage:
  ///
  /// ```
  /// HorizontalListView(
  ///   crossAxisCount: 2,
  ///   crossAxisSpacing: 8.0,
  ///   controller: myController,
  ///   children: [
  ///     // List of child widgets
  ///     // ...
  ///   ],
  /// )
  /// ```
  HorizontalListView({
    required this.crossAxisCount,
    required this.crossAxisSpacing,
    this.controller,
    this.alignment = CrossAxisAlignment.center,
    required this.children,
    super.key,
  })  : itemCount = children!.length,
        itemBuilder = null;

  /// Creates a `HorizontalListView` using a builder function.
  ///
  /// [crossAxisCount] specifies the number of items to display per row.
  /// [crossAxisSpacing] sets the spacing between items in the same row.
  /// [controller] is an optional scroll controller to control the scroll behavior.
  /// [alignment] defines the alignment of items within the rows (default is center).
  /// [itemCount] is the total number of items in the list.
  /// [itemBuilder] is a callback function to build each item widget based on the index.
  ///
  /// Example usage:
  ///
  /// ```dart
  /// HorizontalListView.builder(
  ///   crossAxisCount: 2,
  ///   crossAxisSpacing: 8.0,
  ///   controller: myController,
  ///   itemCount: itemCount,
  ///   itemBuilder: (context, index) {
  ///     // Build each item dynamically based on the index
  ///     return MyCustomItemWidget(index: index);
  ///   },
  /// )
  /// ```
  const HorizontalListView.builder({
    required this.crossAxisCount,
    this.crossAxisSpacing = 0,
    this.controller,
    this.alignment = CrossAxisAlignment.center,
    required this.itemCount,
    required this.itemBuilder,
    super.key,
  }) : children = null;

  /// [crossAxisCount] specifies the number of items to display per row.
  final int crossAxisCount;

  /// [crossAxisSpacing] sets the spacing between items in the same row.
  final double crossAxisSpacing;

  /// [alignment] defines the alignment of items within the rows (default is center).
  final CrossAxisAlignment? alignment;

  /// [controller] is an optional scroll controller to control the scroll behavior.
  final HorizontalListViewController? controller;

  /// [itemCount] is the total number of items in the list.
  final int itemCount;

  /// [children] is a list of child widgets.
  final List<Widget>? children;

  /// [itemBuilder] is a callback function to build each item widget.
  final Widget Function(BuildContext context, int index)? itemBuilder;

  @override
  State<HorizontalListView> createState() => _HorizontalListViewState();
}

class _HorizontalListViewState extends State<HorizontalListView> {
  void rebuildAllChildren(BuildContext context) {
    void rebuild(Element el) {
      el.markNeedsBuild();
      el.visitChildren(rebuild);
    }

    (context as Element).visitChildren(rebuild);
  }

  Key _key = UniqueKey();

  int _computeActualChildCount(int itemCount) {
    return math.max(0, itemCount * 2 - 1);
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      key: _key,
      builder: (context, constraints) {
        double snapSize = constraints.maxWidth + widget.crossAxisSpacing;

        SnapScrollSize scrollPhysics = SnapScrollSize(snapSize: snapSize);

        if (!_key.toString().contains(snapSize.toString())) {
          Future.delayed(Duration.zero, () {
            setState(() {
              rebuildAllChildren(context);
              _key =  Key('snap-$snapSize');
            });
          });
        }

        if (widget.controller != null) {
          widget.controller!.snapSize = snapSize;
        }

        double itemWidth = (constraints.maxWidth -
                ((widget.crossAxisCount - 1) * widget.crossAxisSpacing)) /
            widget.crossAxisCount;

        return SingleChildScrollView(
          controller: widget.controller,
          physics: scrollPhysics,
          scrollDirection: Axis.horizontal,
          child: Row(
            crossAxisAlignment: widget.alignment ?? CrossAxisAlignment.end,
            children: List.generate(
              _computeActualChildCount(widget.itemCount),
              (index) {
                if (index.isEven) {
                  return SizedBox(
                    width: itemWidth,
                    child: widget.children != null
                        ? widget.children![index ~/ 2]
                        : widget.itemBuilder!.call(context, index ~/ 2),
                  );
                } else {
                  return SizedBox(width: widget.crossAxisSpacing);
                }
              },
            ),
          ),
        );
      },
    );
  }
}

/// Custom scroll controller for controlling the horizontal list view's behavior.
///
/// The `HorizontalListViewController` provides additional functionality to
/// control and interact with the `HorizontalListView`. You can use it to
/// animate scrolling to a specific page, determine the current visible page,
/// and get the total number of pages in the list.
///
/// Example usage:
///
/// ```dart
/// HorizontalListViewController myController = HorizontalListViewController();
/// myController.animateToPage(2, duration: Duration(milliseconds: 500), curve: Curves.ease);
/// int currentPage = myController.currentPage;
/// int totalPages = myController.pageLength;
/// ```
class HorizontalListViewController extends ScrollController {
  HorizontalListViewController() : super();

  /// Animates the scroll view to a specific page with [duration] and [curve].
  ///
  /// [page] is the target page number.
  Future<void> animateToPage(int page,
      {required Duration duration, required Curve curve}) {
    double offset = _snapSize * page;

    if (page <= 0) {
      page = 0;
      offset = position.minScrollExtent;
    }
    if (page >= pageLenght) {
      page = pageLenght;
      offset = position.maxScrollExtent;
    }

    return super.animateTo(offset, duration: duration, curve: curve);
  }

  /// Gets the current visible page.
  int get currentPage {
    String roundedPage = (position.pixels / _snapSize).toStringAsFixed(1);
    int parsedNumber = double.parse(roundedPage).ceil();
    return parsedNumber;
  }

  /// Gets the total number of pages in the list.
  int get pageLenght => (position.maxScrollExtent / _snapSize).ceil();

  double _snapSize = 0;

  /// Sets the snap size for scrolling.
  set snapSize(double value) => _snapSize = value;
}
