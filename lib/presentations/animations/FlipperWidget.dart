
import 'dart:math';

import 'package:flutter/material.dart';

class FlipperWidget extends StatefulWidget {
  final String code;
  FlipperWidget(this.code);
  @override
  _FlipperWidgetState createState() => _FlipperWidgetState();
}

class _FlipperWidgetState extends State<FlipperWidget>
    with SingleTickerProviderStateMixin {
  bool reversed = false;
  Animation<double> _animation;
  AnimationController _animationController;

  @override
  void initState() {

    super.initState();
    _animationController =
        AnimationController(vsync: this, duration: Duration(milliseconds: 1));

    _animation = TweenSequence([
      TweenSequenceItem(tween: Tween(begin: 0.0, end: -pi/2), weight: 0.5),
      TweenSequenceItem(tween: Tween(begin: pi/2, end: 0.0), weight: 0.5)
    ]).animate(_animationController);
  }

  _doAnim() {
    if (!mounted) return;
    if (reversed) {
      _animationController.reverse();
      reversed = false;
    } else {
      _animationController.forward();
      reversed = true;
    }
  }

  @override
  Widget build(BuildContext context) {
    print("${widget.code}CODDDDDDDDDDDDDDDDDDDDDDDDDE");
    return Scaffold(

      body: Center(
        child: AnimatedBuilder(
          animation: _animation,
          builder: (context, child) => Transform(
            alignment: Alignment.center,
            transform: Matrix4.identity()
              ..setEntry(3, 2, 0.001)
              ..rotateY(_animation.value),
            child: GestureDetector(
              onTap: _doAnim,
              child: IndexedStack(
                children: <Widget>[CardOne(), CardTwo(widget.code)],
                alignment: Alignment.center,
                index: _animationController.value < 0.5 ? 0 : 1,
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class CardOne extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Card(
      color: Colors.red,
      child: Container(
        width: 300,
        height: 300,
        child: Center(
          child: Text(
            "Tap to see the code",
            style: TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.bold,
              fontSize: 25.0,
            ),
          ),
        ),
      ),
    );
  }
}

class CardTwo extends StatefulWidget {
  final String code;
  CardTwo(this.code);

  @override
  _CardTwoState createState() => _CardTwoState();
}

class _CardTwoState extends State<CardTwo> {


  @override
  Widget build(BuildContext context) {

    return Card(
      color: Colors.black,
      child: Container(
        width: 300,
        height: 300,
        child: Center(
          child: Text(

            widget.code,
            style: TextStyle(
              color: Colors.green,
              fontWeight: FontWeight.bold,
              fontSize: 35.0,
            ),
          ),
        ),
      ),
    );
  }
}