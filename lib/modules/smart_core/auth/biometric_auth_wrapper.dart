import 'package:flutter/material.dart';
import 'biometric_handler.dart';

/// Un helper pour intégrer la biométrie sans modifier les écrans existants.
/// Ce wrapper peut être utilisé autour d'un bouton de connexion ou comme un dialogue.
class BiometricAuthWrapper {
  
  /// Affiche une proposition de connexion biométrique si le flag est activé.
  /// Si l'authentification réussit, appelle [onSuccess].
  /// Sinon, ou si désactivé, l'utilisateur continue avec son email/password.
  static Future<void> checkAndPrompt(BuildContext context, {required VoidCallback onSuccess}) async {
    final bool isAvailable = await BiometricHandler.isBiometricAvailable();
    final bool isEnabled = await BiometricHandler.isBiometricEnabled();

    if (isAvailable && isEnabled) {
      final bool authenticated = await BiometricHandler.authenticate();
      if (authenticated) {
        onSuccess();
      }
    }
  }

  /// Propose l'activation de la biométrie après une connexion réussie
  /// si ce n'est pas déjà configuré.
  static void showSetupDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Connexion Biométrique'),
        content: const Text('Souhaitez-vous activer l\'empreinte digitale pour vos prochaines connexions ?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Plus tard'),
          ),
          ElevatedButton(
            onPressed: () async {
              await BiometricHandler.setBiometricEnabled(true);
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Empreinte activée !')),
              );
            },
            child: const Text('Activer'),
          ),
        ],
      ),
    );
  }
}
