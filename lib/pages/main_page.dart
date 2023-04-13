import 'package:flutter/material.dart';

import 'package:logger/logger.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

final logger = Logger();
final supabase = Supabase.instance.client;

class MainPage extends StatefulWidget {
  const MainPage({super.key});

  @override
  State<MainPage> createState() => _MainPageState();
}

class _MainPageState extends State<MainPage> {
  @override
  Widget build(BuildContext context) {
    // This method is rerun every time setState is called, for instance as done
    // by the _incrementCounter method above.
    //
    // The Flutter framework has been optimized to make rerunning build methods
    // fast, so that you can just rebuild anything that needs updating rather
    // than having to individually change instances of widgets.
    return Scaffold(
      appBar: AppBar(
        // Here we take the value from the MainPage object that was created by
        // the App.build method, and use it to set our appbar title.
        title: const Text('ホーム'),
      ),
      body: Container(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: <Widget>[
            Container(
              padding: const EdgeInsets.all(20),
              child: Text(
                '名前を選んでね',
                style: Theme.of(context).textTheme.titleLarge,
                textAlign: TextAlign.center,
              ),
            ),
            Expanded(
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 20),
                child: const UsersListComponent(),
              ),
            ),
            Container(
              padding: const EdgeInsets.all(20),
              child: const NewUserFormComponent(),
            ),
          ],
        ),
      ),
    );
  }
}

class UsersListComponent extends StatefulWidget {
  const UsersListComponent({super.key});

  @override
  UsersListComponentState createState() {
    return UsersListComponentState();
  }
}

class UsersListComponentState extends State<UsersListComponent> {
  late List users;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        border: Border.all(color: Colors.black12),
        borderRadius: BorderRadius.circular(8),
      ),
      child: RefreshIndicator(
        onRefresh: () async {
          final newUsers = await fetchUsers();
          setState(() {
            users = newUsers;
          });
        },
        child: FutureBuilder<List>(
          future: fetchUsers(),
          builder: (BuildContext context, AsyncSnapshot<List> snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: Text('Connecting...'));
            }
            if (snapshot.hasError) {
              return Center(child: Text(snapshot.error.toString()));
            }
            if (snapshot.hasData) {
              users = snapshot.data!;

              return Scrollbar(
                child: ListView.separated(
                    shrinkWrap: true,
                  physics: const AlwaysScrollableScrollPhysics(),
                  padding: const EdgeInsets.symmetric(horizontal: 0, vertical: 16),
                  itemCount: users.length,
                  itemBuilder: (BuildContext context, int index) {
                    final user = users[index];
                    final name = user['name'];

                    return SizedBox(
                      height: 60,
                      child: Center(
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text('$name', style: const TextStyle(fontWeight: FontWeight.bold)),
                            const Padding(padding: EdgeInsets.only(top: 8)),
                          ],
                        ),
                      ),
                    );
                  },
                  separatorBuilder: (BuildContext context, int index) => const Divider(),
                ),
              );
            }

            return const Center(child: Text('Failed to fetch data...'));
          }
        ),
      ),
    );
  }
}

class NewUserFormComponent extends StatefulWidget {
  const NewUserFormComponent({super.key});

  @override
  NewUserFormComponentState createState() {
    return NewUserFormComponentState();
  }
}

class NewUserFormComponentState extends State<NewUserFormComponent> {
  final _formKey = GlobalKey<FormState>();

  String name = '';

  @override
  Widget build(BuildContext context) {
    return Form(
      key: _formKey,
      child: Row(
        children: [
          Flexible(
            child: TextFormField(
              decoration: const InputDecoration(
                labelText: '新しい名前を入力',

              ),
              onChanged: (value) {
                name = value;
              },
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return '文字を入力してください';
                }
                return null;
              },
            ),
          ),
          const Padding(padding: EdgeInsets.only(right: 14)),
          Align(
            alignment: Alignment.centerRight,
            child: ElevatedButton(
              onPressed: () {
                if (_formKey.currentState!.validate()) {
                  saveNewUser(name).then((_) {
                    _formKey.currentState!.reset();
                    return ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text('Saved $name')),
                    );
                  }).onError((error, stackTrace) =>
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text('Failed $error')),
                    ),
                  );
                }
              },
              child: const Text('追加'),
            ),
          ),
        ],
      ),
    );
  }
}

Future<List> fetchUsers() async {
  final users = await supabase.from('users').select('name');
  logger.d(users);

  return users as List;
}

Future saveNewUser(String name) async {
  final user = await supabase.from('users').insert({ 'name': name });
  logger.d(user);
}
