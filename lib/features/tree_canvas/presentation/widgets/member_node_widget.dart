import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../../../data/models/member_model.dart';
import '../../../profile/presentation/profile_screen.dart';

class MemberNodeWidget extends StatefulWidget {
  final MemberModel member;
  final bool isSelected;
  final bool isVisible;
  final VoidCallback onTap;
  final Function(String relationType) onAddTap;

  const MemberNodeWidget({
    super.key,
    required this.member,
    required this.isSelected,
    required this.isVisible,
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
    return widget.member.birthDate!.day == now.day && widget.member.birthDate!.month == now.month;
  }

  String get _yearsText {
    final b = widget.member.birthDate?.year;
    final d = widget.member.deathDate?.year;
    if (b == null) return '';
    if (d != null) return '$b – $d';
    return '$b';
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    
    final surfaceColor = isDark ? const Color(0xFF1A1D24) : const Color(0xFFFFFFFF);
    final accentColor = isDark ? const Color(0xFFD4AF37) : const Color(0xFF2D4A3E);
    final glowColor = _isDeceased 
        ? Colors.grey.withOpacity(0.4)
        : (_isBirthday ? accentColor.withOpacity(0.8) : accentColor.withOpacity(0.1));

    return AnimatedOpacity(
      opacity: widget.isVisible ? 1.0 : 0.0,
      duration: const Duration(milliseconds: 600),
      curve: Curves.easeInOut,
      child: AnimatedScale(
        scale: widget.isVisible ? 1.0 : 0.8,
        duration: const Duration(milliseconds: 600),
        curve: Curves.easeInOut,
        child: Stack(
          clipBehavior: Clip.none,
          alignment: Alignment.center,
          children: [
            if (widget.isSelected) ...[
              _buildAddBtn(const Offset(0, -90), 'parent', Icons.keyboard_arrow_up),
              _buildAddBtn(const Offset(0, 90), 'child', Icons.keyboard_arrow_down),
              _buildAddBtn(const Offset(-90, 0), 'spouse', Icons.favorite_border),
              
              Positioned(
                left: 60 - 16 + 90,
                top: 60 - 16,
                child: GestureDetector(
                  onTap: () {
                    HapticFeedback.lightImpact();
                    ProfileScreen.show(context, widget.member);
                  },
                  child: CircleAvatar(
                    radius: 16,
                    backgroundColor: Theme.of(context).colorScheme.secondary,
                    child: Icon(Icons.person, size: 18, color: Theme.of(context).colorScheme.onSecondary),
                  ),
                ),
              ),
            ],

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
                scale: _isPressed ? 0.95 : 1.0,
                duration: const Duration(milliseconds: 150),
                curve: Curves.easeOutBack,
                child: Container(
                  width: 120,
                  height: 120,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(24),
                    color: surfaceColor,
                    boxShadow: [
                      BoxShadow(color: glowColor, blurRadius: _isBirthday ? 20 : 10, spreadRadius: _isBirthday ? 5 : 0),
                    ],
                    border: Border.all(
                      color: _isDeceased ? Colors.grey.withOpacity(0.3) : accentColor.withOpacity(0.5),
                      width: 1.5,
                    ),
                  ),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      CircleAvatar(
                        radius: 28,
                        backgroundColor: accentColor.withOpacity(0.1),
                        backgroundImage: widget.member.avatarUrl != null ? NetworkImage(widget.member.avatarUrl!) : null,
                        child: widget.member.avatarUrl == null 
                            ? Text(widget.member.firstName[0], style: TextStyle(color: accentColor, fontWeight: FontWeight.bold, fontSize: 20))
                            : null,
                      ),
                      const SizedBox(height: 8),
                      Text(
                        widget.member.firstName,
                        style: TextStyle(fontWeight: FontWeight.bold, color: isDark ? const Color(0xFFF3F4F6) : const Color(0xFF1F2937)),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      if (!_isDeceased && _yearsText.isNotEmpty)
                        Text(
                          _yearsText,
                          style: const TextStyle(fontSize: 10, color: Color(0xFF9CA3AF)),
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

  Widget _buildAddBtn(Offset offset, String type, IconData icon) {
    return Positioned(
      left: 60 - 16 + offset.dx,
      top: 60 - 16 + offset.dy,
      child: GestureDetector(
        onTap: () {
          HapticFeedback.selectionClick();
          widget.onAddTap(type);
        },
        child: CircleAvatar(
          radius: 16,
          backgroundColor: Theme.of(context).colorScheme.primary,
          child: Icon(icon, size: 18, color: Theme.of(context).colorScheme.onPrimary),
        ),
      ),
    );
  }
}
