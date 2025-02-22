import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:handover/shared/config/notion_api.dart';

void main() {
  runApp(const MyApp());
}

// Global settings storage.
class GlobalSettings {
  static String apiToken = "";
  static String databaseId = "";
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      home: const MyHomePage(title: 'Handover'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key, required this.title});
  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

// The Cubit state for managing the input fields.
class InputFormState {
  final String numberInput;
  final String dropdownValue;
  final DateTime? date;

  InputFormState({
    this.numberInput = '',
    this.dropdownValue = 'Option 1',
    this.date,
  });

  InputFormState copyWith({
    String? numberInput,
    String? dropdownValue,
    DateTime? date,
  }) {
    return InputFormState(
      numberInput: numberInput ?? this.numberInput,
      dropdownValue: dropdownValue ?? this.dropdownValue,
      date: date ?? this.date,
    );
  }
}

class InputFormCubit extends Cubit<InputFormState> {
  InputFormCubit() : super(InputFormState());

  void updateNumber(String value) => emit(state.copyWith(numberInput: value));

  void updateDropdown(String value) =>
      emit(state.copyWith(dropdownValue: value));

  void updateDate(DateTime date) => emit(state.copyWith(date: date));
}

class _MyHomePageState extends State<MyHomePage> {
  // New method that builds a list of input fields managed by Cubit.
  Widget buildInputList(BuildContext context) {
    return BlocProvider<InputFormCubit>(
      create: (_) => InputFormCubit(),
      child: BlocBuilder<InputFormCubit, InputFormState>(
        builder: (context, state) {
          // Use a Column with a spacing widget between each input field.
          return Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              children: <Widget>[
                // Number input field.
                TextField(
                  decoration: const InputDecoration(
                    labelText: 'Number Input',
                    border: OutlineInputBorder(),
                  ),
                  keyboardType: TextInputType.number,
                  onChanged: (value) {
                    context.read<InputFormCubit>().updateNumber(value);
                  },
                ),
                const SizedBox(height: 16),
                // Dropdown field.
                DropdownButtonFormField<String>(
                  decoration: const InputDecoration(
                    labelText: 'Dropdown Input',
                    border: OutlineInputBorder(),
                  ),
                  value: state.dropdownValue,
                  items: <String>['Option 1', 'Option 2', 'Option 3']
                      .map((String value) {
                    return DropdownMenuItem<String>(
                      value: value,
                      child: Text(value),
                    );
                  }).toList(),
                  onChanged: (value) {
                    if (value != null) {
                      context.read<InputFormCubit>().updateDropdown(value);
                    }
                  },
                ),
                const SizedBox(height: 16),
                // Calendar input field.
                TextField(
                  decoration: const InputDecoration(
                    labelText: 'Calendar Input',
                    border: OutlineInputBorder(),
                  ),
                  readOnly: true,
                  controller: TextEditingController(
                    text: state.date != null
                        ? "${state.date!.toLocal()}".split(' ')[0]
                        : '',
                  ),
                  onTap: () async {
                    DateTime initialDate = state.date ?? DateTime.now();
                    DateTime? pickedDate = await showDatePicker(
                      context: context,
                      initialDate: initialDate,
                      firstDate: DateTime(2000),
                      lastDate: DateTime(2100),
                    );
                    if (pickedDate != null) {
                      context.read<InputFormCubit>().updateDate(pickedDate);
                    }
                  },
                ),
                const SizedBox(height: 16),
                // Submit button.
                ElevatedButton(
                  onPressed: () async {
                    final dateString =
                        state.date != null ? state.date!.toIso8601String() : '';
                    final notionApi = NotionApi(
                      apiToken: GlobalSettings.apiToken,
                      databaseId: GlobalSettings.databaseId,
                    );
                    await notionApi.createPage(
                        state.numberInput, dateString, state.dropdownValue);
                  },
                  child: const Text("Submit"),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        centerTitle: true, // Center title for better formatting.
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        title: Text(
          widget.title,
          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 20),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.settings),
            onPressed: () {
              // Navigate to the settings page.
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const SettingsPage()),
              );
            },
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            // Existing widgets.
            const SizedBox(height: 16),
            const SizedBox(height: 32),
            // New input fields section.
            buildInputList(context),
          ],
        ),
      ),
    );
  }
}

// New SettingsPage with two text fields for API token and Database ID.
class SettingsPage extends StatefulWidget {
  const SettingsPage({super.key});

  @override
  State<SettingsPage> createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {
  late TextEditingController apiTokenController;
  late TextEditingController databaseIdController;

  @override
  void initState() {
    super.initState();
    apiTokenController = TextEditingController(text: GlobalSettings.apiToken);
    databaseIdController =
        TextEditingController(text: GlobalSettings.databaseId);
  }

  @override
  void dispose() {
    apiTokenController.dispose();
    databaseIdController.dispose();
    super.dispose();
  }

  void saveSettings() {
    setState(() {
      GlobalSettings.apiToken = apiTokenController.text;
      GlobalSettings.databaseId = databaseIdController.text;
    });
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Settings"),
        centerTitle: true,
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            TextField(
              controller: apiTokenController,
              decoration: const InputDecoration(
                labelText: "API Token",
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: databaseIdController,
              decoration: const InputDecoration(
                labelText: "Database ID",
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: saveSettings,
              child: const Text("Save Settings"),
            ),
          ],
        ),
      ),
    );
  }
}
