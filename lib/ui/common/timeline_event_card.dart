import 'package:wonders/common_libs.dart';
import 'package:wonders/logic/common/string_utils.dart';
import 'package:wonders/ui/common/themed_text.dart';

///WonderEvents里列表的单个卡片
class TimelineEventCard extends StatelessWidget {
  const TimelineEventCard(
      {Key? key, required this.year, required this.text, this.darkMode = false})
      : super(key: key);
  final int year;
  final String text;
  final bool darkMode;

  @override
  Widget build(BuildContext context) {
    return MergeSemantics(
      child: Padding(
        padding: EdgeInsets.only(bottom: $styles.insets.sm),
        child: DefaultTextColor(
          color: darkMode ? Colors.white : Colors.black,
          child: Container(
            color:
                darkMode ? $styles.colors.greyStrong : $styles.colors.offWhite,
            padding: EdgeInsets.all($styles.insets.sm),

            ///IntrinsicHeight：内建高度：根据子控件的内容调整决定高度
            child: IntrinsicHeight(
              child: Row(
                children: [
                  /// Date
                  /// 时间
                  SizedBox(
                    width: 75,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('${year.abs()}',
                            style: $styles.text.h3.copyWith(
                                fontWeight: FontWeight.w400, height: 1)),
                        Text(StringUtils.getYrSuffix(year),
                            style: $styles.text.bodySmall),
                      ],
                    ),
                  ),

                  /// Divider
                  /// 分割线
                  Container(
                      width: 1,
                      color: darkMode ? Colors.white : $styles.colors.black),

                  Gap($styles.insets.sm),

                  /// Text content
                  /// 卡片里的正文内容，用Expand防止溢出(且实现了可换行)
                  Expanded(
                    child: Focus(child: Text(text, style: $styles.text.body)),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
