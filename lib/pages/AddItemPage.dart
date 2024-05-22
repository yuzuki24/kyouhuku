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
    _loadItemsFromDatabase();
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
      _saveImage(File(pickedFile.path));
    } else {
      print('No image selected.');
    }
  }

  Future<void> _saveImage(File image) async {
    final directory = await getApplicationDocumentsDirectory();
    final localImage =
        await image.copy('${directory.path}/${image.path.split('/').last}');
    setState(() {
      _items.add(localImage);
    });
    await _insertItem(localImage.path);
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
    // Implement search suggestion fetching logic here
    // For example, using an API to get suggestions based on the query
    // Returning static suggestions for now
    return [
      {'name': '検索結果1', 'url': 'https://example.com/search1'},
      {'name': '検索結果2', 'url': 'https://example.com/search2'},
      {'name': '検索結果3', 'url': 'https://example.com/search3'},
    ];
  }

  Future<void> _navigateToWebPage(BuildContext context, String url) async {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => WebPage(
            url: url,
            onImageSelected: (imageUrl) {
              _saveImageFromUrl(imageUrl);
            }),
      ),
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
          _saveImage(File(croppedFile.path));
        }
      }
    } catch (e) {
      print('Error saving image: $e');
    }
  }

  Future<void> _pickImageFromWeb(BuildContext context) async {
    _showWebImageModal(context);
  }

  Future<void> _deleteImage(File image) async {
    final imagePath = image.path;
    await db.delete('items', where: 'imagePath = ?', whereArgs: [imagePath]);
    setState(() {
      _items.remove(image);
    });
  }

  void _confirmDeleteImage(File image) {
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
                _deleteImage(image);
              },
            ),
          ],
        );
      },
    );
  }

  void _confirmAddImage(File image) {
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
                getImage(ImageSource.gallery);
              },
            ),
          ],
        );
      },
    );
  }

  Future<void> _addTagToImage(File image) async {
    TextEditingController tagController = TextEditingController();
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('タグを追加'),
          content: TextField(
            controller: tagController,
            decoration: InputDecoration(labelText: 'タグ'),
          ),
          actions: <Widget>[
            TextButton(
              child: Text('キャンセル'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
            TextButton(
              child: Text('追加'),
              onPressed: () async {
                final tag = tagController.text;
                if (tag.isNotEmpty) {
                  await db.update(
                    'items',
                    {'tags': tag},
                    where: 'imagePath = ?',
                    whereArgs: [image.path],
                  );
                }
                Navigator.of(context).pop();
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
      appBar: AppBarWidget(title: 'アイテムを追加'),
      body: Column(
        children: [
          Expanded(
            child: GridView.builder(
              padding: EdgeInsets.all(10),
              gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                crossAxisSpacing: 10,
                mainAxisSpacing: 10,
              ),
              itemCount: _items.length,
              itemBuilder: (BuildContext context, int index) {
                final item = _items[index];
                return Stack(
                  children: [
                    GestureDetector(
                      onLongPress: () => _confirmDeleteImage(item),
                      child: Image.file(item, fit: BoxFit.cover),
                    ),
                    Positioned(
                      top: 5,
                      right: 5,
                      child: IconButton(
                        icon: Icon(Icons.delete, color: Colors.red),
                        onPressed: () => _confirmDeleteImage(item),
                      ),
                    ),
                    Positioned(
                      bottom: 5,
                      right: 5,
                      child: IconButton(
                        icon: Icon(Icons.label, color: Colors.blue),
                        onPressed: () => _addTagToImage(item),
                      ),
                    ),
                  ],
                );
              },
            ),
          ),
          Padding(
            padding: EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                ElevatedButton(
                  onPressed: () => getImage(ImageSource.gallery),
                  child: Text('画像選択'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.blue,
                    padding: EdgeInsets.symmetric(horizontal: 40, vertical: 15),
                    textStyle: TextStyle(fontSize: 18),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(30),
                    ),
                  ),
                ),
                SizedBox(height: 10),
                ElevatedButton(
                  onPressed: () => getImage(ImageSource.camera),
                  child: Text('撮る'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.orange,
                    padding: EdgeInsets.symmetric(horizontal: 40, vertical: 15),
                    textStyle: TextStyle(fontSize: 18),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(30),
                    ),
                  ),
                ),
                SizedBox(height: 10),
                ElevatedButton(
                  onPressed: () => _pickImageFromWeb(context),
                  child: Text('Web画像選択'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.purple,
                    padding: EdgeInsets.symmetric(horizontal: 40, vertical: 15),
                    textStyle: GoogleFonts.montserrat(fontSize: 18),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(30),
                    ),
                  ),
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
          Navigator.of(context).pop();
        }
      }
    } catch (e) {
      print('Error saving image: $e');
    }
  }
}

void main() {
  runApp(MaterialApp(
    home: AddItemPage(),
  ));
}
