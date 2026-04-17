import '../../../core/utils/enums.dart';
import '../../categories/domain/command_category.dart';
import '../domain/command_item.dart';
import 'mock_commands.dart';

class CommandsRepository {
  const CommandsRepository();

  List<CommandItem> getAll() => mockCommands;

  List<CommandCategory> getCategories() => mockCategories;

  List<CommandItem> getByShell(ShellType shellType) {
    return mockCommands.where((item) => item.shellType == shellType).toList();
  }

  CommandItem? getById(String id) {
    for (final item in mockCommands) {
      if (item.id == id) return item;
    }
    return null;
  }
}
