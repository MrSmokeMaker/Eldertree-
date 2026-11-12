import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../../../data/models/member_model.dart';
import '../../../../data/models/enums.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../../../profile/presentation/profile_screen.dart';

class MemberNodeWidget extends StatefulWidget {
  final MemberModel member;
  final bool isSelected;
  final bool isVisible;
  final bool isHighlighted;
  final String branchSize; // 'large', 'medium', 'small'
  final bool isFlipped;
  final VoidCallback onTap;
  final Function(String relationType) onAddTap;

  const MemberNodeWidget({
    super.key,
    required this.member,
    required this.isSelected,
    required this.isVisible,
    this.isHighlighted = false,
    this.branchSize = 'medium',
    this.isFlipped = false,
    required this.onTap,
    required this.onAddTap,
  });

  @override
  State<MemberNodeWidget> createState() => _MemberNodeWidgetState();
}

class _MemberNodeWidgetState extends State<MemberNodeWidget> {
  bool _isPressed = false;

  bool get _isDeceased => widget.member.deathDate != null;

  bool get _isBirthday {
    if (widget.member.birthDate == null) return false;
    final now = DateTime.now();
    return widget.member.birthDate!.day == now.day &&
        widget.member.birthDate!.month == now.month;
  }

  String get _yearsText {
    final b = widget.member.birthDate?.year;
    final d = widget.member.deathDate?.year;
    if (b == null) return '';
    if (d != null) return '$b — $d';
    return '$b г.';
  }

