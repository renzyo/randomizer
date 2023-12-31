import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:randomizer/providers/async_group_list_provider.dart';
import 'package:randomizer/providers/selected_group_list_provider.dart';
import 'package:randomizer/screens/add_group_list/add_group_list.dart';

class SelectListDialog extends ConsumerStatefulWidget {
  const SelectListDialog({super.key});

  @override
  ConsumerState<SelectListDialog> createState() => _SelectListDialogState();
}

class _SelectListDialogState extends ConsumerState<SelectListDialog> {
  @override
  Widget build(BuildContext context) {
    final groupLists = ref.watch(asyncGroupListProvider);

    return AlertDialog(
      title: const Text('Select Group List'),
      content: groupLists.when(
        skipLoadingOnRefresh: true,
        skipLoadingOnReload: true,
        data: (groupList) => SizedBox(
          width: double.maxFinite,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ListView.separated(
                shrinkWrap: true,
                primary: false,
                itemCount: groupList.length,
                separatorBuilder: (context, index) => const Divider(),
                itemBuilder: (context, index) {
                  final item = groupList[index];

                  return ListTile(
                    title: Text(item.name),
                    subtitle: Text(
                      item.items.join(', '),
                      overflow: TextOverflow.ellipsis,
                    ),
                    contentPadding: const EdgeInsets.symmetric(horizontal: 4),
                    onTap: () {
                      ref.read(selectedGroupListProvider.notifier).selectGroupList(item);
                      Navigator.pop(context);
                    },
                    trailing: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        IconButton(
                          icon: const Icon(Icons.edit),
                          onPressed: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => AddGroupListScreen(
                                  groupList: item,
                                  isEdit: true,
                                ),
                              ),
                            );
                          },
                        ),
                        IconButton(
                          icon: const Icon(Icons.delete),
                          onPressed: () {
                            showDialog(
                                context: context,
                                builder: (context) {
                                  return AlertDialog(
                                    title: const Text('Delete Group List'),
                                    content: const Text(
                                        'Are you sure you want to delete this group list?'),
                                    actions: [
                                      TextButton(
                                        onPressed: () {
                                          Navigator.pop(context);
                                        },
                                        child: const Text('Cancel'),
                                      ),
                                      TextButton(
                                        onPressed: () {
                                          ref
                                              .read(asyncGroupListProvider.notifier)
                                              .deleteGroupList(item);
                                          ref
                                              .read(selectedGroupListProvider.notifier)
                                              .selectGroupList(null);
                                          Navigator.pop(context);
                                        },
                                        child: const Text('Delete'),
                                      ),
                                    ],
                                  );
                                });
                          },
                        ),
                      ],
                    ),
                  );
                },
              ),
              const SizedBox(height: 8),
              ElevatedButton.icon(
                label: const Text('New List'),
                icon: const Icon(Icons.add),
                onPressed: () async {
                  Navigator.pop(context);
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const AddGroupListScreen(
                        isFromOtherScreen: true,
                      ),
                    ),
                  );
                },
              ),
            ],
          ),
        ),
        error: (error, stackTrace) => Text(error.toString()),
        loading: () => const CircularProgressIndicator(),
      ),
    );
  }
}
