import 'package:flutter/material.dart';

class Labels extends StatelessWidget {

  final String nextRoute;
  final String firstLabel;
  final String secondLabel;

  const Labels({
    Key key, 
    @required this.nextRoute,
    @required this.firstLabel,
    @required this.secondLabel
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      child: Column(
        children: [
          Text(
            this.firstLabel,
            style: TextStyle(
              color: Colors.black54,
              fontSize: 15.0,
              fontWeight: FontWeight.w300
            ),
          ),
          SizedBox(
            height: 10.0,
          ),
          GestureDetector(
            onTap: () { 
              Navigator.pushReplacementNamed(context, this.nextRoute);
            },
            child: Text(
              this.secondLabel,
              style: TextStyle(
                color: Colors.blue[600],
                fontSize: 18,
                fontWeight: FontWeight.bold
              ),
            ),
          )
        ],
      ),
    );
  }
}