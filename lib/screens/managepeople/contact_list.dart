import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../models/speed_contacts.dart';

class ContactListScreen extends StatefulWidget {
  static const screenId = 'contactlist_screen';
  ContactListScreen({Key? key}) : super(key: key);

  @override
  State<ContactListScreen> createState() => ContactListScreenState();
}

class ContactListScreenState extends State<ContactListScreen> {
  List<dynamic> contactList = [];

  List<String> isCheckedIds = [];

  // Fetch content from the json file
  Future<void> readJson() async {
    final String response =
        await rootBundle.loadString('assets/images/list_contact.json');
    final data = await json.decode(response);

    setState(() {
      contactList = data["contacts"];
    });
  }

  @override
  void initState() {
    readJson();
  }

  @override
  void dispose() {
    // TODO: implement dispose
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (contactList.isEmpty) {
      contactList = <ContactList>[];
    }
    return Scaffold(
      appBar: AppBar(
        title: const Text('Speed Contacts'),
      ),
      body: _buildListView(),
      floatingActionButton: FloatingActionButton(
        child: const Icon(Icons.add),
        onPressed: () {},
      ),
    );
  }

  Widget _buildListView() {
    return ListView.builder(
      padding: const EdgeInsets.all(16.0),
      itemCount: contactList == null ? 0 : contactList.length,
      itemBuilder: (context, index) {
        return Card(
          child: InkWell(
            onTap: () {},
            child: ListTile(
              title: Text(contactList[index]['first'] +
                  ' ' +
                  contactList[index]['last']),
              subtitle: Text(contactList[index]['relationship']),
              trailing: Checkbox(
                value: isCheckedIds.contains(contactList[index]['id']),
                onChanged: (value) {
                  if (value!) {
                    setState(() {
                      isCheckedIds.add(contactList[index]['id']);
                    });
                  } else {
                    setState(() {
                      isCheckedIds.remove(contactList[index]['id']);
                    });
                  }
                },
              ),
            ),
          ),
        );
      },
    );
  }
}
