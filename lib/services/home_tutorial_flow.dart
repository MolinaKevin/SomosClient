import 'package:flutter/material.dart';
import '../config/environment_config.dart';
import '../services/tutorial_service.dart';
import '../widgets/spotlight.dart';
import '../screens/tutorial_screen.dart';

class HomeTutorialFlow {
  HomeTutorialFlow(this.tutorialService);

  final TutorialService tutorialService;

  Future<void> run({
    required BuildContext context,
    required Spotlight spotlight,
    required GlobalKey viewSwitchKey,
    required GlobalKey controlsKey,
    required GlobalKey mapAreaKey,
    required GlobalKey navProfileKey,
    required GlobalKey navMapKey,
    required GlobalKey payKey,
    required void Function(int) setTabIndex,
    required VoidCallback ensureMapTab,
  }) async {
    final shouldShowOnboarding =
        EnvironmentConfig.testForceOnboarding || !(await tutorialService.isOnboardingDone());

    if (shouldShowOnboarding && context.mounted) {
      await Navigator.of(context).push(
        MaterialPageRoute(builder: (_) => const TutorialScreen()),
      );
      await tutorialService.setOnboardingDone();
    }

    final shouldShowSpotlight =
        EnvironmentConfig.testForceSpotlight || !(await tutorialService.isSpotlightDone());

    if (shouldShowSpotlight && context.mounted) {
      ensureMapTab();
      await WidgetsBinding.instance.endOfFrame;

      await spotlight.showForKey(
        viewSwitchKey,
        label: 'Acá podés cambiar cómo visualizar: Mapa o Lista.',
        placement: SpotlightPlacement.below,
        labelOffset: const Offset(0, 4),
      );

      await spotlight.showForKey(
        controlsKey,
        label: 'Estos controles te dejan filtrar, buscar lugares y cambiar el zoom.',
        placement: SpotlightPlacement.below,
        labelOffset: const Offset(0, 4),
      );

      await spotlight.showForKey(
        mapAreaKey,
        label: 'En el mapa se muestran los comercios e instituciones asociadas.',
        extraPadding: 0,
      );

      await spotlight.showForKey(
        navProfileKey,
        label: 'Desde acá accedés a tu perfil.',
      );

      await spotlight.showForKey(
        navMapKey,
        label: 'Este botón te lleva de vuelta al mapa.',
      );

      await spotlight.showForKey(
        payKey,
        label: 'Tocá acá para generar una transacción.',
        circular: true,
        onTapInside: () => setTabIndex(2),
      );

      await tutorialService.setSpotlightDone();
    }
  }
}
