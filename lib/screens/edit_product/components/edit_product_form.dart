import 'dart:io';

import 'package:e_commerce_app_flutter/components/default_button.dart';
import 'package:e_commerce_app_flutter/models/Product.dart';
import 'package:e_commerce_app_flutter/services/database/product_database_helper.dart';
import 'package:e_commerce_app_flutter/services/firestore_files_access/firestore_files_access_service.dart';
import 'package:e_commerce_app_flutter/services/local_files_access/local_files_access_service.dart';
import 'package:flutter/material.dart';
import 'package:future_progress_dialog/future_progress_dialog.dart';

import '../../../constants.dart';
import '../../../size_config.dart';

class EditProductForm extends StatefulWidget {
  final Product product;
  EditProductForm({
    Key key,
    this.product,
  }) : super(key: key);

  @override
  _EditProductFormState createState() => _EditProductFormState();
}

class _EditProductFormState extends State<EditProductForm> {
  final _basicDetailsFormKey = GlobalKey<FormState>();
  final _describeProductFormKey = GlobalKey<FormState>();
  final TextEditingController titleFieldController = TextEditingController();
  final TextEditingController variantFieldController = TextEditingController();
  final TextEditingController discountPriceFieldController =
      TextEditingController();
  final TextEditingController originalPriceFieldController =
      TextEditingController();
  final TextEditingController ratingFieldController = TextEditingController();
  final TextEditingController highlightsFieldController =
      TextEditingController();
  final TextEditingController desciptionFieldController =
      TextEditingController();
  final TextEditingController sellerFieldController = TextEditingController();
  bool basicDetailsFormValidated = false;
  bool describeProductFormValidated = false;
  List<String> selectedImages = List<String>();

