import 'dart:convert';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import 'package:google_fonts/google_fonts.dart';
import 'package:image_cropper/image_cropper.dart';
import 'package:http/http.dart' as http;
import 'package:flutter_inappwebview/flutter_inappwebview.dart';
import 'package:path_provider/path_provider.dart';
import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart' as path;
import 'package:firebase_storage/firebase_storage.dart'; // Firebase Storageのインポート

import 'AppBarWidget.dart';
import 'BottomNavBar.dart';

class AddItemPage extends StatefulWidget {
  const AddItemPage({Key? key}) : super(key: key);

  @override
  _AddItemPageState createState() => _AddItemPageState();
}

class _AddItemPageState extends State<AddItemPage> {
  File? _image;
  List<dynamic> _items = [];
  final String apiKey = 'YOUR_UPCITEMDB_API_KEY';
  final picker = ImagePicker();
  late Database db;

  @override
  void initState() {
    super.initState();
    _initDatabase();
  }

  Future<void> _initDatabase() async {
    db = await openDatabase(
      path.join(await getDatabasesPath(), 'items_database.db'),
      onCreate: (db, version) {
        return db.execute(
          "CREATE TABLE items(id INTEGER PRIMARY KEY, imagePath TEXT, tags TEXT)",
        );
      },
      version: 1,
    );
    _loadItemsFromDatabase();
  }

