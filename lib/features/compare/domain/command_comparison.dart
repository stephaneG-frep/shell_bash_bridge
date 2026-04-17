class CommandComparison {
  const CommandComparison({
    required this.id,
    required this.actionTitle,
    required this.bashCommand,
    required this.powershellCommand,
    required this.explanation,
  });

  final String id;
  final String actionTitle;
  final String bashCommand;
  final String powershellCommand;
  final String explanation;
}
