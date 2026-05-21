import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;

void main() => runApp(MaterialApp(
      home: MyProductsPage(),
      debugShowCheckedModeBanner: false,
    ));

class MyProductsPage extends StatefulWidget {
  @override
  _MyProductsPageState createState() => _MyProductsPageState();
}

class _MyProductsPageState extends State<MyProductsPage> {
  // دالة جلب البيانات - تم تعديل الرابط ليعمل على المتصفح (Web)
  Future<List> fetchProducts() async {
    // استخدمنا localhost لأنك تشغل التطبيق على المتصفح
    final response = await http.get(Uri.parse('http://localhost/homework_api/get_products.php'));

    if (response.statusCode == 200) {
      return json.decode(response.body);
    } else {
      throw Exception('Failed to load products');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("متجري - عرض من قاعدة البيانات"),
        backgroundColor: Colors.blueAccent,
      ),
      body: FutureBuilder<List>(
        future: fetchProducts(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text("خطأ في الاتصال: ${snapshot.error}"));
          } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return Center(child: Text("لا توجد بيانات حالياً"));
          } else {
            return ListView.builder(
              itemCount: snapshot.data!.length,
              itemBuilder: (context, index) {
                var item = snapshot.data![index];
                return ProductBox(
                  name: item['name'] ?? "بدون اسم",
                  brand: item['brand'] ?? "بدون ماركة", // الماركة التي أضفتها في phpMyAdmin
                  description: item['description'] ?? "",
                  price: item['price'].toString(),
                  image: item['image_url'] ?? "",
                );
              },
            );
          }
        },
      ),
    );
  }
}

// تصميم الواجهة لكل منتج (Layout)
class ProductBox extends StatelessWidget {
  final String name, brand, description, price, image;
  ProductBox({
    required this.name,
    required this.brand,
    required this.description,
    required this.price,
    required this.image,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(10),
      height: 180,
      child: Card(
        elevation: 5,
        child: Row(
          children: <Widget>[
            // عرض الصورة من الرابط الموجود في قاعدة البيانات
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Image.network(
                image,
                width: 100,
                fit: BoxFit.contain,
                errorBuilder: (context, error, stackTrace) => Icon(Icons.broken_image, size: 80),
              ),
            ),
            Expanded(
              child: Container(
                padding: EdgeInsets.all(10),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Text(this.name, style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                    Text("الماركة: " + this.brand, style: TextStyle(color: Colors.blue, fontWeight: FontWeight.bold)),
                    Text(this.description, maxLines: 2, overflow: TextOverflow.ellipsis, style: TextStyle(fontSize: 12)),
                    Text("السعر: " + this.price + " \$", style: TextStyle(color: Colors.green, fontWeight: FontWeight.bold)),
                  ],
                ),
              ),
            )
          ],
        ),
      ),  
    );
  }
}  