import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter/services.dart';
import 'package:lottie/lottie.dart';
import 'package:heartbit/config/theme/app_colors.dart';
import 'package:heartbit/features/pairing/presentation/providers/pairing_provider.dart';
import 'package:heartbit/features/auth/presentation/providers/auth_provider.dart';

class PairingScreen extends ConsumerStatefulWidget {
  const PairingScreen({super.key});

  @override
  ConsumerState<PairingScreen> createState() => _PairingScreenState();
}

class _PairingScreenState extends ConsumerState<PairingScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final TextEditingController _codeController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    
    // Auto login anonymously when screen opens
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _ensureLoggedIn();
    });
  }

  Future<void> _ensureLoggedIn() async {
    final userId = ref.read(authUserIdProvider);
    if (userId == null) {
      // Not logged in, do anonymous login
      await ref.read(authControllerProvider.notifier).signInAnonymously();
    }
  }

  @override
  void dispose() {
    _tabController.dispose();
    _codeController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // Listen for errors
    ref.listen(pairingControllerProvider, (previous, next) {
      if (next is AsyncError) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(next.error.toString()),
            backgroundColor: AppColors.error,
          ),
        );
      }
    });

    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: AppColors.primaryGradient,
        ),
        child: SafeArea(
          child: Column(
            children: [
              const SizedBox(height: 40),
              // Header
              const Text(
                'HeartBit',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 32,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 1.2,
                ),
              ),
              const SizedBox(height: 10),
              const Text(
                'Connect with your partner',
                style: TextStyle(
                  color: Colors.white70,
                  fontSize: 16,
                ),
              ),
              const SizedBox(height: 40),

              // Main Card
              Expanded(
                child: Container(
                  width: double.infinity,
                  decoration: const BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.only(
                      topLeft: Radius.circular(30),
                      topRight: Radius.circular(30),
                    ),
                  ),
                  child: Column(
                    children: [
                      const SizedBox(height: 20),
                      // Tabs
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 20),
                        child: Container(
                          decoration: BoxDecoration(
                            color: AppColors.surface,
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: TabBar(
                            controller: _tabController,
                            indicator: BoxDecoration(
                              color: AppColors.primary,
                              borderRadius: BorderRadius.circular(12),
                            ),
                            labelColor: Colors.white,
                            unselectedLabelColor: AppColors.textSecondary,
                            dividerColor: Colors.transparent,
                            tabs: const [
                              Tab(text: 'I have a code'),
                              Tab(text: 'Share my code'),
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(height: 30),

                      // Tab View
                      Expanded(
                        child: TabBarView(
                          controller: _tabController,
                          children: [
                            _buildJoinTab(),
                            _buildShareTab(),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildJoinTab() {
    return Padding(
      padding: const EdgeInsets.all(24.0),
      child: Column(
        children: [
          const Text(
            'Enter Partner\'s Code',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: 12),
          const Text(
            'Ask your partner for their 6-digit code\nand enter it below.',
            textAlign: TextAlign.center,
            style: TextStyle(color: AppColors.textSecondary),
          ),
          const SizedBox(height: 40),
          
          // Code Input Field
          TextField(
            controller: _codeController,
            textAlign: TextAlign.center,
            style: const TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              letterSpacing: 8,
              color: AppColors.primary,
            ),
            maxLength: 6,
            textCapitalization: TextCapitalization.characters,
            decoration: InputDecoration(
              counterText: '',
              hintText: 'ABCD12',
              hintStyle: TextStyle(
                color: Colors.grey.shade300,
                letterSpacing: 8,
              ),
              fillColor: AppColors.surface,
              filled: true,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(16),
                borderSide: BorderSide.none,
              ),
            ),
          ),
          
          const Spacer(),
          
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: () {
                final code = _codeController.text.trim();
                if (code.length == 6) {
                  ref.read(pairingControllerProvider.notifier).joinWithCode(code);
                }
              },
              child: const Text('Connect'),
            ),
          ),
          const SizedBox(height: 20),
        ],
      ),
    );
  }

  Widget _buildShareTab() {
    return Padding(
      padding: const EdgeInsets.all(24.0),
      child: Column(
        children: [
          const Text(
            'Your Pairing Code',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: 12),
          const Text(
            'Share this code with your partner\nto connect accounts.',
            textAlign: TextAlign.center,
            style: TextStyle(color: AppColors.textSecondary),
          ),
          const SizedBox(height: 20),
          // Radar Animation
          SizedBox(
            height: 100,
            child: Lottie.network(
              'https://lottie.host/61c84136-1e42-4217-915f-5545582c0798/w4aY0q6w7D.json',
              errorBuilder: (context, error, stackTrace) => const Icon(Icons.wifi_tethering, size: 48, color: AppColors.primary),
            ),
          ),
          const SizedBox(height: 20),
          

          // Generated Code Display
          Consumer(
            builder: (context, ref, child) {
              final pairingState = ref.watch(pairingControllerProvider);

              return Column(
                children: [
                   Container(
                    padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 24),
                    decoration: BoxDecoration(
                      color: AppColors.surface,
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(color: AppColors.primary.withOpacity(0.2)),
                    ),
                    child: pairingState.when(
                      data: (code) {
                        return Text(
                          code ?? '------',
                          style: const TextStyle(
                            fontSize: 32,
                            fontWeight: FontWeight.bold,
                            letterSpacing: 4,
                            color: AppColors.primary,
                          ),
                        );
                      },
                      loading: () => const CircularProgressIndicator(),
                      error: (e, _) => const Icon(Icons.error, color: AppColors.error),
                    ),
                  ),
                  const SizedBox(height: 24),
                  if (pairingState.value == null)
                    ElevatedButton.icon(
                      onPressed: () {
                        ref.read(pairingControllerProvider.notifier).generateCode();
                      },
                      icon: const Icon(Icons.refresh),
                      label: const Text('Generate New Code'),
                    ),
                ],
              );
            },
          ),
          
          const SizedBox(height: 20),
          TextButton.icon(
            onPressed: () {
              final code = ref.read(pairingControllerProvider).value;
              if (code != null) {
                Clipboard.setData(ClipboardData(text: code));
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Copied to clipboard!')),
                );
              }
            },
            icon: const Icon(Icons.copy, color: AppColors.secondary),
            label: const Text(
              'Copy Code',
              style: TextStyle(color: AppColors.secondary),
            ),
          ),
          
          const Spacer(),
          const Text(
            'Code expires in 24 hours',
            style: TextStyle(
              color: AppColors.textSecondary,
              fontSize: 12,
            ),
          ),
          const SizedBox(height: 20),
        ],
      ),
    );
  }
}
