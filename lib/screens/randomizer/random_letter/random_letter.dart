import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_form_builder/flutter_form_builder.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:randomizer/providers/random_letter_provider.dart';
import 'package:randomizer/static/strings.dart';

class RandomLetterScreen extends ConsumerStatefulWidget {
  const RandomLetterScreen({super.key});

  @override
  ConsumerState<RandomLetterScreen> createState() => _RandomLetterScreenState();
}

class _RandomLetterScreenState extends ConsumerState<RandomLetterScreen> {
  final _formKey = GlobalKey<FormBuilderState>();

  @override
  Widget build(BuildContext context) {
    final randomLetter = ref.watch(randomLetterProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text(StaticStrings.randomLetter),
        actions: [
          IconButton(
            icon: const Icon(Icons.restore_rounded),
            onPressed: () {
              FocusScope.of(context).unfocus();
              _formKey.currentState!.reset();
              ref.read(randomLetterProvider.notifier).reset();
            },
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        label: const Text("Generate Letter"),
        icon: const Icon(Icons.shuffle),
        onPressed: () {
          FocusScope.of(context).unfocus();
          if (_formKey.currentState!.saveAndValidate()) {
            ref.read(randomLetterProvider.notifier).generateRandomLetter(
                  int.parse(_formKey.currentState!.value['amount'] as String),
                  _formKey.currentState!.value['type'] as String,
                );
          }
        },
      ),
      body: Padding(
        padding: const EdgeInsets.all(8.0),
        child: FormBuilder(
          key: _formKey,
          child: Column(
            children: [
              FormBuilderTextField(
                name: 'amount',
                initialValue: "1",
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(
                  labelText: "Amount letter generated",
                  border: OutlineInputBorder(),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter amount of letter generated';
                  }

                  if (int.tryParse(value) == null) {
                    return 'Please enter a valid number (integer)';
                  }

                  if (int.parse(value) < 1 || int.parse(value) > 500) {
                    return 'Please enter amount of letter generated between 1 and 500';
                  }

                  return null;
                },
              ),
              const SizedBox(height: 12),
              FormBuilderDropdown(
                name: 'type',
                initialValue: "both",
                decoration: const InputDecoration(
                  labelText: "Type of letter",
                  border: OutlineInputBorder(),
                ),
                items: const [
                  DropdownMenuItem(
                    value: "uppercase",
                    child: Text("Uppercase Only"),
                  ),
                  DropdownMenuItem(
                    value: "lowercase",
                    child: Text("Lowercase Only"),
                  ),
                  DropdownMenuItem(
                    value: "both",
                    child: Text("Both Uppercase and Lowercase"),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Expanded(
                child: Card(
                  child: Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Stack(
                      children: [
                        Center(
                          child: SingleChildScrollView(
                            child: randomLetter.isEmpty
                                ? FaIcon(
                                    FontAwesomeIcons.font,
                                    color: Theme.of(context)
                                        .colorScheme
                                        .onPrimaryContainer
                                        .withOpacity(0.5),
                                    size: 128,
                                  )
                                : ListView.builder(
                                    shrinkWrap: true,
                                    primary: false,
                                    itemCount: randomLetter.length,
                                    itemBuilder: (context, index) {
                                      return Padding(
                                        padding: const EdgeInsets.all(4),
                                        child: Card(
                                          color: Theme.of(context).colorScheme.secondaryContainer,
                                          child: Padding(
                                            padding: const EdgeInsets.all(12),
                                            child: Stack(
                                              children: [
                                                Positioned(
                                                  top: 0,
                                                  left: 0,
                                                  child: Container(
                                                    padding: const EdgeInsets.all(4),
                                                    decoration: BoxDecoration(
                                                      color: Theme.of(context)
                                                          .colorScheme
                                                          .primaryContainer,
                                                      borderRadius: BorderRadius.circular(4),
                                                    ),
                                                    child: Text("${index + 1}"),
                                                  ),
                                                ),
                                                Container(
                                                  padding: const EdgeInsets.all(8),
                                                  width: double.infinity,
                                                  child: Text(
                                                    randomLetter[index].toString(),
                                                    textAlign: TextAlign.center,
                                                    style: Theme.of(context).textTheme.titleLarge,
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
                                                          text: randomLetter[index].toString(),
                                                        ),
                                                      );
                                                    },
                                                  ),
                                                )
                                              ],
                                            ),
                                          ),
                                        ),
                                      );
                                    },
                                  ),
                          ),
                        ),
                        randomLetter.length <= 1
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
                                          text: randomLetter.join(", ").toString(),
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
    );
  }
}