  Future<void> _insertItem(String imagePath, [String tags = ""]) async {
    await db.insert(
      'items',
      {'imagePath': imagePath, 'tags': tags},
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  Future<void> _loadItemsFromDatabase() async {
    final items = await _getItems();
    setState(() {
      _items = items.map((item) => File(item['imagePath'])).toList();
    });
  }

  Future<List<Map<String, dynamic>>> _getItems() async {
    return await db.query('items');
  }

  Future<void> getImage(ImageSource source) async {
    final pickedFile = await picker.pickImage(source: source);

    if (pickedFile != null) {
      _confirmSaveImage(File(pickedFile.path));
    } else {
      print('No image selected.');
    }
  }

  Future<void> _confirmSaveImage(File image) async {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('確認'),
          content: Text('この画像を保存しますか？'),
          actions: <Widget>[
            TextButton(
              child: Text('いいえ'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
            TextButton(
              child: Text('はい'),
              onPressed: () {
                Navigator.of(context).pop();
                _saveImage(image);
              },
            ),
          ],
        );
      },
    );
  }

  // 画像を削除するメソッド
  Future<void> _deleteImage(int index) async {
    final imagePath = _items[index].path;
    await db.delete('items', where: 'imagePath = ?', whereArgs: [imagePath]);
    setState(() {
      _items.removeAt(index);
    });
    final storageRef = FirebaseStorage.instance
        .ref()
        .child('images/${path.basename(imagePath)}');
    await storageRef.delete(); // Firebase Storageからも削除
  }

  Future<void> _saveImage(File image) async {
    final directory = await getApplicationDocumentsDirectory();
    final localImage =
        await image.copy('${directory.path}/${image.path.split('/').last}');
    setState(() {
      _items.add(localImage);
    });
    await _insertItem(localImage.path);
    await _uploadToFirebase(localImage);
  }

  Future<void> _uploadToFirebase(File image) async {
    try {
      final storageRef = FirebaseStorage.instance
          .ref()
          .child('images/${image.path.split('/').last}');
      await storageRef.putFile(image);
      String downloadURL = await storageRef.getDownloadURL();
      print('Image uploaded: $downloadURL');
    } catch (e) {
      print('Error uploading image: $e');
    }
  }

  Future<void> _processBarcodeImage() async {
    final pickedFile = await picker.getImage(source: ImageSource.camera);
    if (pickedFile != null) {
      CroppedFile? croppedFile = await ImageCropper().cropImage(
        sourcePath: pickedFile.path,
        aspectRatioPresets: [
          CropAspectRatioPreset.square,
        ],
        uiSettings: [
          AndroidUiSettings(
            toolbarTitle: '背景を切り取る',
            toolbarColor: Colors.deepOrange,
            toolbarWidgetColor: Colors.white,
            initAspectRatio: CropAspectRatioPreset.original,
            lockAspectRatio: false,
          ),
          IOSUiSettings(
            minimumAspectRatio: 1.0,
          ),
        ],
      );
      if (croppedFile != null) {
        _saveImage(File(croppedFile.path));
        Navigator.of(context).pop(); // 戻る処理を追加
      }
    }
  }

  void _showWebImageModal(BuildContext context) {
    TextEditingController searchController = TextEditingController();
    List<Map<String, String>> suggestions = [
      {'name': 'ユニクロ', 'url': 'https://www.uniqlo.com'},
      {'name': 'GU', 'url': 'https://www.gu-global.com'},
      {'name': 'ZARA', 'url': 'https://www.zara.com'},
      {'name': 'H&M', 'url': 'https://www.hm.com'},
      {'name': 'Forever 21', 'url': 'https://www.forever21.com'}
    ];

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return StatefulBuilder(
          builder: (context, setState) {
            return AlertDialog(
              title: Text('WEB画像選択'),
              content: SingleChildScrollView(
                child: Column(
                  children: <Widget>[
                    TextField(
                      controller: searchController,
                      decoration: InputDecoration(
                        labelText: 'ブランドサイトを検索',
                        suffixIcon: IconButton(
                          icon: Icon(Icons.search),
                          onPressed: () async {
                            // Implement search logic here to get suggestions from a search engine API

                            final newSuggestions = await _getSearchSuggestions(
                                searchController.text);
                            setState(() {
                              suggestions = newSuggestions;
                            });
                          },
                        ),
                      ),
                    ),
                    ListView.builder(
                      shrinkWrap: true,
                      itemCount: suggestions.length,
                      itemBuilder: (context, index) {
                        return ListTile(
                          title: Text(suggestions[index]['name']!),
                          onTap: () {
                            _navigateToWebPage(
                                context, suggestions[index]['url']!);
                          },
                        );
                      },
                    ),
                  ],
                ),
              ),
              actions: <Widget>[
                TextButton(
                  child: Text('閉じる'),
                  onPressed: () {
                    Navigator.of(context).pop();
                  },
                ),
              ],
            );
          },
        );
      },
    );
  }

  Future<List<Map<String, String>>> _getSearchSuggestions(String query) async {
    final response = await http.get(Uri.parse(
        'https://www.googleapis.com/customsearch/v1?key=YOUR_GOOGLE_API_KEY&cx=YOUR_CX&q=$query'));
    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      List<Map<String, String>> suggestions = [];
      for (var item in data['items']) {
        suggestions.add({
          'name': item['title'],
          'url': item['link'],
        });
      }
      return suggestions;
    } else {
      return [];
    }
  }

  Future<void> _navigateToWebPage(BuildContext context, String url) async {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => WebPage(
          url: url,
          onImageSelected: _handleImageSelectedFromWeb,
        ),
      ),
    );
  }

  void _handleImageSelectedFromWeb(String imageUrl) async {
    await _saveImageFromUrl(imageUrl); // 追加：非同期処理の完了を待機
  }

  Future<void> _confirmSaveImageFromWeb(String imageUrl) async {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('確認'),
          content: Text('この画像を保存しますか？'),
          actions: <Widget>[
            TextButton(
              child: Text('いいえ'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
            TextButton(
              child: Text('はい'),
              onPressed: () {
                Navigator.of(context).pop();
                _saveImageFromUrl(imageUrl);
              },
            ),
          ],
        );
      },
    );
  }

  Future<String> getLocalFilePath() async {
    final directory = await getApplicationDocumentsDirectory();
    return directory.path;
  }

  Future<void> _saveImageFromUrl(String imageUrl) async {
    try {
      // Check if imageUrl is a local file path
      if (imageUrl.startsWith('http') || imageUrl.startsWith('https')) {
        final response = await http.get(Uri.parse(imageUrl));
        if (response.statusCode == 200) {
          final directory = await getApplicationDocumentsDirectory();
          final file = File('${directory.path}/${imageUrl.split('/').last}');
          await file.writeAsBytes(response.bodyBytes);
          setState(() {
            _items.add(file);
          });
          await _insertItem(file.path);
          await _uploadToFirebase(file);
        } else {
          print('Failed to download image');
        }
      } else {
        // If imageUrl is a local file path, directly use it
        final file = File(imageUrl);
        setState(() {
          _items.add(file);
        });
        await _insertItem(file.path);
        await _uploadToFirebase(file);
      }
    } catch (e) {
      print('Error saving image from URL: $e');
    }
  }

  // 画像削除の確認ポップアップを表示するメソッド
  void _confirmDeleteImage(BuildContext context, int index) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('確認'),
          content: Text('この画像を削除しますか？'),
          actions: <Widget>[
            TextButton(
              child: Text('いいえ'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
            TextButton(
              child: Text('はい'),
              onPressed: () {
                Navigator.of(context).pop();
                _deleteImage(index);
              },
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'アイテムを追加',
          style: GoogleFonts.getFont('Kosugi Maru', fontSize: 20),
        ),
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Expanded(
            child: GridView.builder(
              padding: const EdgeInsets.all(10.0),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 3,
                  crossAxisSpacing: 8.0,
                  mainAxisSpacing: 8.0),
              itemCount: _items.length,
              itemBuilder: (BuildContext context, int index) {
                return GestureDetector(
                  onTap: () {
                    // Implement your logic to handle item tap
                  },
                  child: Stack(
                    children: [
                      Image.file(
                        _items[index],
                        fit: BoxFit.cover,
                      ),
                      Positioned(
                        top: 0,
                        right: 0,
                        child: IconButton(
                          icon: Icon(Icons.delete),
                          color: Colors.red,
                          onPressed: () => _confirmDeleteImage(context, index),
                        ),
                      ),
                    ],
                  ),
                );
              },
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                ElevatedButton.icon(
                  onPressed: () => getImage(ImageSource.gallery),
                  icon: Icon(Icons.add),
                  label: Text('画像を追加'),
                ),
                ElevatedButton.icon(
                  onPressed: _processBarcodeImage,
                  icon: Icon(Icons.camera_alt),
                  label: Text('カメラから追加'),
                ),
                ElevatedButton.icon(
                  onPressed: () => _showWebImageModal(context),
                  icon: Icon(Icons.web),
                  label: Text('WEBから画像を追加'),
                ),
              ],
            ),
          ),
        ],
      ),
      bottomNavigationBar: BottomNavBar(),
    );
  }
}

