import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

void main() {
  runApp(MaterialApp(
    home: ManualCoordinationPage(),
  ));
}

class ManualCoordinationPage extends StatefulWidget {
  const ManualCoordinationPage({Key? key}) : super(key: key);

  @override
  _ManualCoordinationPageState createState() => _ManualCoordinationPageState();
}

class _ManualCoordinationPageState extends State<ManualCoordinationPage> {
  double scale1 = 1.0;
  double rotation1 = 0.0;
  double top1 = 100.0;
  double left1 = 100.0;

  double scale2 = 1.0;
  double rotation2 = 0.0;
  double top2 = 300.0;
  double left2 = 100.0;

  double scale3 = 1.0;
  double rotation3 = 0.0;
  double top3 = 500.0;
  double left3 = 100.0;

  int selectedImage = 0;

  List<String> images = [
    'https://c.imgz.jp/276/83398276/83398276b_34_d_35.jpg',
    'https://c.imgz.jp/648/75392648/75392648b_163_d_35.jpg',
    'https://c.imgz.jp/246/324266246/324266246b_28_d_35.jpg'
  ];

  List<String> availableImages = [
    'https://c.imgz.jp/276/83398276/83398276b_34_d_35.jpg',
    'https://c.imgz.jp/648/75392648/75392648b_163_d_35.jpg',
    'https://c.imgz.jp/246/324266246/324266246b_28_d_35.jpg'
  ];

  final picker = ImagePicker();

  Future<void> addImage() async {
    final pickedFile = await picker.pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      setState(() {
        images.add(pickedFile.path);
      });
    }
  }

  void showImageList(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (context) {
        return FractionallySizedBox(
          heightFactor: 0.5,
          child: GridView.builder(
            gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 3,
            ),
            itemCount: availableImages.length,
            itemBuilder: (context, index) {
              return GestureDetector(
                onTap: () {
                  setState(() {
                    images.add(availableImages[index]);
                    availableImages.removeAt(index);
                  });
                  Navigator.pop(context);
                },
                child: Image.network(
                  availableImages[index],
                  fit: BoxFit.cover,
                  errorBuilder: (context, error, stackTrace) {
                    return Center(child: Icon(Icons.error));
                  },
                ),
              );
            },
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('コーデをつくる')),
      body: Stack(
        children: <Widget>[
          buildImage(1, top1, left1, scale1, rotation1),
          buildImage(2, top2, left2, scale2, rotation2),
          buildImage(3, top3, left3, scale3, rotation3),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => showImageList(context),
        child: Icon(Icons.add),
      ),
    );
  }

  Widget buildImage(
      int index, double top, double left, double scale, double rotation) {
    if (images.length < index) return Container();

    return Positioned(
      top: top,
      left: left,
      child: GestureDetector(
        onTap: () {
          setState(() {
            selectedImage = index;
          });
        },
        onPanUpdate: (details) {
          setState(() {
            if (selectedImage == index) {
              if (index == 1) {
                top1 += details.delta.dy;
                left1 += details.delta.dx;
              } else if (index == 2) {
                top2 += details.delta.dy;
                left2 += details.delta.dx;
              } else if (index == 3) {
                top3 += details.delta.dy;
                left3 += details.delta.dx;
              }
            }
          });
        },
        child: Transform(
          transform: Matrix4.identity()
            ..rotateZ(rotation)
            ..scale(scale),
          alignment: FractionalOffset.center,
          child: Stack(
            children: [
              Container(
                decoration: selectedImage == index
                    ? BoxDecoration(
                        border:
                            Border.all(color: Colors.purpleAccent, width: 2.0),
                      )
                    : null,
                child: Image.network(
                  images[index - 1],
                  width: 100 * scale,
                  height: 100 * scale,
                  fit: BoxFit.contain,
                  errorBuilder: (context, error, stackTrace) {
                    return Center(child: Icon(Icons.error));
                  },
                ),
              ),
              if (selectedImage == index)
                Positioned(
                  top: -12,
                  right: -12,
                  child: GestureDetector(
                    onPanUpdate: (details) {
                      setState(() {
                        if (index == 1) {
                          rotation1 += details.delta.dy / 100;
                        } else if (index == 2) {
                          rotation2 += details.delta.dy / 100;
                        } else if (index == 3) {
                          rotation3 += details.delta.dy / 100;
                        }
                      });
                    },
                    child: Icon(Icons.rotate_right, size: 24),
                  ),
                ),
              if (selectedImage == index)
                Positioned(
                  bottom: -12,
                  right: -12,
                  child: GestureDetector(
                    onPanUpdate: (details) {
                      setState(() {
                        if (index == 1) {
                          scale1 += details.delta.dy / 100;
                        } else if (index == 2) {
                          scale2 += details.delta.dy / 100;
                        } else if (index == 3) {
                          scale3 += details.delta.dy / 100;
                        }
                      });
                    },
                    child: Icon(Icons.zoom_in, size: 24),
                  ),
                ),
              if (selectedImage == index)
                Positioned(
                  top: -12,
                  left: -12,
                  child: IconButton(
                    icon: Icon(Icons.close, size: 24),
                    onPressed: () {
                      setState(() {
                        availableImages.add(images[index - 1]);
                        images.removeAt(index - 1);
                        selectedImage = 0;
                      });
                    },
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}
