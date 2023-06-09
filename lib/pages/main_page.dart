import 'package:flutter/material.dart';

import 'package:logger/logger.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:supabase_test_flutter/pages/char_room_page.dart';

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
    return Scaffold(
      appBar: AppBar(
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
  late List<Map<String, dynamic>> _users;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        border: Border.all(color: Colors.black12),
        borderRadius: BorderRadius.circular(8),
      ),
      child: RefreshIndicator(
        onRefresh: () async {
          final users = await fetchUsers();
          setState(() {
            _users = users;
          });
        },
        child: FutureBuilder<List<Map<String, dynamic>>>(
          future: fetchUsers(),
          builder: (BuildContext context, AsyncSnapshot<List<Map<String, dynamic>>> snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: Text('Connecting...'));
            }
            if (snapshot.hasError) {
              return Center(child: Text(snapshot.error.toString()));
            }
            if (snapshot.hasData) {
              _users = snapshot.data!;

              return Scrollbar(
                child: ListView.separated(
                  shrinkWrap: true,
                  physics: const AlwaysScrollableScrollPhysics(),
                  padding: const EdgeInsets.symmetric(horizontal: 0, vertical: 16),
                  itemCount: _users.length,
                  itemBuilder: (BuildContext context, int index) {
                    final user = _users[index];
                    final userName = user['name'];
                    final userId = user['id'];

                    return SizedBox(
                      height: 60,
                      child: GestureDetector(
                        behavior: HitTestBehavior.opaque,
                        onTap: () {
                          Navigator.of(context).push(
                            MaterialPageRoute(builder: (context) => ChatRoomPage(userName: userName))
                          );
                        },
                        child: Center(
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Text('$userName', style: const TextStyle(fontWeight: FontWeight.bold)),
                            ],
                          ),
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

  String _name = '';

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
                _name = value;
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
                  saveNewUser(_name).then((_) {
                    _formKey.currentState!.reset();
                    return ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text('「$_name」を追加しました')),
                    );
                  }).onError((error, stackTrace) =>
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text('追加失敗： $error')),
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

Future<List<Map<String, dynamic>>> fetchUsers() async {
  final users = await supabase.from('users').select<List<Map<String, dynamic>>>('id, name');
  logger.d(users);

  return users;
}

Future saveNewUser(String name) async {
  final user = await supabase.from('users').insert({ 'name': name });
  logger.d(user);
}
