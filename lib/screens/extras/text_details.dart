// enter text details here
import 'package:flutter/material.dart';

class TextDetails extends StatelessWidget {
  final String title;
  final String hint;
  final bool obscure;
  final TextInputType keyboard;
  final bool dropdown;
  final String value;
  final List<String> items;
  final Function onChanged;
  final TextEditingController textController = TextEditingController();

  TextDetails(
    this.title, {
    this.hint,
    this.obscure,
    this.keyboard,
    this.dropdown,
    this.value,
    this.items,
    this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    textController.text = value ?? '';
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Text(
          title,
          textAlign: TextAlign.start,
          style: TextStyle(
            color: Colors.black,
            fontSize: 17.0,
            fontWeight: FontWeight.bold,
          ),
        ),
        Padding(padding: EdgeInsets.all(10.0)),
        dropdown == null || dropdown == false
            ? Container(
                decoration: new BoxDecoration(
                  border: new Border(
                    top: new BorderSide(color: Colors.grey[300]),
                    left: new BorderSide(color: Colors.grey[300]),
                    right: new BorderSide(color: Colors.grey[300]),
                    bottom: new BorderSide(color: Colors.grey[300]),
                  ),
                ),
                padding: EdgeInsets.symmetric(horizontal: 20.0),
                child: new Row(
                  children: <Widget>[
                    new Flexible(
                      child: new TextField(
                        // ?? -> choose value on left if not null, else value on right
                        keyboardType: keyboard ?? TextInputType.text,
                        controller: value != null ? textController : null,
                        onChanged: (String str) => onChanged(str),
                        maxLines: 1,
                        obscureText: obscure ?? false,
                        decoration: new InputDecoration(
                          hintText: hint ?? '',
                          border: InputBorder.none,
                        ),
                      ),
                    )
                  ],
                ),
              )
            : Card(
                elevation: 2.5,
                child: Container(
                  margin: EdgeInsets.symmetric(horizontal: 10.0),
                  child: DropdownButtonHideUnderline(
                    child: DropdownButton(
                      value: value ?? "None",
                      items: items.map((String element) {
                        return DropdownMenuItem<String>(
                            value: element,
                            child: Text(element,
                                textScaleFactor: 0.85,
                                style: TextStyle(fontSize: 14.0)));
                      }).toList(),
                      onChanged: (String str) => onChanged(str),
                    ),
                  ),
                ),
              ),
      ],
    );
  }
}
