import 'package:flutter/material.dart';

class CreateAdPage extends StatefulWidget {
  const CreateAdPage({super.key});

  @override
  State<CreateAdPage> createState() => _CreateAdPageState();
}

class _CreateAdPageState extends State<CreateAdPage> {
  final _formKey = GlobalKey<FormState>();

  final _titleController = TextEditingController();
  final _priceController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _phoneController = TextEditingController();

  final String _sellerName = "Marcos";

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF4F7FA),
      body: Stack(
        children: [

          /// 🔵 HEADER GRADIENT
          Container(
            height: 220,
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  Color(0xFF00B4D8),
                  Color(0xFF0A1E2D)                ],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
            ),
          ),

          SafeArea(
            child: Column(
              children: [

                /// 🔙 HEADER CONTENT
                Padding(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 20, vertical: 16),
                  child: Row(
                    children: [
                      GestureDetector(
                        onTap: () => Navigator.pop(context),
                        child: const Icon(
                          Icons.arrow_back,
                          color: Colors.white,
                        ),
                      ),
                      const SizedBox(width: 16),
                      const Text(
                        "Nouvelle annonce",
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 22,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 20),

                /// 💎 CARD FLOTTANTE
                Expanded(
                  child: Container(
                    margin: const EdgeInsets.symmetric(horizontal: 20),
                    padding: const EdgeInsets.all(24),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(30),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.08),
                          blurRadius: 30,
                          offset: const Offset(0, 15),
                        ),
                      ],
                    ),
                    child: SingleChildScrollView(
                      child: Form(
                        key: _formKey,
                        child: Column(
                          crossAxisAlignment:
                          CrossAxisAlignment.start,
                          children: [

                            _modernField(
                              controller: _titleController,
                              label: "Titre",
                            ),

                            const SizedBox(height: 20),

                            _modernField(
                              controller: _priceController,
                              label: "Prix (€)",
                              keyboardType:
                              TextInputType.number,
                            ),

                            const SizedBox(height: 20),

                            _modernField(
                              controller:
                              _descriptionController,
                              label: "Description",
                              maxLines: 4,
                            ),

                            const SizedBox(height: 30),

                            const Text(
                              "Contact",
                              style: TextStyle(
                                fontWeight:
                                FontWeight.w600,
                                fontSize: 16,
                              ),
                            ),

                            const SizedBox(height: 16),

                            _readOnlyModern(
                              label: "Annonceur",
                              value: _sellerName,
                            ),

                            const SizedBox(height: 20),

                            _modernField(
                              controller:
                              _phoneController,
                              label:
                              "Numéro de téléphone",
                              keyboardType:
                              TextInputType.phone,
                            ),

                            const SizedBox(height: 30),

                            const Text(
                              "Images",
                              style: TextStyle(
                                fontWeight:
                                FontWeight.w600,
                                fontSize: 16,
                              ),
                            ),

                            const SizedBox(height: 16),

                            _imageBox(),

                            const SizedBox(height: 40),

                            /// 🚀 BOUTON PREMIUM
                            SizedBox(
                              width: double.infinity,
                              child: Container(
                                decoration: BoxDecoration(
                                  borderRadius:
                                  BorderRadius.circular(
                                      20),
                                  gradient:
                                  const LinearGradient(
                                    colors: [
                                      Color(0xFF00B4D8),
                                      Color(0xFF0A1E2D)                                    ],
                                  ),
                                ),
                                child: ElevatedButton(
                                  style:
                                  ElevatedButton
                                      .styleFrom(
                                    backgroundColor:
                                    Colors
                                        .transparent,
                                    shadowColor:
                                    Colors
                                        .transparent,
                                    padding:
                                    const EdgeInsets
                                        .symmetric(
                                      vertical: 18,
                                    ),
                                  ),
                                  onPressed: () {},
                                  child: const Text(
                                    "Publier l'annonce",
                                    style: TextStyle(
                                      color: Colors.white,
                                      fontSize: 16,
                                      fontWeight:
                                      FontWeight.w600,
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _modernField({
    required TextEditingController controller,
    required String label,
    int maxLines = 1,
    TextInputType keyboardType =
        TextInputType.text,
  }) {
    return TextFormField(
      controller: controller,
      maxLines: maxLines,
      keyboardType: keyboardType,
      decoration: InputDecoration(
        labelText: label,
        floatingLabelBehavior:
        FloatingLabelBehavior.auto,
        filled: true,
        fillColor: const Color(0xFFF2F4F7),
        contentPadding:
        const EdgeInsets.symmetric(
            horizontal: 16, vertical: 18),
        border: OutlineInputBorder(
          borderRadius:
          BorderRadius.circular(16),
          borderSide: BorderSide.none,
        ),
      ),
    );
  }

  Widget _readOnlyModern({
    required String label,
    required String value,
  }) {
    return TextFormField(
      initialValue: value,
      readOnly: true,
      decoration: InputDecoration(
        labelText: label,
        filled: true,
        fillColor: const Color(0xFFE9EDF2),
        border: OutlineInputBorder(
          borderRadius:
          BorderRadius.circular(16),
          borderSide: BorderSide.none,
        ),
      ),
    );
  }

  Widget _imageBox() {
    return Container(
      height: 120,
      width: double.infinity,
      decoration: BoxDecoration(
        borderRadius:
        BorderRadius.circular(20),
        border: Border.all(
            color: Colors.grey.shade300),
      ),
      child: const Center(
        child: Column(
          mainAxisAlignment:
          MainAxisAlignment.center,
          children: [
            Icon(Icons.add_photo_alternate,
                size: 30,
                color: Colors.grey),
            SizedBox(height: 8),
            Text(
              "Ajouter des images",
              style:
              TextStyle(color: Colors.grey),
            ),
          ],
        ),
      ),
    );
  }
}