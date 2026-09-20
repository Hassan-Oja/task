import 'package:flutter/material.dart';
import 'package:uber/widgets/custom_text_field.dart';

class HomeButtomSheet extends StatelessWidget {
  ScrollController scrollController ;
  TextEditingController destinationController;
  double ditance;
  final VoidCallback onSearch;


  HomeButtomSheet({super.key , required this.scrollController , required this.ditance , required this.destinationController , required this.onSearch});

  @override
  Widget build(BuildContext context) {
    var width = MediaQuery.of(context).size.width;
    var height = MediaQuery.of(context).size.height;
    return  Container(
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(
          top: Radius.circular(25),
        ),
      ),
      child: ListView(
        controller: scrollController,
        padding: const EdgeInsets.all(20),
        children: [
          const Center(child: Icon(Icons.drag_handle, size: 30)),
          const SizedBox(height: 20),
          Text('${ditance!.toStringAsFixed(2)} km',
            style: const TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),
          CustomTextField(
              hintText: "Enter Your Destination ",
              controller: destinationController
          ),
          ElevatedButton(
            onPressed: onSearch,
            child: const Text('Search'),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.deepPurple,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
              padding: EdgeInsets.symmetric(
                horizontal: width * 0.1,
                vertical: height * 0.01,
              ),
            ),
          )
        ],
      ),
    );;
  }
}
