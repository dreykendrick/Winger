import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../shared/components/winger_button.dart';
import '../../../../shared/components/winger_card.dart';
import '../../../../shared/components/winger_input.dart';
import '../../../../shared/design_system/tokens/design_tokens.dart';
import '../../domain/entities/account_type.dart';
import '../providers/auth_providers.dart';

class InfoCollectionScreen extends ConsumerStatefulWidget {
  final AccountType accountType;

  const InfoCollectionScreen({
    super.key,
    this.accountType = AccountType.vendor,
  });

  @override
  ConsumerState<InfoCollectionScreen> createState() =>
      _InfoCollectionScreenState();
}

class _InfoCollectionScreenState extends ConsumerState<InfoCollectionScreen> {
  final _formKey = GlobalKey<FormState>();
  final _businessNameController = TextEditingController();
  final _cityController = TextEditingController();
  final _addressController = TextEditingController();
  final _contactPhoneController = TextEditingController();

  String _selectedRegion = 'Dar es Salaam';
  bool _isSubmitting = false;

  final List<String> _tanzanianRegions = [
    'Dar es Salaam',
    'Arusha',
    'Mwanza',
    'Dodoma',
    'Kilimanjaro',
    'Zanzibar',
    'Mbeya',
    'Tanga',
    'Morogoro',
    'Iringa',
    'Other Region'
  ];

  @override
  void dispose() {
    _businessNameController.dispose();
    _cityController.dispose();
    _addressController.dispose();
    _contactPhoneController.dispose();
    super.dispose();
  }

  void _onSubmitInfo() async {
    if (!(_formKey.currentState?.validate() ?? false)) return;

    setState(() => _isSubmitting = true);

    try {
      // Simulate saving location & profile context
      await Future.delayed(const Duration(milliseconds: 600));

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Onboarding setup complete! Welcome to Winger.'),
          backgroundColor: WingerTokens.primaryEmerald,
        ),
      );

      final identityContext = ref.read(identityContextProvider);
      final isVendor =
          identityContext.accountTypes.contains(AccountType.vendor) ||
              widget.accountType == AccountType.vendor;
      final isAffiliate =
          identityContext.accountTypes.contains(AccountType.affiliate) ||
              widget.accountType == AccountType.affiliate;

      if (isVendor) {
        context.go('/vendor');
      } else if (isAffiliate) {
        context.go('/affiliate');
      } else {
        context.go('/home');
      }
    } catch (e) {
      if (!mounted) return;
      setState(() => _isSubmitting = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error saving setup info: $e'),
          backgroundColor: WingerTokens.dangerCoral,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final isVendor = widget.accountType == AccountType.vendor;

    return Scaffold(
      backgroundColor: const Color(0xFF0B0D17),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: Text(
          isVendor ? 'Vendor Business & Location' : 'Promoter Profile Setup',
          style: const TextStyle(color: Colors.white, fontSize: 16),
        ),
        automaticallyImplyLeading: false,
      ),
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(WingerTokens.space24),
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 440),
              child: WingerCard(
                child: Form(
                  key: _formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Icon(
                        isVendor
                            ? Icons.add_location_alt_outlined
                            : Icons.badge_outlined,
                        size: 44,
                        color: WingerTokens.primaryEmerald,
                      ),
                      const SizedBox(height: 12),
                      Text(
                        isVendor
                            ? 'Store Location & Business Info'
                            : 'Promoter Profile & Location',
                        style: const TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 6),
                      Text(
                        'Provide your location details to complete onboarding.',
                        style: TextStyle(
                            fontSize: 13, color: Colors.grey.shade400),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 24),

                      // Business / Store Name
                      WingerInput(
                        label: isVendor
                            ? 'Store / Business Name'
                            : 'Promoter Handle / Name',
                        hint: isVendor
                            ? 'Kariakoo Electronics'
                            : 'Swahili Tech Reviews',
                        controller: _businessNameController,
                        prefixIcon:
                            isVendor ? Icons.storefront : Icons.campaign,
                        validator: (val) {
                          if (val == null || val.trim().isEmpty) {
                            return 'Name is required';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 14),

                      // Region Selection Dropdown
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'Region',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 13,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 6),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 14),
                            decoration: BoxDecoration(
                              color: const Color(0xFF1B2033),
                              borderRadius: BorderRadius.circular(10),
                              border: Border.all(
                                color: Colors.white.withValues(alpha: 0.1),
                              ),
                            ),
                            child: DropdownButtonHideUnderline(
                              child: DropdownButton<String>(
                                value: _selectedRegion,
                                isExpanded: true,
                                dropdownColor: const Color(0xFF1B2033),
                                style: const TextStyle(
                                    color: Colors.white, fontSize: 14),
                                icon: const Icon(Icons.arrow_drop_down,
                                    color: Colors.white70),
                                items: _tanzanianRegions.map((region) {
                                  return DropdownMenuItem<String>(
                                    value: region,
                                    child: Text(region),
                                  );
                                }).toList(),
                                onChanged: (val) {
                                  if (val != null) {
                                    setState(() => _selectedRegion = val);
                                  }
                                },
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 14),

                      // City / District Input
                      WingerInput(
                        label: 'City / District',
                        hint: 'e.g. Kinondoni, Ubungo, Nyamagana',
                        controller: _cityController,
                        prefixIcon: Icons.location_city_outlined,
                        validator: (val) {
                          if (val == null || val.trim().isEmpty) {
                            return 'District / City required';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 14),

                      // Physical Address Input
                      WingerInput(
                        label: 'Street / Physical Address',
                        hint: 'e.g. Uhuru Street, Plot #12',
                        controller: _addressController,
                        prefixIcon: Icons.map_outlined,
                        validator: (val) {
                          if (val == null || val.trim().isEmpty) {
                            return 'Address required';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 24),

                      WingerButton(
                        label: 'Complete Onboarding Setup',
                        isLoading: _isSubmitting,
                        onPressed: _onSubmitInfo,
                      ),
                      const SizedBox(height: 10),
                      TextButton(
                        onPressed: () {
                          if (isVendor) {
                            context.go('/vendor');
                          } else {
                            context.go('/home');
                          }
                        },
                        child: Text(
                          'Skip for now →',
                          style: TextStyle(
                            color: Colors.grey.shade400,
                            fontSize: 12,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
