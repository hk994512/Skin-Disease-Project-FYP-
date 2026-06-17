import 'package:clearskin_ai/core/config.dart';

class MyAppbar extends StatelessWidget implements PreferredSizeWidget {
  const MyAppbar({
    super.key,
    required this.text,
    this.actions,
    this.leading,
    this.automaticallyImplyLeading = false,
    this.backgroundColor,
    this.fontWeight,
  });
  final String text;
  final List<Widget>? actions;
  final Widget? leading;
  final bool automaticallyImplyLeading;
  final Color? backgroundColor;
  final FontWeight? fontWeight;
  @override
  Widget build(BuildContext context) {
    return AppBar(
      backgroundColor: context.appBarTheme.backgroundColor,
      actionsIconTheme: IconThemeData(color: context.colorScheme.onSurface),
      leading: leading,
      iconTheme: IconThemeData(color: context.theme.colorScheme.onSurface),
      automaticallyImplyLeading: automaticallyImplyLeading,
      centerTitle: true,
      title: Text(
        text,
        style: context.theme.textTheme.headlineMedium!.copyWith(
          fontWeight: fontWeight ?? .w700,
        ),
      ),
      actions: actions,
    );
  }

  @override
  Size get preferredSize => Size.fromHeight(60.h);
}
