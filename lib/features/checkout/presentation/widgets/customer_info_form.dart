import 'package:flutter/material.dart';
import 'package:winger/features/checkout/domain/entities/customer_info.dart';
import 'package:winger/shared/components/winger_input.dart';

class CustomerInfoForm extends StatefulWidget {
  final CustomerInfo? initialInfo;
  final ValueChanged<CustomerInfo> onChanged;

  const CustomerInfoForm({
    super.key,
    this.initialInfo,
    required this.onChanged,
  });

  @override
  State<CustomerInfoForm> createState() => _CustomerInfoFormState();
}

class _CustomerInfoFormState extends State<CustomerInfoForm> {
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _phoneController = TextEditingController();

  @override
  void initState() {
    super.initState();
    if (widget.initialInfo != null) {
      _nameController.text = widget.initialInfo!.fullName;
      _emailController.text = widget.initialInfo!.email;
      _phoneController.text = widget.initialInfo!.phoneNumber;
    }
  }

  void _notify() {
    widget.onChanged(
      CustomerInfo(
        fullName: _nameController.text,
        email: _emailController.text,
        phoneNumber: _phoneController.text,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        WingerInput(
          label: 'Full Name',
          hint: 'Jane Doe',
          controller: _nameController,
          onChanged: (_) => _notify(),
        ),
        const SizedBox(height: 12),
        WingerInput(
          label: 'Email Address',
          hint: 'jane@example.com',
          controller: _emailController,
          keyboardType: TextInputType.emailAddress,
          onChanged: (_) => _notify(),
        ),
        const SizedBox(height: 12),
        WingerInput(
          label: 'Phone Number',
          hint: '+255 700 000 000',
          controller: _phoneController,
          keyboardType: TextInputType.phone,
          onChanged: (_) => _notify(),
        ),
      ],
    );
  }
}
