import 'package:flutter/material.dart';
import 'package:flutter_form_builder/flutter_form_builder.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:randomizer/model/group_list.dart';
import 'package:randomizer/providers/list_detail_provider.dart';

class PickElement extends ConsumerStatefulWidget {
  const PickElement({super.key, required this.groupList});

  final GroupList groupList;

  @override
  ConsumerState<PickElement> createState() => _PickElementState();
}

class _PickElementState extends ConsumerState<PickElement> {
  final _formKey = GlobalKey<FormBuilderState>();

  @override
  Widget build(BuildContext context) {
    final listDetail = ref.watch(listDetailProvider);

    return Scaffold(
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          if (_formKey.currentState!.saveAndValidate()) {
            ref.read(listDetailProvider.notifier).pickElement(
                  widget.groupList,
                  (_formKey.currentState!.fields["amount"]!.value as double).toInt(),
                );
          }
        },
        icon: const Icon(Icons.shuffle),
        label: const Text("Pick Element"),
      ),
      body: Padding(
        padding: const EdgeInsets.all(8.0),
        child: FormBuilder(
          key: _formKey,
          child: Column(
            children: [
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: FormBuilderSlider(
                  name: "amount",
                  initialValue: 1,
                  min: widget.groupList.items.length == 1 ? 0 : 1,
                  max: widget.groupList.items.length.toDouble(),
                  divisions:
                      widget.groupList.items.length == 1 ? 1 : widget.groupList.items.length - 1,
                  maxValueWidget: (max) => Container(),
                  valueWidget: (value) => Text("$value elements"),
                  minValueWidget: (min) => Container(),
                  decoration: const InputDecoration(
                    labelText: "Amount Element Picked",
                    border: InputBorder.none,
                  ),
                ),
              ),
              Expanded(
                child: Card(
                  child: Padding(
                    padding: const EdgeInsets.all(8),
                    child: Center(
                      child: SingleChildScrollView(
                        child: listDetail.isEmpty
                            ? const Text("No Element Picked")
                            : ListView.builder(
                                shrinkWrap: true,
                                primary: false,
                                itemCount: listDetail.length,
                                itemBuilder: (context, index) {
                                  return Padding(
                                    padding: const EdgeInsets.all(4),
                                    child: Card(
                                      color: Theme.of(context).colorScheme.secondaryContainer,
                                      child: Padding(
                                        padding: const EdgeInsets.all(12),
                                        child: Text(
                                          listDetail[index],
                                          textAlign: TextAlign.center,
                                          style: Theme.of(context).textTheme.titleLarge,
                                        ),
                                      ),
                                    ),
                                  );
                                },
                              ),
                      ),
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 72),
            ],
          ),
        ),
      ),
    );
  }
}