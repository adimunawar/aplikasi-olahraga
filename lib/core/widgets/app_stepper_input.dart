import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../theme/app_colors.dart';
import '../theme/app_typography.dart';

/// Reusable Stepper Input Component with Manual Typing Support (Mockup 1:1)
/// Mendukung tombol minus/plus dan input angka manual langsung pada kolom tengah.
class AppStepperInput extends StatefulWidget {
  final String label;
  final String unit;
  final double value;
  final double step;
  final double minValue;
  final double maxValue;
  final bool isDecimal;
  final ValueChanged<double> onChanged;

  const AppStepperInput({
    super.key,
    required this.label,
    required this.unit,
    required this.value,
    this.step = 1.0,
    this.minValue = 1.0,
    this.maxValue = 300.0,
    this.isDecimal = false,
    required this.onChanged,
  });

  @override
  State<AppStepperInput> createState() => _AppStepperInputState();
}

class _AppStepperInputState extends State<AppStepperInput> {
  late TextEditingController _controller;
  late FocusNode _focusNode;

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController(text: _formatValue(widget.value));
    _focusNode = FocusNode();
    _focusNode.addListener(_onFocusChange);
  }

  @override
  void didUpdateWidget(covariant AppStepperInput oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (!_focusNode.hasFocus && oldWidget.value != widget.value) {
      final formatted = _formatValue(widget.value);
      if (_controller.text != formatted) {
        _controller.text = formatted;
      }
    }
  }

  @override
  void dispose() {
    _focusNode.removeListener(_onFocusChange);
    _focusNode.dispose();
    _controller.dispose();
    super.dispose();
  }

  String _formatValue(double val) {
    if (widget.isDecimal) {
      return val.toStringAsFixed(1);
    }
    return val.round().toString();
  }

  void _onFocusChange() {
    if (!_focusNode.hasFocus) {
      // Ketika keyboard tertutup/unfocus, pastikan nilai valid dan ter-clamp
      final parsed = double.tryParse(_controller.text.replaceAll(',', '.'));
      if (parsed == null || parsed < widget.minValue || parsed > widget.maxValue) {
        final clamped = (parsed ?? widget.value).clamp(widget.minValue, widget.maxValue);
        widget.onChanged(clamped);
        _controller.text = _formatValue(clamped);
      }
    }
  }

  void _handleManualInput(String text) {
    if (text.isEmpty) return;
    final parsed = double.tryParse(text.replaceAll(',', '.'));
    if (parsed != null) {
      widget.onChanged(parsed);
    }
  }

  void _decrement() {
    HapticFeedback.lightImpact();
    final next = (widget.value - widget.step).clamp(widget.minValue, widget.maxValue);
    widget.onChanged(next);
    _controller.text = _formatValue(next);
  }

  void _increment() {
    HapticFeedback.lightImpact();
    final next = (widget.value + widget.step).clamp(widget.minValue, widget.maxValue);
    widget.onChanged(next);
    _controller.text = _formatValue(next);
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Label Section (Age, Height, Weight, etc.)
        Text(
          widget.label,
          style: AppTypography.headlineSmall.copyWith(
            fontWeight: FontWeight.w800,
            fontSize: 16,
            color: AppColors.darkCharcoal,
            letterSpacing: -0.2,
          ),
        ),
        const SizedBox(height: 10),

        // Row Stepper Card + Unit Beside
        Row(
          children: [
            // Pill Container: [-  Number  +]
            Container(
              width: 220,
              height: 56,
              decoration: BoxDecoration(
                color: const Color(0xFFF8FAFC),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: const Color(0xFFE2E8F0), width: 1.2),
                boxShadow: const [
                  BoxShadow(
                    color: Color(0x08000000),
                    blurRadius: 4,
                    offset: Offset(0, 2),
                  ),
                ],
              ),
              child: Row(
                children: [
                  // Minus Button
                  _buildStepButton(
                    icon: Icons.remove_rounded,
                    onTap: widget.value > widget.minValue ? _decrement : null,
                  ),

                  // Center Editable Number Input
                  Expanded(
                    child: TextField(
                      controller: _controller,
                      focusNode: _focusNode,
                      keyboardType: TextInputType.numberWithOptions(
                        decimal: widget.isDecimal,
                      ),
                      inputFormatters: [
                        FilteringTextInputFormatter.allow(
                          widget.isDecimal ? RegExp(r'^\d*\.?\d*') : RegExp(r'^\d*'),
                        ),
                      ],
                      textAlign: TextAlign.center,
                      style: AppTypography.displayMedium.copyWith(
                        fontWeight: FontWeight.w900,
                        fontSize: 24,
                        color: AppColors.darkCharcoal,
                      ),
                      decoration: const InputDecoration(
                        border: InputBorder.none,
                        isDense: true,
                        contentPadding: EdgeInsets.zero,
                      ),
                      onChanged: _handleManualInput,
                    ),
                  ),

                  // Plus Button
                  _buildStepButton(
                    icon: Icons.add_rounded,
                    onTap: widget.value < widget.maxValue ? _increment : null,
                  ),
                ],
              ),
            ),
            const SizedBox(width: 16),

            // Satuan di samping (years, cm, kg)
            Text(
              widget.unit,
              style: AppTypography.titleMedium.copyWith(
                fontWeight: FontWeight.w700,
                fontSize: 16,
                color: AppColors.darkCharcoal,
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildStepButton({
    required IconData icon,
    required VoidCallback? onTap,
  }) {
    final isEnabled = onTap != null;

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(14),
        child: SizedBox(
          width: 52,
          height: double.infinity,
          child: Center(
            child: Icon(
              icon,
              size: 24,
              color: isEnabled ? AppColors.darkCharcoal : const Color(0xFFCBD5E1),
            ),
          ),
        ),
      ),
    );
  }
}
