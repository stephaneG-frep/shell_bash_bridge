enum CommandRiskLevel { low, medium, high }

class CommandRisk {
  const CommandRisk({
    required this.level,
    required this.label,
    required this.message,
  });

  final CommandRiskLevel level;
  final String label;
  final String message;
}

CommandRisk assessCommandRisk({required String name, required String syntax}) {
  final normalized = '$name $syntax'.toLowerCase();

  const highPatterns = [
    'rm -rf',
    'remove-item -recurse -force',
    'dd ',
    'mkfs',
    'format-volume',
    'shutdown',
    'reboot',
    'halt',
    'kill -9',
    'stop-process -force',
    'del /f',
    ':(){',
  ];

  const mediumPatterns = [
    'rm ',
    'remove-item',
    'chmod',
    'chown',
    'systemctl',
    'service ',
    'kill ',
    'taskkill',
    'apt remove',
    'dnf remove',
    'pacman -r',
    'zypper remove',
    'move-item',
    'mv ',
  ];

  final hasHigh = highPatterns.any(normalized.contains);
  if (hasHigh) {
    return const CommandRisk(
      level: CommandRiskLevel.high,
      label: 'Risque élevé',
      message:
          'Commande potentiellement destructive. Vérifie la cible et prépare un rollback.',
    );
  }

  final hasMedium = mediumPatterns.any(normalized.contains);
  if (hasMedium) {
    return const CommandRisk(
      level: CommandRiskLevel.medium,
      label: 'Risque modéré',
      message:
          'Commande sensible. Relis les options avant exécution sur un environnement réel.',
    );
  }

  return const CommandRisk(
    level: CommandRiskLevel.low,
    label: 'Risque faible',
    message: 'Commande généralement sûre pour la pratique.',
  );
}
