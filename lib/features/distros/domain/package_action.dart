class PackageAction {
  const PackageAction({
    required this.id,
    required this.action,
    required this.description,
    required this.commands,
    this.tip,
  });

  final String id;
  final String action;
  final String description;
  final Map<String, String> commands;
  final String? tip;
}
