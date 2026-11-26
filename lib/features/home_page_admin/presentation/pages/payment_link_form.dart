import 'package:flutter/material.dart';
import 'admin_text_resources_page.dart';

class PaymentLinkForm extends StatelessWidget {
  const PaymentLinkForm({super.key});
  @override
  Widget build(BuildContext context) =>
      const AdminTextResourcesPage(payments: true);
}
