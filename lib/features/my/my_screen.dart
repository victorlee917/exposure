import 'package:daily_exposures/constants/borders.dart';
import 'package:daily_exposures/constants/fonts.dart';
import 'package:daily_exposures/constants/paddings.dart';
import 'package:daily_exposures/constants/rvalues.dart';
import 'package:daily_exposures/constants/sizes.dart';
import 'package:daily_exposures/features/common/widgets/appbar_gradation.dart';
import 'package:daily_exposures/features/my/widgets/list_label.dart';
// import 'package:daily_exposures/features/username/change_username_screen.dart';
import 'package:daily_exposures/main.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:in_app_review/in_app_review.dart';
// import 'package:share_plus/share_plus.dart';

class MyScreen extends StatefulWidget {
  const MyScreen({super.key});

  @override
  State<MyScreen> createState() => _MyScreenState();
}

class _MyScreenState extends State<MyScreen> {
  // 스와이프 백 감지 변수
  static const double _edgeWidth = 24.0; // 왼쪽 엣지 폭
  static const double _triggerDx = 60.0; // 이동 임계
  static const double _triggerVx = 600.0; // 속도 임계(px/s)

  double _totalDx = 0.0;
  bool _eligible = false; // 엣지에서 시작했는지

  void _onDragStart(DragStartDetails d) {
    // 왼쪽 엣지(24px)에서만 제스처 시작 허용
    _eligible = d.globalPosition.dx <= _edgeWidth;
    _totalDx = 0.0;
  }

  void _onDragUpdate(DragUpdateDetails d) {
    if (!_eligible) return;
    _totalDx += d.delta.dx;
    // 충분히 이동하면 즉시 pop (바로 반환해 튕김 방지)
    if (_totalDx > _triggerDx) {
      _popIfPossible();
    }
  }

  void _onDragEnd(DragEndDetails d) {
    if (!_eligible) return;
    final vx = d.velocity.pixelsPerSecond.dx;
    if (vx > _triggerVx || _totalDx > _triggerDx) {
      _popIfPossible();
    } else {
      // 조건 미충족 → 아무 일 없음 (원위치)
    }
  }

  void _popIfPossible() {
    if (!mounted) return;
    // 중복 pop 방지
    _eligible = false;
    Navigator.of(context).maybePop();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(kToolbarHeight),
        child: AppBar(
          surfaceTintColor: Colors.transparent,
          leading: IconButton(
            icon: FaIcon(FontAwesomeIcons.chevronLeft),
            onPressed: () {
              Navigator.of(context).pop();
            },
          ),
          centerTitle: true,
          elevation: 0,
        ),
      ),
      body: Stack(
        children: [
          // 본문
          ListView(
            padding: const EdgeInsets.only(
              top: 0,
              bottom: Paddings.buttonVertical,
              left: Paddings.screentHorizontal,
              right: Paddings.screentHorizontal,
            ),
            children: [
              // const Text(
              //   "Hello,\nnickname",
              //   style: TextStyle(fontSize: 28, fontWeight: Fonts.weightHeavy),
              // ),
              // const SizedBox(height: 20),
              // ListTile(
              //   minTileHeight: Sizes.sizeButtonHeight,
              //   contentPadding: const EdgeInsets.symmetric(
              //     horizontal: Paddings.buttonHorizontal,
              //   ),
              //   shape: RoundedRectangleBorder(
              //     borderRadius: BorderRadius.circular(Rvalues.button),
              //     side: BorderSide(
              //       color: isSystemDarkMode
              //           ? Borders.lineColorDark
              //           : Borders.lineColorLight,
              //     ),
              //   ),
              //   title: const Text("exposure.link/nickname"),
              //   trailing: const FaIcon(FontAwesomeIcons.share, size: 16),
              //   onTap: () {
              //     Share.share("exposure.link/nickname");
              //   },
              // ),
              // const SizedBox(height: 20),
              // ListTile(
              //   contentPadding: const EdgeInsets.symmetric(horizontal: 4),
              //   title: const ListLabel(text: "Change nickname"),
              //   onTap: () {
              //     Navigator.of(context).push(
              //       MaterialPageRoute(
              //         builder: (context) => const ChangeUsernameScreen(),
              //       ),
              //     );
              //   },
              // ),
              ValueListenableBuilder(
                valueListenable: isDarkMode,
                builder: (context, value, child) {
                  return SwitchListTile.adaptive(
                    contentPadding: const EdgeInsets.symmetric(horizontal: 4),
                    title: const ListLabel(text: "Dark mode"),
                    value: value,
                    onChanged: (newValue) {
                      isDarkMode.value = newValue;
                    },
                  );
                },
              ),
              // ValueListenableBuilder<bool>( // 주석 처리된 코드
              //   valueListenable: isLeftHandedMode,
              //   builder: (context, isLeftHanded, child) {
              //     return SwitchListTile.adaptive(
              //       contentPadding: const EdgeInsets.symmetric(horizontal: 4),
              //       title: ListLabel(text: "Left-handed mode"),
              //       value: isLeftHanded,
              //       onChanged: (value) {
              //         isLeftHandedMode.value = value;
              //       },
              //     );
              //   },
              // ),
              ListTile(
                contentPadding: const EdgeInsets.symmetric(horizontal: 4),
                title: ListLabel(text: "Rate our App"),
                onTap: () async {
                  final InAppReview inAppReview = InAppReview.instance;
                  if (await inAppReview.isAvailable()) {
                    inAppReview.requestReview();
                  }
                },
              ),
              ListTile(
                contentPadding: const EdgeInsets.symmetric(horizontal: 4),
                title: ListLabel(text: "Exposure Instagram"),
                onTap: () {},
              ),
              // ListTile(
              //   contentPadding: const EdgeInsets.symmetric(horizontal: 4),
              //   title: ListLabel(text: "Privacy Policy"),
              //   onTap: () {},
              // ),
              // ListTile(
              //   contentPadding: const EdgeInsets.symmetric(horizontal: 4),
              //   title: ListLabel(text: "Terms of Service"),
              //   onTap: () {},
              // ),
              // Divider(
              //   color: isSystemDarkMode
              //       ? Borders.lineColorDark
              //       : Borders.lineColorLight,
              // ),
              // ListTile(
              //   contentPadding: const EdgeInsets.symmetric(horizontal: 4),
              //   title: ListLabel(text: "Logout"),
              //   onTap: () {},
              // ),
              // ListTile(
              //   contentPadding: const EdgeInsets.symmetric(horizontal: 4),
              //   title: ListLabel(
              //     text: "Delete Account",
              //     textColor: Colors.red,
              //   ),
              //   onTap: () {},
              // ),
            ],
          ),

          const Positioned(
            top: 0,
            left: 0,
            right: 0,
            child: AppbarGradation(
              height: 40, // 높이 조정 가능
              useThemeBg: true, // 테마 배경 → 투명
            ),
          ),
          // ✅ 왼쪽 엣지 스와이프 백 레이어 (상호작용 면적 24px)
          //   - 본문 터치와 충돌 최소화 위해 "엣지 영역"만 Hit
          //   - 한번 제스처를 잡으면 화면 어디로 드래그해도 이어짐
          Align(
            alignment: Alignment.centerLeft,
            child: SizedBox(
              width: _edgeWidth,
              height: double.infinity,
              child: GestureDetector(
                behavior: HitTestBehavior.translucent,
                onHorizontalDragStart: _onDragStart,
                onHorizontalDragUpdate: _onDragUpdate,
                onHorizontalDragEnd: _onDragEnd,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