  @override
  void dispose() {
    titleFieldController.dispose();
    variantFieldController.dispose();
    discountPriceFieldController.dispose();
    originalPriceFieldController.dispose();
    ratingFieldController.dispose();
    highlightsFieldController.dispose();
    desciptionFieldController.dispose();
    sellerFieldController.dispose();

    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        buildBasicDetailsTile(context),
        SizedBox(height: getProportionateScreenHeight(10)),
        buildDescribeProductTile(context),
        SizedBox(height: getProportionateScreenHeight(10)),
        buildUploadImagesTile(context),
        SizedBox(height: getProportionateScreenHeight(30)),
        DefaultButton(
          text: "Next",
          press: nextButtonCallback,
        ),
        SizedBox(height: getProportionateScreenHeight(10)),
      ],
    );
  }

  Widget buildBasicDetailsTile(BuildContext context) {
    return Form(
      key: _basicDetailsFormKey,
      child: ExpansionTile(
        title: Text(
          "Basic Details",
          style: Theme.of(context).textTheme.headline6,
        ),
        leading: Icon(
          Icons.shop,
        ),
        childrenPadding:
            EdgeInsets.symmetric(vertical: getProportionateScreenHeight(20)),
        children: [
          buildTitleField(),
          SizedBox(height: getProportionateScreenHeight(20)),
          buildVariantField(),
          SizedBox(height: getProportionateScreenHeight(20)),
          buildOriginalPriceField(),
          SizedBox(height: getProportionateScreenHeight(20)),
          buildDiscountPriceField(),
          SizedBox(height: getProportionateScreenHeight(20)),
          buildSellerField(),
          SizedBox(height: getProportionateScreenHeight(20)),
          DefaultButton(
            text: "Save",
            press: () {
              if (_basicDetailsFormKey.currentState.validate()) {
                _basicDetailsFormKey.currentState.save();
                widget.product.title = titleFieldController.text;
                widget.product.variant = variantFieldController.text;
                widget.product.originalPrice =
                    double.parse(originalPriceFieldController.text);
                widget.product.discountPrice =
                    double.parse(discountPriceFieldController.text);
                widget.product.seller = sellerFieldController.text;
                basicDetailsFormValidated = true;
              } else {
                basicDetailsFormValidated = false;
              }
            },
          ),
        ],
      ),
    );
  }

  Widget buildDescribeProductTile(BuildContext context) {
    return Form(
      key: _describeProductFormKey,
      child: ExpansionTile(
        title: Text(
          "Describe Product",
          style: Theme.of(context).textTheme.headline6,
        ),
        leading: Icon(
          Icons.description,
        ),
        childrenPadding:
            EdgeInsets.symmetric(vertical: getProportionateScreenHeight(20)),
        children: [
          buildHighlightsField(),
          SizedBox(height: getProportionateScreenHeight(20)),
          buildDescriptionField(),
          SizedBox(height: getProportionateScreenHeight(20)),
          DefaultButton(
            text: "Save",
            press: () {
              if (_describeProductFormKey.currentState.validate()) {
                _describeProductFormKey.currentState.save();
                widget.product.highlights = highlightsFieldController.text;
                widget.product.description = desciptionFieldController.text;
                describeProductFormValidated = true;
              } else {
                describeProductFormValidated = false;
              }
            },
          ),
        ],
      ),
    );
  }

  Widget buildUploadImagesTile(BuildContext context) {
    return ExpansionTile(
      title: Text(
        "Upload Images",
        style: Theme.of(context).textTheme.headline6,
      ),
      leading: Icon(Icons.image),
      childrenPadding:
          EdgeInsets.symmetric(vertical: getProportionateScreenHeight(20)),
      children: [
        Padding(
          padding: const EdgeInsets.all(16.0),
          child: IconButton(
            icon: Icon(
              Icons.add_a_photo,
            ),
            color: kTextColor,
            onPressed: addImageButtonCallback,
          ),
        ),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            ...List.generate(
              selectedImages.length,
              (index) => SizedBox(
                width: 80,
                height: 80,
                child: Padding(
                  padding: const EdgeInsets.all(5.0),
                  child: GestureDetector(
                    onTap: () {
                      addImageButtonCallback(index: index);
                    },
                    child: Image.memory(
                      File(selectedImages[index]).readAsBytesSync(),
                      fit: BoxFit.cover,
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget buildTitleField() {
    return TextFormField(
      controller: titleFieldController,
      keyboardType: TextInputType.name,
      decoration: InputDecoration(
        hintText: "e.g., Samsung Galaxy F41 Mobile",
        labelText: "Product Title",
        floatingLabelBehavior: FloatingLabelBehavior.always,
      ),
      validator: (_) {
        if (titleFieldController.text.isEmpty) {
          return FIELD_REQUIRED_MSG;
        }
        return null;
      },
      autovalidateMode: AutovalidateMode.onUserInteraction,
    );
  }

  Widget buildVariantField() {
    return TextFormField(
      controller: variantFieldController,
      keyboardType: TextInputType.name,
      decoration: InputDecoration(
        hintText: "e.g., Fusion Green",
        labelText: "Variant",
        floatingLabelBehavior: FloatingLabelBehavior.always,
      ),
      validator: (_) {
        if (variantFieldController.text.isEmpty) {
          return FIELD_REQUIRED_MSG;
        }
        return null;
      },
      autovalidateMode: AutovalidateMode.onUserInteraction,
    );
  }

  Widget buildHighlightsField() {
    return TextFormField(
      controller: highlightsFieldController,
      keyboardType: TextInputType.multiline,
      decoration: InputDecoration(
        hintText:
            "e.g., RAM: 4GB | Front Camera: 30MP | Rear Camera: Quad Camera Setup",
        labelText: "Highlights",
        floatingLabelBehavior: FloatingLabelBehavior.always,
      ),
      validator: (_) {
        if (highlightsFieldController.text.isEmpty) {
          return FIELD_REQUIRED_MSG;
        }
        return null;
      },
      autovalidateMode: AutovalidateMode.onUserInteraction,
      maxLines: null,
    );
  }

  Widget buildDescriptionField() {
    return TextFormField(
      controller: desciptionFieldController,
      keyboardType: TextInputType.multiline,
      decoration: InputDecoration(
        hintText:
            "e.g., This a flagship phone under made in India, by Samsung. With this device, Samsung introduces its new F Series.",
        labelText: "Description",
        floatingLabelBehavior: FloatingLabelBehavior.always,
      ),
      validator: (_) {
        if (desciptionFieldController.text.isEmpty) {
          return FIELD_REQUIRED_MSG;
        }
        return null;
      },
      autovalidateMode: AutovalidateMode.onUserInteraction,
      maxLines: null,
    );
  }

  Widget buildSellerField() {
    return TextFormField(
      controller: sellerFieldController,
      keyboardType: TextInputType.name,
      decoration: InputDecoration(
        hintText: "e.g., HighTech Traders",
        labelText: "Seller",
        floatingLabelBehavior: FloatingLabelBehavior.always,
      ),
      validator: (_) {
        if (sellerFieldController.text.isEmpty) {
          return FIELD_REQUIRED_MSG;
        }
        return null;
      },
      autovalidateMode: AutovalidateMode.onUserInteraction,
    );
  }

  Widget buildOriginalPriceField() {
    return TextFormField(
      controller: originalPriceFieldController,
      keyboardType: TextInputType.number,
      decoration: InputDecoration(
        hintText: "e.g., 5999.0",
        labelText: "Original Price (in INR)",
        floatingLabelBehavior: FloatingLabelBehavior.always,
      ),
      validator: (_) {
        if (originalPriceFieldController.text.isEmpty) {
          return FIELD_REQUIRED_MSG;
        }
        return null;
      },
      autovalidateMode: AutovalidateMode.onUserInteraction,
    );
  }

  Widget buildDiscountPriceField() {
    return TextFormField(
      controller: discountPriceFieldController,
      keyboardType: TextInputType.number,
      decoration: InputDecoration(
        hintText: "e.g., 2499.0",
        labelText: "Discount Price (in INR)",
        floatingLabelBehavior: FloatingLabelBehavior.always,
      ),
      validator: (_) {
        if (discountPriceFieldController.text.isEmpty) {
          return FIELD_REQUIRED_MSG;
        }
        return null;
      },
      autovalidateMode: AutovalidateMode.onUserInteraction,
    );
  }

  Future<void> nextButtonCallback() async {
    if (basicDetailsFormValidated == true &&
        describeProductFormValidated == true) {
      final productUploadFuture =
          ProductDatabaseHelper().addUsersProduct(widget.product);
      String productId = await showDialog(
        context: context,
        builder: (context) {
          return FutureProgressDialog(
            productUploadFuture,
            message: Text("Uploading Product"),
          );
        },
      );
      List<String> downloadUrls = await uploadProductImages(productId);
      final updateProductFuture =
          ProductDatabaseHelper().updateProductsImages(productId, downloadUrls);
      await showDialog(
        context: context,
        builder: (context) {
          return FutureProgressDialog(
            updateProductFuture,
            message: Text("Saving Product"),
          );
        },
      );
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text("Product Saved"),
        ),
      );
      Navigator.pop(context);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text("Please fill complete details"),
        ),
      );
    }
  }

  Future<List<String>> uploadProductImages(String productId) async {
    String path = "products/images/$productId";
    List<String> urls = List<String>();
    for (int i = 0; i < selectedImages.length; i++) {
      print("Image being uploaded: " + selectedImages[i]);
      final imgUploadFuture = FirestoreFilesAccess()
          .uploadFileToPath(File(selectedImages[i]), path + "_$i");
      String downloadUrl = await showDialog(
        context: context,
        builder: (context) {
          return FutureProgressDialog(
            imgUploadFuture,
            message: Text("Uploading Images ${i + 1}/${selectedImages.length}"),
          );
        },
      );
      urls.add(downloadUrl);
    }
    return urls;
  }

  Future<void> addImageButtonCallback({int index}) async {
    if (index == null && selectedImages.length >= 3) {
      ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Max 3 images can be uploaded")));
      return;
    }
    final path = await choseImageFromLocalFiles(context);
    if (path == READ_STORAGE_PERMISSION_DENIED) {
      ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Storage permissions required")));
      return;
    } else if (path == INVALID_FILE_CHOSEN) {
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text("Invalid Image")));
      return;
    } else if (path == FILE_SIZE_OUT_OF_BOUNDS) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text("File size should be within 5KB to 1MB only")));
      return;
    }

    setState(() {
      if (index == null) {
        selectedImages.add(path);
      } else {
        selectedImages[index] = path;
      }
    });
  }
}