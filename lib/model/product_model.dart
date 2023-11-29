class Product {
  String uid;
  String id;
  String name;
  double price;
  DateTime expiryDate; // Change the data type to DateTime

  Product({
    required this.uid,
    required this.id,
    required this.name,
    required this.price,
    required this.expiryDate,
  });

  // Named constructor to create a Product instance from a map
  Product.fromMap(Map<String, dynamic> map)
      : uid = map['uid'],
        id = map['id'],
        name = map['name'],
        price = map['price'].toDouble(),
        expiryDate = DateTime.parse(map['expiryDate']); // Parse the string to DateTime

  // Method to convert a Product instance to a map
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'price': price,
      'expiryDate': expiryDate.toIso8601String(), // Convert DateTime to a string
    };
  }
}