import 'package:flutter/material.dart';

class appBar extends StatefulWidget {
  const appBar({super.key});

  @override
  State<appBar> createState() =>
      _appBarState(title: 'Default Title', backgroundColor: Colors.transparent);
}

class _appBarState extends State<appBar> {
  final String title;
  final Color backgroundColor;

  _appBarState({required this.title, required this.backgroundColor});

  @override
  Widget build(BuildContext context) {
    return AppBar(
      title: Text(title,
          style: TextStyle(
              color: Colors.white,
              fontSize: 20,
              fontFamily: 'Poppins')), // You can add title here
      backgroundColor: backgroundColor,
      flexibleSpace: Image(
        image: AssetImage('assets/images/1.png'),
        fit: BoxFit.cover,
      ),
      centerTitle: true,
      leading: new IconButton(
        icon: new Icon(Icons.arrow_back_ios_new, color: Colors.white),
        onPressed: () => Navigator.of(context).pop(),
      ),
      elevation: 0.0, //No shadow
    );
  }
}
