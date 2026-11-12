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

  String get _fullName =>
      '${widget.member.firstName} ${widget.member.lastName ?? ''}'.trim();

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
    const goldDark = Color(0xFF9E7710);

    // Параметры геометрии медальона в зависимости от статуса ветви
    final double nodeWidth;
    final double nodeHeight;
    final double medallionSize;
    final double plaqueWidth;

    switch (widget.branchSize) {
      case 'large':
        nodeWidth = 160.0;
        nodeHeight = 130.0;
        medallionSize = 58.0;
        plaqueWidth = 98.0;
        break;
      case 'small':
        nodeWidth = 130.0;
        nodeHeight = 108.0;
        medallionSize = 44.0;
        plaqueWidth = 80.0;
        break;
      case 'medium':
      default:
        nodeWidth = 145.0;
        nodeHeight = 118.0;
        medallionSize = 50.0;
        plaqueWidth = 90.0;
        break;
    }

    final centerOffset = Offset(nodeWidth / 2, medallionSize / 2 + 10);

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
                  centerOffset,
                  const Offset(0, -68),
                  'parent',
                  Icons.account_tree_outlined,
                  'Родитель (к корням)',
                ),
                _buildAddBtn(
                  centerOffset,
                  const Offset(0, 68),
                  'child',
                  Icons.child_care_outlined,
                  'Потомок (в крону)',
                ),
                _buildAddBtn(
                  centerOffset,
                  Offset(widget.isFlipped ? -68 : 68, 0),
                  'spouse',
                  Icons.favorite_rounded,
                  'Супруг(а)',
                ),
                // Кнопка быстрого перехода в летопись рода
                Positioned(
                  left: centerOffset.dx - 18 + (widget.isFlipped ? 68 : -68),
                  top: centerOffset.dy - 18,
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
                        child: const Icon(Icons.menu_book_rounded,
                            size: 18, color: Color(0xFF1A1A1A)),
                      ),
                    ),
                  ),
                ),
              ],

              // Основное интерактивное тело медальона персоны
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
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      // 1. Позолоченный геральдический медальон с портретом
                      Stack(
                        alignment: Alignment.center,
                        clipBehavior: Clip.none,
                        children: [
                          // Декоративные дубовые веточки по бокам медальона
                          Positioned(
                            left: -12,
                            top: 4,
                            child: Transform.rotate(
                              angle: -0.3,
                              child: _buildSideOakSprig(),
                            ),
                          ),
                          Positioned(
                            right: -12,
                            top: 4,
                            child: Transform.rotate(
                              angle: 0.3,
                              child: Transform.flip(
                                flipX: true,
                                child: _buildSideOakSprig(),
                              ),
                            ),
                          ),

                          // Золотой медальон
                          _buildGildedMedallionFrame(
                            medallionSize,
                            goldPrimary,
                            goldLight,
                            goldDark,
                          ),

                          // Иконка вечной памяти
                          if (_isDeceased)
                            Positioned(
                              left: 0,
                              top: 0,
                              child: Container(
                                padding: const EdgeInsets.all(2.5),
                                decoration: const BoxDecoration(
                                  color: Color(0xFF202020),
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
                              right: 0,
                              top: 0,
                              child: const Icon(
                                Icons.auto_awesome,
                                size: 15,
                                color: goldPrimary,
                              ),
                            ),
                        ],
                      ),

                      const SizedBox(height: 5),

                      // 2. Пергаментная табличка с именем и датами
                      SizedBox(
                        width: plaqueWidth,
                        child: _buildParchmentPlaque(),
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

  /// Позолоченный медальон в стиле референса (Image 2)
  Widget _buildGildedMedallionFrame(
    double size,
    Color goldPrimary,
    Color goldLight,
    Color goldDark,
  ) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF382314).withValues(alpha: 0.35),
            blurRadius: 8,
            offset: const Offset(0, 3),
          ),
          if (widget.isSelected || widget.isHighlighted)
            BoxShadow(
              color: goldPrimary.withValues(alpha: 0.85),
              blurRadius: 18,
              spreadRadius: 3,
            ),
        ],
        gradient: LinearGradient(
          colors: [goldLight, goldPrimary, goldDark, goldPrimary],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        border: Border.all(
          color: const Color(0xFF5A3E1B),
          width: 1.4,
        ),
      ),
      padding: const EdgeInsets.all(3.2),
      child: Container(
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          border: Border.all(
            color: const Color(0xFF8B6B42),
            width: 1.0,
          ),
        ),
        child: ClipOval(
          child: _buildAvatar(size - 9),
        ),
      ),
    );
  }

  /// Декоративные дубовые листики и желудь у медальона
  Widget _buildSideOakSprig() {
    return SizedBox(
      width: 20,
      height: 24,
      child: CustomPaint(
        painter: _MiniOakSprigPainter(),
      ),
    );
  }

  /// Аватар персоны или благородный винтажный силуэт
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

  /// Пергаментная свиточная табличка в стиле геральдического референса
  Widget _buildParchmentPlaque() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 3),
      decoration: BoxDecoration(
        color: const Color(0xFFF7F2E4),
        borderRadius: BorderRadius.circular(6),
        border: Border.all(
          color: const Color(0xFF8B6B42),
          width: 1.1,
        ),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF4A3423).withValues(alpha: 0.24),
            blurRadius: 5,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            _fullName,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            textAlign: TextAlign.center,
            style: const TextStyle(
              fontSize: 10.5,
              fontWeight: FontWeight.bold,
              color: Color(0xFF2C1E14),
              fontFamily: 'serif',
              letterSpacing: 0.1,
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
                  fontSize: 9.0,
                  fontWeight: FontWeight.w600,
                  color: Color(0xFF6A4D32),
                  fontFamily: 'serif',
                ),
              ),
            ),
        ],
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

/// Миниатюрный дубовый листик с желудем у кромки медальона
class _MiniOakSprigPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final leafPaint = Paint()
      ..color = const Color(0xFF2E6B47)
      ..style = PaintingStyle.fill;
    final goldVein = Paint()
      ..color = const Color(0xFFDFB743).withValues(alpha: 0.75)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 0.8;

    final leafPath = Path()
      ..moveTo(size.width, size.height * 0.7)
      ..cubicTo(size.width * 0.5, size.height * 0.4, 0, size.height * 0.3, 0, 0)
      ..cubicTo(size.width * 0.3, size.height * 0.4, size.width * 0.7, size.height * 0.5, size.width, size.height * 0.7);

    canvas.drawPath(leafPath, leafPaint);
    canvas.drawLine(Offset(size.width, size.height * 0.7), Offset(0, 0), goldVein);

    // Золотой желудь
    canvas.drawCircle(
      Offset(size.width * 0.6, size.height * 0.75),
      2.5,
      Paint()..color = const Color(0xFFDFB743),
    );
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
