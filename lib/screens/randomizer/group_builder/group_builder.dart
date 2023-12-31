import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_form_builder/flutter_form_builder.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:randomizer/model/group_list.dart';
import 'package:randomizer/providers/async_group_list_provider.dart';
import 'package:randomizer/providers/group_builder_provider.dart';
import 'package:randomizer/providers/selected_group_list_provider.dart';
import 'package:randomizer/screens/add_group_list/add_group_list.dart';
import 'package:randomizer/widgets/select_list_dialog.dart';

class GroupBuilderScreen extends ConsumerStatefulWidget {
  const GroupBuilderScreen({super.key});

  @override
  ConsumerState<GroupBuilderScreen> createState() => _GroupBuilderScreenState();
}

class _GroupBuilderScreenState extends ConsumerState<GroupBuilderScreen> {
  final _formKey = GlobalKey<FormBuilderState>();
  String errorText = "";

  void _handleResetButton() {
    FocusScope.of(context).unfocus();
    _formKey.currentState!.reset();
    ref.read(groupBuilderProvider.notifier).reset();
    ref.read(selectedGroupListProvider.notifier).unselectGroupList();
  }

  void _handleGenerateButton() {
    FocusScope.of(context).unfocus();
    if (_formKey.currentState!.saveAndValidate()) {
      final amount = int.parse(_formKey.currentState!.value['amount']);
      final groupList = ref.read(selectedGroupListProvider);

      ref.read(groupBuilderProvider.notifier).generateGroupList(groupList!, amount);
    }
  }

  void _handleLoadListButton(List<GroupList> groupList) {
    showDialog(
      context: context,
      builder: (context) => const SelectListDialog(),
    );
  }

