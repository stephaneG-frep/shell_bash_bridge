class ActionPlan {
  const ActionPlan({
    required this.id,
    required this.intentId,
    required this.title,
    required this.description,
    required this.steps,
    required this.commandIds,
    required this.safetyTips,
  });

  final String id;
  final String intentId;
  final String title;
  final String description;
  final List<String> steps;
  final List<String> commandIds;
  final List<String> safetyTips;
}
