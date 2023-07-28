part of '../collection_screen.dart';

///某一类收藏品列表（作为卡片）
///（垂直排列：标题+若干收藏品，水平排列:收藏品）
class _CollectionListCard extends StatelessWidget with GetItMixin {
  _CollectionListCard(
      {Key? key,
      this.width,
      this.height,
      required this.data,
      required this.fromId})
      : super(key: key);

  final double? width;
  final double? height;
  final WonderData data;
  final String fromId;

  void _showDetails(BuildContext context, CollectibleData collectible) {
    context.push(ScreenPaths.artifact(collectible.artifactId));
    Future.delayed(300.ms).then((_) =>
        collectiblesLogic.setState(collectible.id, CollectibleState.explored));
  }

  @override
  Widget build(BuildContext context) {
    final states = watchX((CollectiblesLogic o) => o.statesById);
    List<CollectibleData> collectibles = collectiblesLogic.forWonder(data.type);
    debugPrint('_collection_list_card:width $width,height $height');
    return Center(
      child: SizedBox(
        ///若可能的话，让它的尺寸不受限制）
        width: width ?? double.infinity,
        height: height ?? double.infinity,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            /// Title
            Text(
              data.title.toUpperCase(),
              textAlign: TextAlign.left,
              style:
                  $styles.text.title1.copyWith(color: $styles.colors.offWhite),
            ),
            Gap($styles.insets.md),

            /// Images
            /// 这里用了Expanded以后，可以根据屏幕水平/垂直实际情况拉伸子widget高度
            Expanded(
              child: SeparatedRow(
                  separatorBuilder: () => Gap($styles.insets.sm),
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    ...collectibles.map((e) {
                      int state = states[e.id] ?? CollectibleState.lost;
                      return Flexible(
                        child: _CollectibleImage(
                          collectible: e,
                          state: state,
                          onPressed: (c) => _showDetails(context, c),
                          heroTag: e.id == fromId
                              ? 'collectible_image_$fromId'
                              : null,
                        ),
                      );
                    }).toList()
                  ]),
            )
          ],
        ),
      ),
    );
  }
}