class WebPage extends StatefulWidget {
  final String url;
  final Function(String) onImageSelected;

  WebPage({required this.url, required this.onImageSelected});

  @override
  _WebPageState createState() => _WebPageState();
}

class _WebPageState extends State<WebPage> {
  late InAppWebViewController webViewController;
  List<String> imageUrls = [];
  String? selectedImageUrl;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Web Page'),
      ),
      body: Column(
        children: [
          Expanded(
            child: InAppWebView(
              initialUrlRequest:
                  URLRequest(url: WebUri(Uri.parse(widget.url).toString())),
              onWebViewCreated: (controller) {
                webViewController = controller;
                controller.addJavaScriptHandler(
                    handlerName: 'imageUrls',
                    callback: (args) {
                      setState(() {
                        imageUrls = List<String>.from(args[0]);
                      });
                      if (imageUrls.isNotEmpty) {
                        _showImageSelectionDialog(context);
                      }
                    });
              },
            ),
          ),
          Container(
            height: 60,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                ElevatedButton(
                  onPressed: () {
                    if (webViewController != null) {
                      webViewController.goBack();
                    }
                  },
                  child: Text('戻る'),
                ),
                ElevatedButton(
                  onPressed: () {
                    if (webViewController != null) {
                      webViewController.goForward();
                    }
                  },
                  child: Text('進む'),
                ),
                ElevatedButton(
                  onPressed: () async {
                    if (webViewController != null) {
                      await webViewController.evaluateJavascript(source: """
                        var images = document.querySelectorAll('img');
                        var maxWidth = 0;
                        var targetImages = [];
                        images.forEach(function(img) {
                          var width = img.naturalWidth;
                          if (width > maxWidth) {
                            maxWidth = width;
                            targetImages = [img.src];
                          } else if (width == maxWidth) {
                            targetImages.push(img.src);
                          }
                        });
                        window.flutter_inappwebview.callHandler('imageUrls', targetImages);
                      """);
                    }
                  },
                  child: Text('画像を取り込む'),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  void _showImageSelectionDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('画像を選択'),
          content: SingleChildScrollView(
            child: Column(
              children: imageUrls.map((url) {
                return GestureDetector(
                  onTap: () {
                    setState(() {
                      selectedImageUrl = url;
                    });
                    _confirmSaveImage(context, url);
                  },
                  child: Container(
                    margin: EdgeInsets.symmetric(vertical: 5),
                    decoration: BoxDecoration(
                      border: Border.all(
                        color: selectedImageUrl == url
                            ? Colors.blue
                            : Colors.transparent,
                        width: 2,
                      ),
                    ),
                    child: Image.network(url, height: 100, fit: BoxFit.cover),
                  ),
                );
              }).toList(),
            ),
          ),
          actions: <Widget>[
            TextButton(
              child: Text('閉じる'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }

  void _confirmSaveImage(BuildContext context, String imageUrl) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('確認'),
          content: Text('この画像を保存しますか？'),
          actions: <Widget>[
            TextButton(
              child: Text('いいえ'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
            TextButton(
              child: Text('はい'),
              onPressed: () {
                Navigator.of(context).pop();
                _saveImageFromUrl(imageUrl);
              },
            ),
          ],
        );
      },
    );
  }

  Future<void> _saveImageFromUrl(String imageUrl) async {
    try {
      final response = await http.get(Uri.parse(imageUrl));
      if (response.statusCode == 200) {
        final directory = await getApplicationDocumentsDirectory();
        final file = File('${directory.path}/${imageUrl.split('/').last}');
        await file.writeAsBytes(response.bodyBytes);
        final croppedFile = await ImageCropper().cropImage(
          sourcePath: file.path,
          aspectRatioPresets: [CropAspectRatioPreset.square],
          uiSettings: [
            AndroidUiSettings(
              toolbarTitle: '背景を切り取る',
              toolbarColor: Colors.deepOrange,
              toolbarWidgetColor: Colors.white,
              initAspectRatio: CropAspectRatioPreset.original,
              lockAspectRatio: false,
            ),
            IOSUiSettings(
              minimumAspectRatio: 1.0,
            ),
          ],
        );
        if (croppedFile != null) {
          final croppedImage = File(croppedFile.path);
          widget.onImageSelected(croppedImage.path);
          Navigator.of(context).pop(); // 画像を切り取った後にダイアログを閉じる
        }
      }
    } catch (e) {
      print('Error saving image: $e');
      // エラーハンドリングを追加
      showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: Text('エラー'),
            content: Text('画像の保存中にエラーが発生しました。もう一度お試しください。'),
            actions: <Widget>[
              TextButton(
                child: Text('閉じる'),
                onPressed: () {
                  Navigator.of(context).pop();
                },
              ),
            ],
          );
        },
      );
    }
  }
}

void main() {
  runApp(MaterialApp(
    home: AddItemPage(),
  ));
}
