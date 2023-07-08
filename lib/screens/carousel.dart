import 'package:flutter/material.dart';
import 'package:carousel_slider/carousel_slider.dart';

class CarouselPage extends StatefulWidget {
  @override
  State<CarouselPage> createState() => _CarouselPageState();
}

class _CarouselPageState extends State<CarouselPage> {
  final List<Widget> carouselItems = [
    CarouselItem(
      image: 'assets/images/attendence.jpg',
      text: 'Effortless Attendance Management',
      description:
          'Track attendance seamlessly with our user-friendly app. Say goodbye to manual attendance sheets.',
    ),
    CarouselItem(
      image: 'assets/images/anywhere.jpg',
      text: 'Track Attendance Anywhere, Anytime',
      description:
          'Our app allows you to monitor attendance from anywhere, at any time, providing flexibility and convenience.',
    ),
    CarouselItem(
      image: 'assets/images/qrcode.jpg',
      text: 'Boost Efficiency with QR Code Attendance',
      description:
          'Save time and improve efficiency by utilizing QR code technology for hassle-free attendance tracking.',
    ),
  ];
  int _currentCarouselIndex = 0;
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: false,
      body: Column(
        children: [
          Expanded(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(10, 20, 10, 20),
              child: CarouselSlider(
                items: carouselItems,
                options: CarouselOptions(
                  enlargeCenterPage: true,
                  autoPlay: true,
                  disableCenter: true,
                  viewportFraction: 1,
                  height: MediaQuery.of(context).size.height,
                  autoPlayInterval: Duration(seconds: 5),
                  onPageChanged: (index, reason) {
                    setState(() {
                      _currentCarouselIndex = index;
                    });
                  },
                ),
              ),
            ),
          ),
          SizedBox(height: 10.0),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: carouselItems.map((item) {
              int index = carouselItems.indexOf(item);
              return Container(
                width: 8.0,
                height: 8.0,
                margin: EdgeInsets.symmetric(vertical: 10.0, horizontal: 2.0),
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: _currentCarouselIndex == index
                      ? Colors.blue
                      : Colors.grey,
                ),
              );
            }).toList(),
          ),
          SizedBox(height: 30.0),
          Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              GestureDetector(
                onTap: () {
                  Navigator.pushNamed(context, '/login');
                },
                child: Container(
                  width: MediaQuery.of(context).size.width * .4,
                  height: 50,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(15),
                    color: Colors.blue,
                  ),
                  child: Center(
                      child: Text(
                    'Sign In',
                    style: TextStyle(
                        color: Colors.white,
                        fontSize: 17,
                        fontWeight: FontWeight.bold),
                  )),
                ),
              ),
              SizedBox(
                width: 10,
              ),
              GestureDetector(
                onTap: () {
                  Navigator.pushNamed(context, '/register');
                },
                child: Container(
                  width: MediaQuery.of(context).size.width * .4,
                  height: 50,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(15),
                    border: Border.all(color: Colors.blue, width: 2),
                    color: Colors.white,
                  ),
                  child: Center(
                    child: Text(
                      'Sign Up',
                      style: TextStyle(
                          color: Colors.blue,
                          fontSize: 17,
                          fontWeight: FontWeight.bold),
                    ),
                  ),
                ),
              ),
            ],
          ),
          SizedBox(height: 40.0),
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

  final String description;

  const CarouselItem(
      {Key? key,
      required this.image,
      required this.text,
      required this.description})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.symmetric(horizontal: 8.0),
      child: Column(
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(40),
            child: Image.asset(
              image,
              height: MediaQuery.of(context).size.height * .5,
              width: MediaQuery.of(context).size.width,
            ),
          ),
          SizedBox(height: 10.0),
          Text(
            text,
            textAlign: TextAlign.center,
            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 22),
          ),
          SizedBox(
            height: 30,
          ),
          Text(
            description,
            textAlign: TextAlign.justify,
            style: TextStyle(fontWeight: FontWeight.normal, fontSize: 16),
          ),
        ],
      ),
    );
  }
}
