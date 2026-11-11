import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../../../data/models/member_model.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../../../profile/presentation/profile_screen.dart';

class MemberNodeWidget extends StatefulWidget {
  final MemberModel member;
  final bool isSelected;
  final bool isVisible;
  final bool isHighlighted;
  final VoidCallback onTap;
  final Function(String relationType) onAddTap;

  const MemberNodeWidget({
    super.key,
    required this.member,
    required this.isSelected,
    required this.isVisible,
    this.isHighlighted = false,
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
    if (d != null) return '$b  ◆  $d';
    return '$b г.';
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    // Премиальная геральдическая палитра
    const goldPrimary = Color(0xFFD4AF37);
    const goldLight = Color(0xFFF3E5AB);
    const goldDark = Color(0xFFAA8012);

    final surfaceColor =
        isDark ? const Color(0xFF141820) : const Color(0xFFFFFFFF);
    final cardBorderColor = isDark
        ? (widget.isSelected ? goldPrimary : const Color(0xFF384355))
        : (widget.isSelected ? goldPrimary : const Color(0xFFE2D9C8));

    Color glowColor;
    if (widget.isHighlighted) {
      glowColor = goldPrimary.withValues(alpha: 0.8);
    } else if (_isBirthday) {
      glowColor = goldLight.withValues(alpha: 0.9);
    } else if (widget.isSelected) {
      glowColor = goldPrimary.withValues(alpha: 0.5);
    } else if (_isDeceased) {
      glowColor = Colors.black.withValues(alpha: 0.3);
    } else {
      glowColor = goldPrimary.withValues(alpha: isDark ? 0.12 : 0.08);
    }

    return AnimatedOpacity(
      opacity: widget.isVisible ? 1.0 : 0.0,
      duration: const Duration(milliseconds: 500),
      curve: Curves.easeInOut,
      child: AnimatedScale(
        scale: widget.isVisible ? 1.0 : 0.85,
        duration: const Duration(milliseconds: 500),
        curve: Curves.easeInOut,
        child: Stack(
          clipBehavior: Clip.none,
          alignment: Alignment.center,
          children: [
            // Всплывающие кнопки управления при выборе узла
            if (widget.isSelected) ...[
              _buildAddBtn(
                const Offset(0, -96),
                'parent',
                Icons.account_tree_outlined,
                'Родитель',
              ),
              _buildAddBtn(
                const Offset(0, 96),
                'child',
                Icons.child_care_outlined,
                'Потомок',
              ),
              _buildAddBtn(
                const Offset(-96, 0),
                'spouse',
                Icons.favorite_rounded,
                'Супруг(а)',
              ),
              // Кнопка быстрого перехода в карточку профиля
              Positioned(
                left: 60 - 18 + 96,
                top: 60 - 18,
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
                          color: goldPrimary.withValues(alpha: 0.5),
                          blurRadius: 8,
                          offset: const Offset(0, 2),
                        ),
                      ],
                      border: Border.all(color: Colors.white, width: 1.5),
                    ),
                    child: const Icon(Icons.person, size: 18, color: Color(0xFF1A1A1A)),
                  ),
                ),
              ),
            ],

            // Основная карточка-медальон персоны
            GestureDetector(
              onTapDown: (_) {
                HapticFeedback.selectionClick();
                setState(() => _isPressed = true);
              },
              onTapUp: (_) {
                HapticFeedback.lightImpact();
                setState(() => _isPressed = false);
                widget.onTap();
              },
              onTapCancel: () => setState(() => _isPressed = false),
              child: AnimatedScale(
                scale: _isPressed ? 0.96 : (widget.isSelected ? 1.04 : 1.0),
                duration: const Duration(milliseconds: 160),
                curve: Curves.easeOutBack,
                child: Container(
                  width: 128,
                  height: 128,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(26),
                    color: surfaceColor,
                    boxShadow: [
                      // Мягкое благородное свечение
                      BoxShadow(
                        color: glowColor,
                        blurRadius: (widget.isHighlighted || _isBirthday || widget.isSelected)
                            ? 24
                            : 12,
                        spreadRadius: widget.isSelected ? 3 : 0,
                        offset: const Offset(0, 4),
                      ),
                      // Тень основания
                      BoxShadow(
                        color: Colors.black.withValues(alpha: isDark ? 0.45 : 0.08),
                        blurRadius: 10,
                        offset: const Offset(0, 5),
                      ),
                    ],
                    // Внешний золотой/платиновый безель
                    border: Border.all(
                      color: widget.isHighlighted
                          ? goldLight
                          : (widget.isSelected ? goldPrimary : cardBorderColor),
                      width: (widget.isSelected || widget.isHighlighted) ? 2.2 : 1.4,
                    ),
                  ),
                  child: Stack(
                    alignment: Alignment.center,
                    children: [
                      // Тонкий внутренний золотистый контур для эффекта филиграни
                      Positioned.fill(
                        child: Container(
                          margin: const EdgeInsets.all(3.5),
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(22),
                            border: Border.all(
                              color: goldPrimary.withValues(
                                alpha: widget.isSelected ? 0.6 : (isDark ? 0.2 : 0.3),
                              ),
                              width: 0.8,
                            ),
                          ),
                        ),
                      ),

                      // Контент узла
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 10.0),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            // Аватар-медальон с золотым кольцом
                            Container(
                              padding: const EdgeInsets.all(2.5),
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                gradient: LinearGradient(
                                  colors: _isDeceased
                                      ? const [Color(0xFF8A939E), Color(0xFF5E6570)]
                                      : const [goldLight, goldDark],
                                  begin: Alignment.topLeft,
                                  end: Alignment.bottomRight,
                                ),
                                boxShadow: [
                                  BoxShadow(
                                    color: (_isDeceased ? Colors.black : goldPrimary)
                                        .withValues(alpha: 0.3),
                                    blurRadius: 6,
                                  ),
                                ],
                              ),
                              child: CircleAvatar(
                                radius: 25,
                                backgroundColor: isDark
                                    ? const Color(0xFF1C222D)
                                    : const Color(0xFFF7F4EE),
                                backgroundImage: widget.member.avatarUrl != null
                                    ? CachedNetworkImageProvider(widget.member.avatarUrl!)
                                    : null,
                                child: widget.member.avatarUrl == null
                                    ? Text(
                                        widget.member.firstName.isNotEmpty
                                            ? widget.member.firstName[0]
                                            : '?',
                                        style: TextStyle(
                                          color: _isDeceased
                                              ? (isDark ? Colors.grey[400] : Colors.grey[700])
                                              : goldPrimary,
                                          fontWeight: FontWeight.bold,
                                          fontSize: 19,
                                          fontFamily: 'Inter',
                                        ),
                                      )
                                    : null,
                              ),
                            ),
                            const SizedBox(height: 7),

                            // Имя персоны
                            Text(
                              widget.member.firstName,
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 13,
                                letterSpacing: 0.2,
                                color: isDark
                                    ? const Color(0xFFF3F4F6)
                                    : const Color(0xFF1F2937),
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),

                            // Годы жизни с золотым ромбиком
                            if (_yearsText.isNotEmpty)
                              Padding(
                                padding: const EdgeInsets.only(top: 2.0),
                                child: Text(
                                  _yearsText,
                                  style: TextStyle(
                                    fontSize: 10,
                                    fontWeight: FontWeight.w500,
                                    letterSpacing: 0.3,
                                    color: _isDeceased
                                        ? const Color(0xFF8B949E)
                                        : (isDark
                                            ? const Color(0xFFC7A855)
                                            : const Color(0xFF8A6C25)),
                                  ),
                                ),
                              ),
                          ],
                        ),
                      ),

                      // Ленточка "Вечная память" для ушедших предков
                      if (_isDeceased)
                        Positioned(
                          top: 8,
                          right: 8,
                          child: Icon(
                            Icons.history_edu,
                            size: 13,
                            color: isDark ? const Color(0xFF8B949E) : const Color(0xFF6B7280),
                          ),
                        ),

                      // Корона/звездочка для дня рождения
                      if (_isBirthday)
                        const Positioned(
                          top: 6,
                          child: Icon(
                            Icons.auto_awesome,
                            size: 14,
                            color: goldPrimary,
                          ),
                        ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// Золотая сургучная печать-кнопка для добавления родственников
  Widget _buildAddBtn(Offset offset, String type, IconData icon, String tooltip) {
    const goldPrimary = Color(0xFFD4AF37);
    const goldLight = Color(0xFFF7E7B4);
    const goldDark = Color(0xFF9E7710);

    return Positioned(
      left: 60 - 18 + offset.dx,
      top: 60 - 18 + offset.dy,
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
