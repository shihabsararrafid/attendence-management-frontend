import 'package:flutter/material.dart';
import 'package:carousel_slider/carousel_slider.dart';

class CarouselPage extends StatelessWidget {
  final List<Widget> carouselItems = [
    CarouselItem(
      image: 'assets/images/attendence.jpg',
      text: 'Effortless Attendance Management',
    ),
    CarouselItem(
      image: 'assets/images/anywhere.jpg',
      text: 'Track Attendance Anywhere, Anytime',
    ),
    CarouselItem(
      image: 'assets/images/qrcode.jpg',
      text: 'Boost Efficiency with QR Code Attendance',
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: false,
      body: Column(
        children: [
          Expanded(
            child: CarouselSlider(
              items: carouselItems,
              options: CarouselOptions(
                enlargeCenterPage: true,
                autoPlay: true,
                height: MediaQuery.of(context).size.height,
                autoPlayInterval: Duration(seconds: 3),
              ),
            ),
          ),
          SizedBox(height: 20.0),
          // RaisedButton(
          //   child: Text('Sign Up'),
          //   onPressed: () {
          //     // Add sign-up button functionality
          //   },
          // ),
          // RaisedButton(
          //   child: Text('Login'),
          //   onPressed: () {
          //     // Add login button functionality
          //   },
          // ),
        ],
      ),
    );
  }

  RaisedButton({required Text child, required Null Function() onPressed}) {}
}

class CarouselItem extends StatelessWidget {
  final String image;
  final String text;

  const CarouselItem({Key? key, required this.image, required this.text})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.symmetric(horizontal: 8.0),
      child: Column(
        children: [
          Image.asset(
            image,
            height: MediaQuery.of(context).size.height * .5,
            width: MediaQuery.of(context).size.width,
          ),
          SizedBox(height: 10.0),
          Text(
            text,
            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
          ),
        ],
      ),
    );
  }
}