  @override
  Widget build(BuildContext context) {
    const goldPrimary = Color(0xFFD4AF37);
    const goldLight = Color(0xFFF3E5AB);

    // Параметры геометрии в зависимости от размера ветви
    final double nodeWidth;
    final double nodeHeight;
    final double frameSize;
    final double frameLeft;
    final double frameTop;
    final double plaqueWidth;
    final double plaqueLeft;
    final double plaqueTop;
    final String assetName;

    switch (widget.branchSize) {
      case 'large':
        nodeWidth = 176.0;
        nodeHeight = 184.0;
        frameSize = 70.0;
        assetName = 'assets/branches/branch_large.png';
        if (widget.isFlipped) {
          frameLeft = 24.0;
          plaqueLeft = 10.0;
        } else {
          frameLeft = 82.0;
          plaqueLeft = 66.0;
        }
        frameTop = 58.0;
        plaqueWidth = 100.0;
        plaqueTop = 134.0;
        break;
      case 'small':
        nodeWidth = 130.0;
        nodeHeight = 142.0;
        frameSize = 50.0;
        assetName = 'assets/branches/branch_small.png';
        if (widget.isFlipped) {
          frameLeft = 18.0;
          plaqueLeft = 4.0;
        } else {
          frameLeft = 62.0;
          plaqueLeft = 50.0;
        }
        frameTop = 46.0;
        plaqueWidth = 76.0;
        plaqueTop = 100.0;
        break;
      case 'medium':
      default:
        nodeWidth = 150.0;
        nodeHeight = 158.0;
        frameSize = 60.0;
        assetName = 'assets/branches/branch_medium.png';
        if (widget.isFlipped) {
          frameLeft = 20.0;
          plaqueLeft = 6.0;
        } else {
          frameLeft = 70.0;
          plaqueLeft = 56.0;
        }
        frameTop = 50.0;
        plaqueWidth = 88.0;
        plaqueTop = 114.0;
        break;
    }

    final frameCenter = Offset(
      frameLeft + frameSize / 2,
      frameTop + frameSize / 2,
    );

    return AnimatedOpacity(
      opacity: widget.isVisible ? 1.0 : 0.0,
      duration: const Duration(milliseconds: 500),
      curve: Curves.easeInOut,
      child: AnimatedScale(
        scale: widget.isVisible ? 1.0 : 0.85,
        duration: const Duration(milliseconds: 500),
        curve: Curves.easeInOut,
        child: SizedBox(
          width: nodeWidth,
          height: nodeHeight,
          child: Stack(
            clipBehavior: Clip.none,
            alignment: Alignment.center,
            children: [
              // Всплывающие золотые печати управления при выборе узла
              if (widget.isSelected) ...[
                _buildAddBtn(
                  frameCenter,
                  const Offset(0, -78),
                  'parent',
                  Icons.account_tree_outlined,
                  'Родитель (к корням)',
                ),
                _buildAddBtn(
                  frameCenter,
                  const Offset(0, 78),
                  'child',
                  Icons.child_care_outlined,
                  'Потомок (в крону)',
                ),
                _buildAddBtn(
                  frameCenter,
                  Offset(widget.isFlipped ? -78 : 78, 0),
                  'spouse',
                  Icons.favorite_rounded,
                  'Супруг(а)',
                ),
                // Кнопка быстрого перехода в карточку летописи
                Positioned(
                  left: frameCenter.dx - 18 + (widget.isFlipped ? 78 : -78),
                  top: frameCenter.dy - 18,
                  child: Tooltip(
                    message: 'Открыть летопись / профиль',
                    child: GestureDetector(
                      onTap: () {
                        HapticFeedback.lightImpact();
                        ProfileScreen.show(context, widget.member);
                      },
                      child: Container(
                        width: 36,
                        height: 36,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          gradient: const LinearGradient(
                            colors: [goldLight, goldPrimary],
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                          ),
                          boxShadow: [
                            BoxShadow(
                              color: goldPrimary.withValues(alpha: 0.6),
                              blurRadius: 10,
                              offset: const Offset(0, 3),
                            ),
                          ],
                          border: Border.all(color: Colors.white, width: 1.5),
                        ),
                        child: const Icon(Icons.menu_book_rounded,
                            size: 18, color: Color(0xFF1A1A1A)),
                      ),
                    ),
                  ),
                ),
              ],

              // Основное тело ветви с рамкой и табличкой
              GestureDetector(
                onDoubleTap: () {
                  HapticFeedback.lightImpact();
                  ProfileScreen.show(context, widget.member);
                },
                onTapDown: (_) {
                  HapticFeedback.selectionClick();
                  setState(() => _isPressed = true);
                },
                onTapUp: (_) {
                  HapticFeedback.lightImpact();
                  setState(() => _isPressed = false);
                  if (widget.isSelected) {
                    ProfileScreen.show(context, widget.member);
                  } else {
                    widget.onTap();
                  }
                },
                onTapCancel: () => setState(() => _isPressed = false),
                child: AnimatedScale(
                  scale: _isPressed ? 0.96 : (widget.isSelected ? 1.05 : 1.0),
                  duration: const Duration(milliseconds: 160),
                  curve: Curves.easeOutBack,
                  child: Stack(
                    children: [
                      // 1. Фотография или гербовый силуэт под рамкой
                      Positioned(
                        left: frameLeft + 4,
                        top: frameTop + 4,
                        width: frameSize - 8,
                        height: frameSize - 8,
                        child: Container(
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(frameSize * 0.16),
                            boxShadow: [
                              if (widget.isSelected || widget.isHighlighted)
                                BoxShadow(
                                  color: goldPrimary.withValues(alpha: 0.8),
                                  blurRadius: 16,
                                  spreadRadius: 2,
                                ),
                            ],
                          ),
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(frameSize * 0.16),
                            child: _buildAvatar(frameSize - 8),
                          ),
                        ),
                      ),

                      // 2. Ассет дубовой ветви с золотой рамкой
                      Positioned.fill(
                        child: Transform.flip(
                          flipX: widget.isFlipped,
                          child: Image.asset(
                            assetName,
                            fit: BoxFit.contain,
                            errorBuilder: (ctx, err, stack) =>
                                _buildFallbackBranch(nodeWidth, nodeHeight),
                          ),
                        ),
                      ),

                      // 3. Пергаментная подвесная табличка с именем и датами
                      Positioned(
                        left: plaqueLeft,
                        top: plaqueTop,
                        width: plaqueWidth,
                        child: _buildParchmentPlaque(),
                      ),

                      // Иконка вечной памяти
                      if (_isDeceased)
                        Positioned(
                          left: frameLeft + 6,
                          top: frameTop + 6,
                          child: Container(
                            padding: const EdgeInsets.all(2),
                            decoration: BoxDecoration(
                              color: Colors.black.withValues(alpha: 0.6),
                              shape: BoxShape.circle,
                            ),
                            child: const Icon(
                              Icons.history_edu,
                              size: 11,
                              color: Color(0xFFF3E5AB),
                            ),
                          ),
                        ),

                      // Именинная золотая звёздочка
                      if (_isBirthday)
                        Positioned(
                          left: frameLeft + frameSize - 16,
                          top: frameTop + 4,
                          child: const Icon(
                            Icons.auto_awesome,
                            size: 14,
                            color: goldPrimary,
                          ),
                        ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  /// Аватар персоны или антикварный силуэт
  Widget _buildAvatar(double size) {
    if (widget.member.avatarUrl != null &&
        widget.member.avatarUrl!.isNotEmpty) {
      return CachedNetworkImage(
        imageUrl: widget.member.avatarUrl!,
        fit: BoxFit.cover,
        errorWidget: (c, u, e) => _buildDefaultSilhouette(size),
      );
    }
    return _buildDefaultSilhouette(size);
  }

  Widget _buildDefaultSilhouette(double size) {
    final isMale = widget.member.gender == Gender.male;
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: widget.member.deathDate != null
              ? const [Color(0xFF6B7280), Color(0xFF374151)]
              : (isMale
                  ? const [Color(0xFF8B6B42), Color(0xFF533E26)]
                  : const [Color(0xFFA67C52), Color(0xFF66482D)]),
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
      ),
      child: Center(
        child: Icon(
          isMale ? Icons.person_rounded : Icons.person_3_rounded,
          size: size * 0.65,
          color: const Color(0xFFF3E5AB).withValues(alpha: 0.9),
        ),
      ),
    );
  }

  /// Пергаментная табличка в антикварном стиле референса
  Widget _buildParchmentPlaque() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 3),
      decoration: BoxDecoration(
        color: const Color(0xFFF5EEDB),
        borderRadius: BorderRadius.circular(6),
        border: Border.all(
          color: const Color(0xFF8B6B42),
          width: 1.1,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.28),
            blurRadius: 5,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            '${widget.member.firstName} ${widget.member.lastName ?? ''}'.trim(),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            textAlign: TextAlign.center,
            style: const TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.bold,
              color: Color(0xFF26190E),
              fontFamily: 'serif',
              letterSpacing: 0.2,
            ),
          ),
          if (_yearsText.isNotEmpty)
            Padding(
              padding: const EdgeInsets.only(top: 1),
              child: Text(
                _yearsText,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontSize: 9.5,
                  fontWeight: FontWeight.w600,
                  color: Color(0xFF5E452E),
                  fontFamily: 'serif',
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildFallbackBranch(double w, double h) {
    return Container(
      width: w,
      height: h,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFD4AF37), width: 1.5),
      ),
    );
  }

  /// Золотая сургучная печать-кнопка для добавления родственников
  Widget _buildAddBtn(
    Offset center,
    Offset offset,
    String type,
    IconData icon,
    String tooltip,
  ) {
    const goldPrimary = Color(0xFFD4AF37);
    const goldLight = Color(0xFFF7E7B4);
    const goldDark = Color(0xFF9E7710);

    return Positioned(
      left: center.dx - 18 + offset.dx,
      top: center.dy - 18 + offset.dy,
      child: Tooltip(
        message: tooltip,
        child: GestureDetector(
          onTap: () {
            HapticFeedback.selectionClick();
            widget.onAddTap(type);
          },
          child: Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: const LinearGradient(
                colors: [goldLight, goldPrimary, goldDark],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              boxShadow: [
                BoxShadow(
                  color: goldPrimary.withValues(alpha: 0.6),
                  blurRadius: 10,
                  offset: const Offset(0, 3),
                ),
              ],
              border: Border.all(color: Colors.white, width: 1.5),
            ),
            child: Icon(
              icon,
              size: 18,
              color: const Color(0xFF1A1A1A),
            ),
          ),
        ),
      ),
    );
  }
}
