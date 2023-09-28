import 'package:expandable/expandable.dart';
import 'package:flutter/material.dart';
import 'package:path/path.dart';

class UserGuid extends StatefulWidget {
  @override
  _UserGuidState createState() => _UserGuidState();
}

class _UserGuidState extends State<UserGuid> {
  bool isItem1Open = true;
  bool isItem2Open = false;
  @override
  Widget build(BuildContext context) {
    return ExpansionPanelList(
      expansionCallback: (int index, bool isExpanded) {setState(() {if(index == 0) {isItem1Open = !isExpanded;isItem2Open = false;}else {isItem2Open = !isExpanded;isItem1Open = false;}});},
      children: [
        ExpansionPanel(
          headerBuilder: (BuildContext context, bool isExpanded) {
            return ListTile(dense: true, tileColor: Colors.teal[400], selected: isItem1Open, selectedTileColor: Colors.teal[100], textColor: Colors.white, leading: CircleAvatar(radius: 15,child: Text('?')), title: Text('How to use UWB_Navigator ?'),);
          },
          body: const ListTile(title: Text('How to setup'), subtitle: Text('Please follow the instru...'),),
          isExpanded: isItem1Open,
        ),
        ExpansionPanel(
          headerBuilder: (BuildContext context, bool isExpanded) {
            return ListTile(dense: true,tileColor: Colors.teal[400], selected: isItem2Open, selectedTileColor: Colors.teal[100], textColor: Colors.white, leading: const CircleAvatar(radius: 15,child: Text('#')), title: const Text('UWB Tags'),);
          },
          body: const ListTile(title: Text('Item 2 child'), subtitle: Text('Details goes here'),),
          isExpanded: isItem2Open,
        ),

      ],
    );
  }
}