  @override
  Widget build(BuildContext context) {
    final asyncGroupList = ref.watch(asyncGroupListProvider);
    final selectedGroupList = ref.watch(selectedGroupListProvider);
    final groupBuilder = ref.watch(groupBuilderProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Group Builder'),
        actions: [
          IconButton(
            onPressed: _handleResetButton,
            icon: const Icon(Icons.restore_rounded),
          ),
        ],
      ),
      floatingActionButton: selectedGroupList != null
          ? FloatingActionButton.extended(
              label: const Text('Generate Group'),
              icon: const Icon(Icons.shuffle),
              onPressed: _handleGenerateButton,
            )
          : null,
      body: asyncGroupList.when(
        skipLoadingOnRefresh: true,
        skipLoadingOnReload: true,
        data: (groupLists) => Padding(
          padding: const EdgeInsets.all(8),
          child: FormBuilder(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                FormBuilderTextField(
                  name: 'amount',
                  initialValue: "3",
                  keyboardType: TextInputType.number,
                  decoration: const InputDecoration(
                    labelText: 'Amount Group Generated',
                    border: OutlineInputBorder(),
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter amount group generated';
                    }
                    if (int.tryParse(value) == null) {
                      return 'Please enter a valid number (integer)';
                    }
                    if (int.tryParse(value)! > selectedGroupList!.items.length) {
                      return 'Value are more than total item in selected list';
                    }

                    return null;
                  },
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    Expanded(
                      child: ElevatedButton(
                        child: const Text('Load Name List'),
                        onPressed: () {
                          _handleLoadListButton(groupLists);
                        },
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: ElevatedButton(
                        child: const Text('New Name List'),
                        onPressed: () async {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) =>
                                  const AddGroupListScreen(isFromOtherScreen: true),
                            ),
                          );
                        },
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Text(
                  "Selected Name List: ${selectedGroupList == null ? 'None' : selectedGroupList.name}",
                  style: Theme.of(context).textTheme.bodyLarge,
                ),
                const SizedBox(height: 8),
                if (selectedGroupList != null)
                  Text(
                    "Total Item: ${selectedGroupList.items.length}",
                    style: Theme.of(context).textTheme.bodyLarge,
                  ),
                const SizedBox(height: 8),
                Expanded(
                  child: Card(
                    child: Padding(
                      padding: const EdgeInsets.all(8),
                      child: Stack(
                        children: [
                          Center(
                            child: groupBuilder.isEmpty
                                ? FaIcon(
                                    FontAwesomeIcons.userGroup,
                                    color: Theme.of(context)
                                        .colorScheme
                                        .onPrimaryContainer
                                        .withOpacity(0.5),
                                    size: 128,
                                  )
                                : SingleChildScrollView(
                                    child: ListView.builder(
                                      shrinkWrap: true,
                                      primary: false,
                                      physics: const NeverScrollableScrollPhysics(),
                                      itemCount: groupBuilder.length,
                                      itemBuilder: (context, index) {
                                        final group = groupBuilder[index];
                                        return Padding(
                                          padding: const EdgeInsets.all(8),
                                          child: Card(
                                            color: Theme.of(context).colorScheme.secondaryContainer,
                                            child: Padding(
                                              padding: const EdgeInsets.all(8),
                                              child: Stack(
                                                children: [
                                                  Center(
                                                    child: Column(
                                                      children: [
                                                        Container(
                                                          padding: const EdgeInsets.symmetric(
                                                            horizontal: 8,
                                                            vertical: 4,
                                                          ),
                                                          decoration: BoxDecoration(
                                                            color: Theme.of(context)
                                                                .colorScheme
                                                                .primaryContainer,
                                                            borderRadius: BorderRadius.circular(4),
                                                          ),
                                                          child: Text(
                                                            "Group ${groupBuilder.indexOf(group) + 1}",
                                                            style: Theme.of(context)
                                                                .textTheme
                                                                .bodyLarge,
                                                          ),
                                                        ),
                                                        const SizedBox(height: 8),
                                                        Text(
                                                          group.items.join(', '),
                                                          style:
                                                              Theme.of(context).textTheme.bodyLarge,
                                                        ),
                                                      ],
                                                    ),
                                                  ),
                                                  Positioned(
                                                    right: 0,
                                                    child: IconButton.filled(
                                                      style: ButtonStyle(
                                                        backgroundColor:
                                                            MaterialStateProperty.all<Color>(
                                                          Theme.of(context)
                                                              .colorScheme
                                                              .primaryContainer,
                                                        ),
                                                        foregroundColor:
                                                            MaterialStateProperty.all<Color>(
                                                          Theme.of(context)
                                                              .colorScheme
                                                              .onPrimaryContainer,
                                                        ),
                                                      ),
                                                      icon: const Icon(Icons.copy),
                                                      onPressed: () async {
                                                        await Clipboard.setData(
                                                          ClipboardData(
                                                            text:
                                                                "Group ${index + 1}: ${group.items.join(', ')}",
                                                          ),
                                                        );
                                                      },
                                                    ),
                                                  ),
                                                ],
                                              ),
                                            ),
                                          ),
                                        );
                                      },
                                    ),
                                  ),
                          ),
                          groupBuilder.length <= 1
                              ? Container()
                              : Positioned(
                                  bottom: 0,
                                  left: 0,
                                  child: Padding(
                                    padding: const EdgeInsets.all(8.0),
                                    child: ElevatedButton.icon(
                                      label: const Text("Copy All"),
                                      style: ButtonStyle(
                                        backgroundColor: MaterialStateProperty.all<Color>(
                                          Theme.of(context).colorScheme.primaryContainer,
                                        ),
                                        foregroundColor: MaterialStateProperty.all<Color>(
                                          Theme.of(context).colorScheme.onPrimaryContainer,
                                        ),
                                      ),
                                      icon: const Icon(Icons.copy),
                                      onPressed: () async {
                                        await Clipboard.setData(
                                          ClipboardData(
                                            text: groupBuilder
                                                .map((e) =>
                                                    "Group ${groupBuilder.indexOf(e) + 1}: ${e.items.join(', ')}")
                                                .join('\n'),
                                          ),
                                        );
                                      },
                                    ),
                                  ),
                                ),
                        ],
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 72),
              ],
            ),
          ),
        ),
        error: (error, stackTrace) => Center(child: Text(error.toString())),
        loading: () => const Center(child: CircularProgressIndicator()),
      ),
    );
  }
}
