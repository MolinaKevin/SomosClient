import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import '../screens/entity_detail_screen.dart';
import '../widgets/seal_icon_widget.dart';
import 'package:auto_size_text/auto_size_text.dart';

class InfoCardPopup {
  static const _cream = Color(0xFFFFF5E6);

  static void show({
    required BuildContext context,
    required Map<String, dynamic> data,
    required Map<String, dynamic> translations,
    required List<Map<String, dynamic>> allSeals,
    required VoidCallback onDismiss,

    double bottomBarHeight = 0,
    double extraBottomGap = 0,
    double maxHeightFactorPhone = 0.36,
    double maxHeightFactorLarge = 0.28,
  }) {
    showGeneralDialog(
      context: context,
      barrierColor: Colors.transparent,
      barrierDismissible: true,
      barrierLabel: MaterialLocalizations.of(context).modalBarrierDismissLabel,
      transitionDuration: const Duration(milliseconds: 220),
      pageBuilder: (BuildContext buildContext, Animation<double> animation,
          Animation<double> secondaryAnimation) {
        final media = MediaQuery.of(context);
        final size = media.size;
        final isPhone = size.shortestSide < 600;

        final maxCardHeight =
            size.height * (isPhone ? maxHeightFactorPhone : maxHeightFactorLarge);

        final bottom = bottomBarHeight + extraBottomGap;
        final bgUrl = (data['background_image'] ?? '').toString();

        final rawScale = media.textScaleFactor;
        final cappedScale = rawScale.clamp(0.85, 1.15);
        final cappedScaler = TextScaler.linear(cappedScale);

        return MediaQuery(
          data: media.copyWith(textScaler: cappedScaler),
          child: LayoutBuilder(
            builder: (context, c) {
              // Tamaños base para tipografías adaptativas dentro del popup
              final w = c.maxWidth;
              final h = c.maxHeight;
              final s = w < h ? w : h;

              final titleSize = (s * 0.060).clamp(18, 22).toDouble(); // nombre comercio
              final chipFontSize = (s * 0.038).clamp(12, 14).toDouble(); // chip abierto/cerrado

              return Stack(
                clipBehavior: Clip.none,
                alignment: Alignment.bottomCenter,
                children: [
                  // Cerrar tocando fuera
                  Positioned.fill(
                    child: GestureDetector(
                      onTap: () => Navigator.pop(context),
                      child: Container(color: Colors.transparent),
                    ),
                  ),

                  // Card flotante superpuesta (toda clickeable)
                  Positioned(
                    left: 12,
                    right: 12,
                    bottom: bottom,
                    child: Material(
                      color: Colors.transparent,
                      child: InkWell(
                        borderRadius: BorderRadius.circular(16),
                        onTap: () {
                          Navigator.of(context).pop();

                          WidgetsBinding.instance.addPostFrameCallback((_) {
                            Navigator.of(context, rootNavigator: true).push(
                              CupertinoPageRoute(
                                builder: (ctx) => EntityDetailScreen(
                                  title: (data['name'] ??
                                      translations['common']['noDataAvailable'] ??
                                      'Not available')
                                      .toString(),
                                  address: data['address'] ??
                                      translations['entities']?['noAddress'] ??
                                      'Address not available',
                                  phone: data['phone'] ??
                                      translations['entities']?['noPhone'] ??
                                      'Phone not available',
                                  email: data['email'] ??
                                      translations['entities']?['noEmail'] ??
                                      'Email not available',
                                  city: data['city'] ??
                                      translations['entities']?['noCity'] ??
                                      'City not available',
                                  description: data['description'] ??
                                      translations['entities']?['noDescription'] ??
                                      'Description not available',
                                  imageUrl: data['avatar_url'] ?? '',
                                  backgroundImage: data['background_image'] ?? '',
                                  fotosUrls: List<String>.from(data['fotos_urls'] ?? []),
                                  translations: translations,
                                  seals: List<Map<String, dynamic>>.from(
                                    (data['seals_with_state'] ?? []),
                                  ).where((s) =>
                                  s['state'] == 'partial' || s['state'] == 'full').toList(),
                                ),
                              ),
                            );
                          });
                        },
                        splashColor: Colors.black12,
                        highlightColor: Colors.black12.withOpacity(0.05),
                        child: Container(
                          decoration: BoxDecoration(
                            color: _cream,
                            borderRadius: BorderRadius.circular(16),
                            boxShadow: const [
                              BoxShadow(
                                color: Colors.black26,
                                blurRadius: 10,
                                offset: Offset(0, 5),
                              ),
                            ],
                          ),
                          clipBehavior: Clip.antiAlias,
                          child: ConstrainedBox(
                            constraints: BoxConstraints(maxHeight: maxCardHeight),
                            child: _CardContent(
                              data: data,
                              translations: translations,
                              allSeals: allSeals,
                              bgUrl: bgUrl,
                              titleSize: titleSize,
                              chipFontSize: chipFontSize,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              );
            },
          ),
        );
      },
      transitionBuilder: (context, animation, secondaryAnimation, child) {
        return FadeTransition(
          opacity: animation,
          child: SlideTransition(
            position: Tween<Offset>(
              begin: const Offset(0, 1),
              end: const Offset(0, 0),
            ).animate(animation),
            child: child,
          ),
        );
      },
    ).then((_) => onDismiss());
  }
}

class _CardContent extends StatelessWidget {
  final Map<String, dynamic> data;
  final Map<String, dynamic> translations;
  final List<Map<String, dynamic>> allSeals;
  final String bgUrl;

  final double titleSize;
  final double chipFontSize;

  const _CardContent({
    required this.data,
    required this.translations,
    required this.allSeals,
    required this.bgUrl,
    this.titleSize = 20,
    this.chipFontSize = 14,
  });

  @override
  Widget build(BuildContext context) {
    final sealsWithStateData =
    List<Map<String, dynamic>>.from(data['seals_with_state'] ?? []);
    final hasSeals = sealsWithStateData
        .any((s) => s['state'] == 'partial' || s['state'] == 'full');

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        // Header imagen con degradado suave al cuerpo
        ClipRRect(
          borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
          child: AspectRatio(
            aspectRatio: 16 / 9,
            child: Stack(
              fit: StackFit.expand,
              children: [
                Container(color: InfoCardPopup._cream),
                if (bgUrl.isNotEmpty)
                  Image.network(bgUrl, fit: BoxFit.cover)
                else
                  Container(color: const Color(0xFF2F5E3B).withOpacity(.15)),
                // Fade inferior
                Align(
                  alignment: Alignment.bottomCenter,
                  child: IgnorePointer(
                    ignoring: true,
                    child: Container(
                      height: 40,
                      decoration: const BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.topCenter,
                          end: Alignment.bottomCenter,
                          colors: [Colors.transparent, InfoCardPopup._cream],
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),

        Flexible(
          child: SingleChildScrollView(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 14),
            physics: const BouncingScrollPhysics(),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                CircleAvatar(
                  radius: 28,
                  backgroundColor: const Color(0xFF103D1B),
                  backgroundImage:
                  NetworkImage((data['avatar_url'] ?? '').toString()),
                ),
                const SizedBox(width: 16),

                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Chip abierto/cerrado
                      Align(
                        alignment: Alignment.centerLeft,
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 10, vertical: 4),
                          decoration: BoxDecoration(
                            color: data['is_open'] == true
                                ? Colors.green[100]
                                : Colors.red[100],
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Text(
                            data['is_open'] == true
                                ? (translations['entities']['open'] ?? 'Open')
                                : (translations['entities']['closed'] ??
                                'Closed'),
                            style: TextStyle(
                              fontSize: chipFontSize,
                              color: data['is_open'] == true
                                  ? Colors.green[800]
                                  : Colors.red[800],
                              fontWeight: FontWeight.w600,
                              height: 1.0,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 6),

                      // Título auto-ajustable
                      AutoSizeText(
                        (data['name'] ??
                            translations['common']['noDataAvailable'] ??
                            'Not available')
                            .toString(),
                        maxLines: 1,
                        minFontSize: 14,
                        stepGranularity: 0.5,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          fontSize: titleSize,
                          fontWeight: FontWeight.w700,
                          height: 1.05,
                        ),
                      ),
                    ],
                  ),
                ),

                if (hasSeals) const SizedBox(width: 8),

                // Seals a la derecha, scroll horizontal si exceden
                if (hasSeals)
                  Directionality(
                    textDirection: TextDirection.rtl,
                    child: LayoutBuilder(
                      builder: (ctx, _) {
                        const double sealSize = 24;
                        const double spacing  = 2;
                        final double viewportWidth =
                            sealSize * 2 + spacing * 3 + sealSize * 0.35;

                        final seals = sealsWithStateData
                            .where((s) => s['state'] == 'partial' || s['state'] == 'full')
                            .map((sealState) {
                          final base = allSeals.firstWhere(
                                (seal) => seal['id'] == sealState['id'],
                            orElse: () => {},
                          );
                          if (base.isEmpty) return null;
                          return {...base, 'state': sealState['state']};
                        })
                            .whereType<Map<String, dynamic>>()
                            .toList();

                        return SizedBox(
                          width: viewportWidth,
                          height: sealSize,
                          child: ListView.separated(
                            scrollDirection: Axis.horizontal,
                            reverse: true,
                            physics: const BouncingScrollPhysics(),
                            padding: EdgeInsets.zero,
                            itemCount: seals.length,
                            separatorBuilder: (_, __) => SizedBox(width: spacing),
                            itemBuilder: (_, i) => SizedBox(
                              width: sealSize, height: sealSize,
                              child: Center(
                                child: SealIconWidget(seal: seals[i], size: sealSize),
                              ),
                            ),
                          ),
                        );
                      },
                    ),
                  ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}
