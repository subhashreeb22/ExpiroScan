import 'package:flutter/material.dart';
class CustomSearchBox extends StatefulWidget {
  final ValueChanged<String> onTextChanged;

  const CustomSearchBox({Key? key, required this.onTextChanged})
      : super(key: key);

  @override
  _CustomSearchBoxState createState() => _CustomSearchBoxState();
}

class _CustomSearchBoxState extends State<CustomSearchBox> {
  TextEditingController _searchController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        border: Border.all(color: Colors.black, width: 3.0), // Increase border width here
        borderRadius: BorderRadius.circular(20),
      ),
      padding: EdgeInsets.symmetric(horizontal: 16),
      child: Row(
        children: [
          Icon(Icons.search),
          SizedBox(width: 10),
          Expanded(
            child: TextField(
              controller: _searchController,
              onChanged: (value) {
                widget.onTextChanged(value); // Pass the search text to the parent widget
              },
              decoration: InputDecoration(
                hintText: 'Search...',
                border: InputBorder.none,
              ),
            ),
          ),
          if (_searchController.text.isNotEmpty)
            GestureDetector(
              onTap: () {
                setState(() {
                  _searchController.clear();
                });
                widget.onTextChanged(''); // Clear the search text
              },
              child: Icon(Icons.clear),
            ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }
}
