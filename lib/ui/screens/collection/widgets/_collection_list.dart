part of '../collection_screen.dart';

@immutable
class _CollectionList extends StatelessWidget with GetItMixin {
  _CollectionList({
    Key? key,
    this.onReset,
    required this.fromId,
    this.scrollKey,
  }) : super(key: key);

  final VoidCallback? onReset;
  final Key? scrollKey;
  final String fromId;

  WonderType? get scrollTargetWonder {
    CollectibleData? item;
    if (fromId.isEmpty) {
      item = collectiblesLogic.getFirstDiscoveredOrNull();
    } else {
      item = collectiblesLogic.fromId(fromId);
    }
    return item?.wonder;
  }

  @override
  Widget build(BuildContext context) {
    ///watchX:只监听CollectiblesLogic对象内statesById的变化
    watchX((CollectiblesLogic o) => o.statesById);
    List<WonderData> wonders = wondersLogic.all;
    bool vtMode = context.isLandscape == false;
    final scrollWonder = scrollTargetWonder;
    // Create list of collections that is shared by both hz and vt layouts
    ///创建一个支持水平和垂直布局的列表
    List<Widget> collections = [
      ///'...'表示仍是List中的元素？
      ...wonders.map((d) {
        return _CollectionListCard(
          key: d.type == scrollWonder ? scrollKey : null,
          height: vtMode ? 300 : 400,
          width: vtMode ? null : 600,
          fromId: fromId,
          data: d,
        );
      }).toList()
    ];
    // Scroll view adapts to scroll vertically or horizontally
    return SingleChildScrollView(
      scrollDirection: vtMode ? Axis.vertical : Axis.horizontal,
      child: Padding(
        ///所有收藏品外边距
        padding: EdgeInsets.all($styles.insets.lg),

        ///SeparatedFlex:封装了带分割线的Row/Column
        child: SeparatedFlex(
          direction: vtMode ? Axis.vertical : Axis.horizontal,
          mainAxisSize: MainAxisSize.min,
          separatorBuilder: () => Gap($styles.insets.lg),
          children: [
            ...collections,

            ///滑动到最底部，与按钮的间隔
            Gap($styles.insets.sm),
            if (kDebugMode) _buildResetBtn(context),
          ],
        ),
      ),
    );
  }

  Widget _buildResetBtn(BuildContext context) {
    Widget btn = AppBtn.from(
      onPressed: onReset ?? () {},
      text: $strings.collectionButtonReset,
      isSecondary: true,
      expand: true,
    );
    return AnimatedOpacity(
        opacity: onReset == null ? 0.25 : 1,
        duration: $styles.times.fast,
        child: btn);
  }
}
