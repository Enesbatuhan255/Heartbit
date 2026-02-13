import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:heartbit/config/theme/app_colors.dart';
import 'package:heartbit/features/auth/presentation/providers/auth_provider.dart';
import 'package:heartbit/features/pairing/presentation/providers/pairing_provider.dart';

import '../../domain/entities/activity_category.dart';
import '../providers/swipe_provider.dart';
import '../providers/draft_session_provider.dart';
import '../../domain/entities/draft_session.dart';

class SwipeSetupScreen extends ConsumerStatefulWidget {
  const SwipeSetupScreen({super.key});

  @override
  ConsumerState<SwipeSetupScreen> createState() => _SwipeSetupScreenState();
}

class _SwipeSetupScreenState extends ConsumerState<SwipeSetupScreen> {
  final TextEditingController _customController = TextEditingController();
  bool _isGenerating = false;

  @override
  void initState() {
    super.initState();
    // Enter lobby and notify partner
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(draftSessionControllerProvider.notifier).enterLobby();
    });
  }

  @override
  void dispose() {
    // Leave lobby when exiting
    ref.read(draftSessionControllerProvider.notifier).leaveLobby();
    _customController.dispose();
    super.dispose();
  }

  // Hidden database seeder (Kept for debug)
  Future<void> _seedDatabase() async {
    final scaffold = ScaffoldMessenger.of(context);
    scaffold.showSnackBar(const SnackBar(content: Text('🌱 Seeding database...')));
    
    final firestore = FirebaseFirestore.instance;
    final batch = firestore.batch();
    final collection = firestore.collection('global_activities');
    
    final activities = [
      // Chill Home
      {
        'id': 'ga_chill_001', 'title': 'Movie Marathon Night', 'description': 'Pick a trilogy or series and binge watch together', 
        'imageUrl': 'https://images.unsplash.com/photo-1489599849927-2ee91cede3ba?w=800', 'category': 'chill_home', 
        'intensityLevel': 1, 'estimatedTime': '3-4 hours', 'budgetLevel': 1, 'isActive': true
      },
      // ... (Keeping it concise, real verification relies on debug card logic now)
    ];
    // Simple 1-item seed just to verify writes if needed
    if (activities.isNotEmpty) {
       for (final activity in activities) {
         batch.set(collection.doc(activity['id'] as String), activity);
       }
       try {
         await batch.commit();
         scaffold.showSnackBar(const SnackBar(content: Text('✅ Database Seeded Successfully!')));
       } catch (e) {
         scaffold.showSnackBar(SnackBar(content: Text('Error seeding: $e')));
       }
    }
  }
  
  Future<void> _startSwiping(List<String> categories, List<String> customActivities, List<int> budgets, List<String> durations) async {
    if (categories.isEmpty && customActivities.isEmpty) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Please select at least one vibe or add a wild card!')),
        );
      }
      return;
    }

    setState(() => _isGenerating = true);
    
    try {
      // Generate the deck using SHARED draft data
      await ref.read(swipeDeckControllerProvider.notifier).generateDeck(
        explicitCustoms: customActivities,
      );
      
      if (!mounted) return;
      
      final deckState = ref.read(swipeDeckControllerProvider);
      
      if (deckState.hasError) {
        if (mounted) {
           ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error: ${deckState.error}')));
        }
        return;
      }
      
      if (!deckState.hasValue || deckState.value!.isEmpty) {
        if (mounted) {
           ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('No activities found...')));
        }
        return;
      }

      context.push('/swipe-match-enhanced');
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error generating deck: $e')));
      }
    } finally {
      if (mounted) {
        setState(() => _isGenerating = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    // Auto-navigation Listener - MOVED TO BUILD TOP
    ref.listen(sharedDraftSessionProvider, (prev, next) {
      if (next.hasValue && next.value != null) {
         if (next.value!.readyUsers.length >= 2) {
           // Prevent multiple navigations
           if (!_isGenerating && ModalRoute.of(context)?.isCurrent == true) {
             _startSwiping(
               next.value!.selectedCategories,
               next.value!.customActivities,
               next.value!.budgetLevels,
               next.value!.durationTiers,
             );
           }
         }
      }
    });

    // Watch shared draft with live updates
    final draftAsync = ref.watch(sharedDraftSessionProvider);

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios, color: AppColors.textPrimary),
          onPressed: () => Navigator.pop(context),
        ),
        title: GestureDetector(
          onLongPress: _seedDatabase,
          child: Column(
            children: const [
               Text(
                'Setup Lobby',
                style: TextStyle(
                  color: AppColors.textPrimary,
                  fontWeight: FontWeight.bold,
                ),
              ),
               Text(
                'Syncing with partner...',
                style: TextStyle(
                  color: AppColors.textSecondary,
                  fontSize: 10,
                ),
              ),
            ],
          ),
        ),
        centerTitle: true,
      ),
      body: draftAsync.when(
        loading: () => const Center(child: CircularProgressIndicator(color: AppColors.primary)),
        error: (err, stack) => Center(child: Text('Error loading lobby: $err', style: const TextStyle(color: Colors.white))),
        data: (draftSession) {
          final draft = draftSession ?? const DraftSession(); // Handle null (first load)
          
          return SafeArea(
            child: Column(
              children: [
                Expanded(
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.all(24),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // 1. Vibe Selection
                        const Text(
                          'Choose your vibe',
                          style: TextStyle(
                            color: AppColors.textPrimary,
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 8),
                        const Text(
                          'What represent your mood today? (Both can pick!)',
                          style: TextStyle(
                            color: AppColors.textSecondary,
                            fontSize: 16,
                          ),
                        ),
                        const SizedBox(height: 24),
                        
                        GridView.count(
                          shrinkWrap: true,
                          physics: const NeverScrollableScrollPhysics(),
                          crossAxisCount: 2,
                          mainAxisSpacing: 16,
                          crossAxisSpacing: 16,
                          childAspectRatio: 1.1,
                          children: ActivityCategory.values.map((category) {
                            final isSelected = draft.selectedCategories.contains(category.value);
                            return _CategoryCard(
                              category: category,
                              isSelected: isSelected,
                              onTap: () {
                                ref.read(draftSessionControllerProvider.notifier).toggleCategory(category.value);
                              },
                            );
                          }).toList(),
                        ),

                        const SizedBox(height: 32),

                        // 3. Custom Activities (Wild Cards)
                        const Text(
                          'Add Wild Cards 🃏',
                          style: TextStyle(
                            color: AppColors.textPrimary,
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 16),
                        
                        Row(
                          children: [
                            Expanded(
                              child: TextField(
                                controller: _customController,
                                style: const TextStyle(color: AppColors.textPrimary),
                                decoration: InputDecoration(
                                  hintText: 'e.g. Sushi, Massage...',
                                  hintStyle: TextStyle(color: AppColors.textSecondary.withOpacity(0.5), fontStyle: FontStyle.italic),
                                  filled: true,
                                  fillColor: AppColors.surface,
                                  border: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(12),
                                    borderSide: BorderSide.none,
                                  ),
                                ),
                              ),
                            ),
                            const SizedBox(width: 12),
                            IconButton(
                              onPressed: () {
                                if (_customController.text.trim().isNotEmpty) {
                                  ref.read(draftSessionControllerProvider.notifier).addCustomActivity(_customController.text.trim());
                                  _customController.clear();
                                }
                              },
                              style: IconButton.styleFrom(
                                backgroundColor: AppColors.primary,
                                padding: const EdgeInsets.all(12),
                                ),
                              icon: const Icon(Icons.add, color: Colors.white),
                            ),
                          ],
                        ),
                        
                        const SizedBox(height: 16),
                        if (draft.customActivities.isEmpty)
                          const Text('No wild cards added yet', style: TextStyle(color: AppColors.textSecondary)),
                          
                        Wrap(
                          spacing: 8,
                          runSpacing: 8,
                          children: draft.customActivities.map((custom) {
                            return Chip(
                              label: Text(custom),
                              backgroundColor: AppColors.primary.withOpacity(0.2),
                              labelStyle: const TextStyle(color: AppColors.primary),
                              deleteIcon: const Icon(Icons.close, size: 18, color: AppColors.primary),
                              onDeleted: () {
                                ref.read(draftSessionControllerProvider.notifier).removeCustomActivity(custom);
                              },
                            );
                          }).toList(),
                        ),
                        
                        const SizedBox(height: 100), // Spacing for bottom button
                      ],
                    ),
                  ),
                ),
                
                // Bottom Button (Waiting Room Logic)
                Builder(
                  builder: (context) {
                    final userId = ref.watch(authUserIdProvider);
                    // Safe access with default empty list if draft is new/null
                    final readyUsers = draft.readyUsers;
                    
                    final isMeReady = userId != null && readyUsers.contains(userId);
                    final isPartnerReady = readyUsers.any((id) => id != userId);
                    final isBothReady = readyUsers.length >= 2;

                    // Button State Logic
                    String label = 'Start Session';
                    Color color = AppColors.primary;
                    bool disabled = false;
                    
                    if (isBothReady) {
                      label = 'Launching... 🚀';
                      disabled = true; // Preventing double clicks while auto-nav happens
                    } else if (isMeReady) {
                      if (isPartnerReady) {
                        label = 'Launching... 🚀'; // Should auto-nav, but just in case
                      } else {
                        label = 'Waiting for Partner... ⏳';
                        color = AppColors.textSecondary;
                        disabled = true; 
                        label = 'Waiting... (Tap to Cancel)';
                        disabled = false;
                      }
                    } else {
                      if (isPartnerReady) {
                        label = 'Partner Ready! Join Now 👋';
                        color = Colors.green;
                      } else {
                        label = 'I\'m Ready! 🙋‍♂️';
                      }
                    }

                    return Padding(
                      padding: const EdgeInsets.all(24),
                      child: SizedBox(
                        width: double.infinity,
                        height: 56,
                        child: ElevatedButton(
                          onPressed: (_isGenerating || (disabled && !isMeReady))
                              ? null
                              : () {
                                  // Toggle Ready State instead of starting immediately
                                  HapticFeedback.mediumImpact();
                                  ref.read(draftSessionControllerProvider.notifier).toggleReady();
                                },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: isMeReady && !isBothReady ? AppColors.surface : color,
                            foregroundColor: isMeReady && !isBothReady ? AppColors.textPrimary : Colors.white,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(16),
                              side: isMeReady && !isBothReady 
                                ? BorderSide(color: AppColors.textSecondary.withOpacity(0.5)) 
                                : BorderSide.none,
                            ),
                            elevation: 0,
                          ),
                          child: _isGenerating
                              ? const SizedBox(height: 24, width: 24, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                              : Text(
                                  label,
                                  style: const TextStyle(
                                    fontSize: 18,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                        ),
                      ),
                    );
                  }
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}

class _CategoryCard extends StatelessWidget {
  final ActivityCategory category;
  final bool isSelected;
  final VoidCallback onTap;

  const _CategoryCard({
    required this.category,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        decoration: BoxDecoration(
          color: isSelected ? AppColors.primary : AppColors.surface,
          borderRadius: BorderRadius.circular(24),
          border: isSelected
              ? Border.all(color: AppColors.primary.withOpacity(0.5), width: 2)
              : null,
          boxShadow: isSelected
              ? [
                  BoxShadow(
                    color: AppColors.primary.withOpacity(0.3),
                    blurRadius: 12,
                    offset: const Offset(0, 4),
                  ),
                ]
              : [],
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              category.emoji,
              style: const TextStyle(fontSize: 32),
            ),
            const SizedBox(height: 12),
            Text(
              category.label,
              style: TextStyle(
                color: isSelected ? Colors.white : AppColors.textPrimary,
                fontWeight: FontWeight.bold,
                fontSize: 16,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              category.description,
              textAlign: TextAlign.center,
              style: TextStyle(
                color: isSelected
                    ? Colors.white.withOpacity(0.8)
                    : AppColors.textSecondary,
                fontSize: 12,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
