import 'package:flutter/material.dart';
import 'package:flutter_application_2/core/constants/colors.dart' show AppColors;

class CustomProfileInfoRow extends StatefulWidget {
  const CustomProfileInfoRow({
    super.key,
    required this.text,
    required this.onSave, 
    required this.label,
  });
  final String label;
  final String text;
  final Function(String) onSave; 

  @override
  State<CustomProfileInfoRow> createState() => _CustomProfileInfoRowState();
}

class _CustomProfileInfoRowState extends State<CustomProfileInfoRow> {
  bool _isEditing = false;
  late TextEditingController _controller;

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController(text: widget.text);
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.start,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
       Text(widget.label ,style: TextStyle(fontSize: 16 , fontWeight: FontWeight.bold , color: AppColors.blackColor), ),
        // SizedBox(height: 5,),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Expanded(
              child: _isEditing
                  ? TextField(
                      controller: _controller,
                      style:  TextStyle(
                        fontSize: 16,
                        color:AppColors.greyColor,
                        fontWeight: FontWeight.w500,
                      ),
                        
                      decoration: const InputDecoration(
                        // contentPadding: EdgeInsets.symmetric(vertical: 2 , horizontal: 5),
                        isDense: true,
                        border: UnderlineInputBorder(
                          borderSide: BorderSide.none,
                        ),
                      ),
                    )
                  : 
                  Text(
                      _controller.text,
                      style: const TextStyle(
                        color: Color.fromARGB(255, 76, 76, 76),                    fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
            ),
        
            IconButton(
              icon: Icon(
                _isEditing
                    ? Icons.check_circle_outline 
                    : Icons.mode_edit_outline_rounded, 
                color: Colors.blue,
                size: 25,
              ),
              onPressed: () {
                if (_isEditing) {
                  widget.onSave(_controller.text);
                }
                setState(() {
                  _isEditing = !_isEditing;
                });
              },
            ),
          ],
        ),
         const Divider(),
      ],
    );
  }
}

