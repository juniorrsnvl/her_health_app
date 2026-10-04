import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

/// Design A ("Blush & Sage, refined"): one place for the colours, type and
/// controls the redesigned screens share, so every screen matches.
class DA {
  // Colours
  static const ground = Color(0xFFFAF6F3); // warm off-white page
  static const surface = Colors.white; // cards and fields
  static const border = Color(0xFFEADFDB);
  static const divider = Color(0xFFEFE6E2);
  static const ink = Color(0xFF2F3A2A); // main text
  static const muted = Color(0xFF5E5652); // secondary text
  static const quiet = Color(0xFF6B6460); // captions
  static const sage = Color(0xFF6E7B5F);
  static const blush = Color(0xFFF6DCE2); // soft highlight
  static const rose = Color(0xFFB04F6C); // buttons and selection
  static const chip = Color(0xFFF1EAE6); // round icon buttons

  // Status badges: colour AND word differ, so they're readable without colour.
  static const approvedBg = Color(0xFFE3EBDD), approvedInk = Color(0xFF3F4D34);
  static const pendingBg = Color(0xFFFBEBD3), pendingInk = Color(0xFF7A4B0B);
  static const rejectedBg = Color(0xFFF6DCE2), rejectedInk = Color(0xFF8A2E48);

  // Type: Nunito for headings, Nunito Sans for everything else.
  static TextStyle heading(double size, {Color color = ink}) => GoogleFonts.nunito(
        fontSize: size,
        fontWeight: FontWeight.w800,
        color: color,
        height: 1.15,
      );

  static TextStyle body(
    double size, {
    Color color = ink,
    FontWeight weight = FontWeight.w400,
    double height = 1.45,
  }) =>
      GoogleFonts.nunitoSans(fontSize: size, color: color, fontWeight: weight, height: height);

  /// A text field: white, rounded, soft border; rose when focused.
  static InputDecoration input({String? hint, Widget? suffix, Widget? prefix}) {
    OutlineInputBorder outline(Color c, double w) => OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide(color: c, width: w),
        );
    return InputDecoration(
      hintText: hint,
      hintStyle: body(16, color: quiet),
      filled: true,
      fillColor: surface,
      contentPadding: const EdgeInsets.symmetric(horizontal: 18, vertical: 18),
      suffixIcon: suffix,
      prefixIcon: prefix,
      border: outline(border, 1.5),
      enabledBorder: outline(border, 1.5),
      focusedBorder: outline(rose, 2),
    );
  }

  /// The label shown above a field.
  static Widget label(String text) => Padding(
        padding: const EdgeInsets.only(bottom: 8),
        child: Text(text, style: body(14, weight: FontWeight.w700)),
      );

  /// Main call to action: rose, full width, pill-shaped.
  static ButtonStyle primary() => ElevatedButton.styleFrom(
        backgroundColor: rose,
        foregroundColor: Colors.white,
        disabledBackgroundColor: rose.withValues(alpha: 0.5),
        minimumSize: const Size.fromHeight(56),
        shape: const StadiumBorder(),
        elevation: 0,
        textStyle: GoogleFonts.nunito(fontSize: 17, fontWeight: FontWeight.w800),
      );

  /// Secondary action: rose outline.
  static ButtonStyle outline() => OutlinedButton.styleFrom(
        foregroundColor: rose,
        side: const BorderSide(color: rose, width: 1.5),
        minimumSize: const Size.fromHeight(52),
        shape: const StadiumBorder(),
        textStyle: GoogleFonts.nunito(fontSize: 16, fontWeight: FontWeight.w800),
      );

  /// Round 44px back button.
  static Widget backButton(BuildContext context) => SizedBox(
        width: 44,
        height: 44,
        child: IconButton(
          tooltip: 'Back',
          style: IconButton.styleFrom(backgroundColor: chip, foregroundColor: ink),
          icon: const Icon(Icons.arrow_back_ios_new_rounded, size: 18),
          onPressed: () => Navigator.maybePop(context),
        ),
      );

  /// White card with the soft border.
  static BoxDecoration card({Color color = surface, Color edge = border, double radius = 20}) =>
      BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(radius),
        border: Border.all(color: edge, width: 1.5),
      );

  /// Small spinner for buttons while something saves.
  static const buttonSpinner = SizedBox(
    height: 22,
    width: 22,
    child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
  );
}
