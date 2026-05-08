import 'package:flutter/material.dart';

class AppColors {
  AppColors._();

  // ============================================================
  // Brand
  // ============================================================

  static const Color primary = Color(0xFF6366F1); // Indigo 500
  static const Color primaryHover = Color(0xFF818CF8); // Indigo 400
  static const Color primaryPressed = Color(0xFF4F46E5); // Indigo 600

  static const Color secondary = Color(0xFF06B6D4); // Cyan 500
  static const Color accent = Color(0xFF8B5CF6); // Violet 500
  static const Color accentSoft = Color(0xFFA78BFA); // Violet 400

  // ============================================================
  // App Backgrounds
  // ============================================================

  static const Color background = Color(0xFF0B1120); // Deep Navy
  static const Color backgroundAlt = Color(0xFF0F172A); // Slate 900

  static const Color sidebar = Color(0xFF111827); // Gray 900
  static const Color topBar = Color(0xFF0F172A); // Slate 900
  static const Color bottomBar = Color(0xFF111827); // Gray 900

  static const Color surface = Color(0xFF182235); // Custom Slate
  static const Color surfaceAlt = Color(0xFF1E293B); // Slate 800
  static const Color surfaceHover = Color(0xFF273449);
  static const Color surfacePressed = Color(0xFF334155); // Slate 700

  static const Color card = Color(0xFF151F32);
  static const Color panel = Color(0xFF101827);
  static const Color editor = Color(0xFF0D1324);
  static const Color terminal = Color(0xFF050816);

  // ============================================================
  // Text
  // ============================================================

  static const Color textPrimary = Color(0xFFF8FAFC); // Slate 50
  static const Color textSecondary = Color(0xFFCBD5E1); // Slate 300
  static const Color textMuted = Color(0xFF94A3B8); // Slate 400
  static const Color textDisabled = Color(0xFF64748B); // Slate 500

  static const Color textOnPrimary = Color(0xFFFFFFFF);
  static const Color textOnDark = Color(0xFFF8FAFC);

  // ============================================================
  // Borders / Dividers
  // ============================================================

  static const Color border = Color(0xFF263247);
  static const Color borderStrong = Color(0xFF334155);
  static const Color divider = Color(0xFF1E293B);

  static Color glassBackground = Colors.white.withValues(alpha: 0.045);
  static Color glassBackgroundStrong = Colors.white.withValues(alpha: 0.075);
  static Color glassBorder = Colors.white.withValues(alpha: 0.10);

  // ============================================================
  // States
  // ============================================================

  static const Color success = Color(0xFF22C55E); // Green 500
  static const Color successSoft = Color(0xFF14532D);

  static const Color warning = Color(0xFFF59E0B); // Amber 500
  static const Color warningSoft = Color(0xFF451A03);

  static const Color error = Color(0xFFEF4444); // Red 500
  static const Color errorSoft = Color(0xFF450A0A);

  static const Color info = Color(0xFF38BDF8); // Sky 400
  static const Color infoSoft = Color(0xFF082F49);

  // ============================================================
  // Runtime / Model Status
  // ============================================================

  static const Color runtimeOff = Color(0xFF64748B);
  static const Color runtimeStarting = Color(0xFFF59E0B);
  static const Color runtimeRunning = Color(0xFF22C55E);
  static const Color runtimeBusy = Color(0xFF38BDF8);
  static const Color runtimeError = Color(0xFFEF4444);

  // ============================================================
  // IDE / Code Editor
  // ============================================================

  static const Color editorBackground = Color(0xFF0D1324);
  static const Color editorLineNumber = Color(0xFF475569);
  static const Color editorCurrentLine = Color(0xFF111C33);
  static const Color editorSelection = Color(0x553B82F6);
  static const Color editorCursor = Color(0xFF818CF8);

  static const Color codeKeyword = Color(0xFFC084FC);
  static const Color codeString = Color(0xFF86EFAC);
  static const Color codeNumber = Color(0xFFFBBF24);
  static const Color codeFunction = Color(0xFF67E8F9);
  static const Color codeComment = Color(0xFF64748B);
  static const Color codeError = Color(0xFFF87171);

  // ============================================================
  // Chat
  // ============================================================

  static const Color userBubble = Color(0xFF312E81);
  static const Color assistantBubble = Color(0xFF162033);
  static const Color systemBubble = Color(0xFF1E1B4B);

  static const Color userBubbleBorder = Color(0xFF6366F1);
  static const Color assistantBubbleBorder = Color(0xFF334155);
  static const Color systemBubbleBorder = Color(0xFF8B5CF6);

  // ============================================================
  // Window Control Colors
  // ============================================================

  static const Color closeButton = Color(0xFFEF4444);
  static const Color closeButtonHover = Color(0xFFF87171);

  static const Color minimizeButton = Color(0xFFF59E0B);
  static const Color minimizeButtonHover = Color(0xFFFBBF24);

  static const Color maximizeButton = Color(0xFF10B981);
  static const Color maximizeButtonHover = Color(0xFF34D399);

  // ============================================================
  // Shadows / Overlays
  // ============================================================

  static const Color shadow = Color(0x99000000);
  static const Color overlay = Color(0x99000000);
  static const Color modalBarrier = Color(0xCC020617);

  // ============================================================
  // Gradients
  // ============================================================

  static const LinearGradient appBackgroundGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [Color(0xFF0B1120), Color(0xFF111827), Color(0xFF0F172A)],
  );

  static const LinearGradient primaryGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [Color(0xFF6366F1), Color(0xFF8B5CF6)],
  );

  static const LinearGradient cyanVioletGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [Color(0xFF06B6D4), Color(0xFF6366F1), Color(0xFF8B5CF6)],
  );

  static const LinearGradient panelGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [Color(0xFF182235), Color(0xFF101827)],
  );

  static const LinearGradient softDarkGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [Color(0xFF151F32), Color(0xFF0D1324)],
  );
}

