import 'package:flutter/material.dart';
import 'package:easy_localization/easy_localization.dart';
import '../ads_controller.dart';
import '../billing_manager.dart';
import 'package:auto_size_text/auto_size_text.dart';

class VipScreen extends StatefulWidget {
  const VipScreen({super.key});

  @override
  State<VipScreen> createState() => _VipScreenState();
}

class _VipScreenState extends State<VipScreen> {
  int selectedPlan = 0; // 0 - месяц, 1 - год
  bool _isLoading = false;
  bool _isInitialized = false;

  @override
  void initState() {
    super.initState();
    _initializeBilling();

    // ✅ ИСПРАВЛЕНО: Используем правильный метод обновления статуса
    BillingManager.onSubscriptionChanged = () {
      if (mounted) {
        // Используем метод updateSubscriptionStatus вместо прямого присвоения
        AdsController().updateSubscriptionStatus(true);

        setState(() {}); // Обновляем UI

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('pro_activated'.tr())),
        );
        Navigator.pop(context);
      }
    };
  }

  Future<void> _initializeBilling() async {
    try {
      await BillingManager.initialize();
      if (mounted) {
        setState(() {
          _isInitialized = true; // ✅ ИСПРАВЛЕНО: устанавливаем true при успехе
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isInitialized = false; // ✅ При ошибке = false
        });
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('billing_init_error'.tr() + ': $e')),
        );
      }
    }
  }

  Future<void> _purchaseSubscription() async {
    if (!_isInitialized) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('billing_not_initialized'.tr())),
      );
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      final productId = selectedPlan == 0
          ? BillingManager.monthlyProductId
          : BillingManager.yearlyProductId;

      await BillingManager.buySubscription(productId);
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('purchase_error'.tr() + ': $e')),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  Future<void> _restorePurchases() async {
    if (!_isInitialized) return;

    setState(() {
      _isLoading = true;
    });

    try {
      await BillingManager.restorePurchases();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('purchases_restored'.tr())),
      );
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('restore_error'.tr() + ': $e')),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [Color(0xFF181818), Color(0xFF232323), Color(0xFF181818)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: SafeArea(
          child: SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.all(22.0),
              child: Column(
                mainAxisSize: MainAxisSize.max,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // Кнопка "Назад"
                  Row(
                    children: [
                      IconButton(
                        onPressed: () => Navigator.pop(context),
                        icon: Icon(Icons.arrow_back, color: Colors.white),
                      ),
                      Spacer(),
                      TextButton(
                        onPressed: _isInitialized ? _restorePurchases : null,
                        child: Text(
                          'restore_purchases'.tr(), // ✅ ИСПРАВЛЕНО: локализация
                          style: TextStyle(color: Colors.white70),
                        ),
                      ),
                    ],
                  ),

                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      ShaderMask(
                        shaderCallback: (Rect bounds) {
                          return const LinearGradient(
                            colors: [Color(0xFFFFD700), Color(0xFFFFA500)],
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                          ).createShader(bounds);
                        },
                        child: Icon(Icons.workspace_premium,
                            size: 54, color: Colors.white),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: AutoSizeText(
                          'pro_title'.tr(),
                          style: TextStyle(
                            color: Color(0xFFFFD700),
                            fontWeight: FontWeight.w900,
                            fontSize: 28,
                            letterSpacing: 2,
                            shadows: [
                              Shadow(
                                color: Colors.black.withOpacity(0.4),
                                blurRadius: 8,
                                offset: Offset(0, 2),
                              ),
                            ],
                          ),
                          maxLines: 1,
                          minFontSize: 14,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 18),

                  Card(
                    color: const Color(0xFF232323),
                    elevation: 12,
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(20)),
                    child: Padding(
                      padding: const EdgeInsets.all(22.0),
                      child: Column(
                        children: [
                          ShaderMask(
                            shaderCallback: (Rect bounds) {
                              return const LinearGradient(
                                colors: [Color(0xFFFFD700), Color(0xFFFFA500)],
                                begin: Alignment.topLeft,
                                end: Alignment.bottomRight,
                              ).createShader(bounds);
                            },
                            child:
                                Icon(Icons.star, color: Colors.white, size: 48),
                          ),
                          const SizedBox(height: 10),
                          Text(
                            'pro_subtitle'.tr(),
                            style: TextStyle(
                              fontSize: 19,
                              fontWeight: FontWeight.bold,
                              color: Color(0xFFFFD700),
                              letterSpacing: 1.1,
                            ),
                            textAlign: TextAlign.center,
                          ),
                          const SizedBox(height: 16),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              _feature('pro_feature_no_ads'.tr()),
                              _feature('pro_feature_export'.tr()),
                              _feature('pro_feature_all_functions'.tr()),
                              _feature('pro_feature_support'.tr()),
                              _feature('pro_feature_templates'.tr()),
                              _feature('pro_feature_save_load'.tr()),
                              _feature('pro_feature_fast_updates'.tr()),
                              _feature('pro_feature_badge'.tr()),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 32),

                  Text(
                    'pro_choose_plan'.tr(),
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.w900,
                      color: Color(0xFFFFD700),
                      letterSpacing: 2,
                      shadows: [
                        Shadow(
                          color: Colors.black.withOpacity(0.4),
                          blurRadius: 8,
                          offset: Offset(0, 2),
                        ),
                      ],
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 18),

                  // ✅ УЛУЧШЕНО: Лучший индикатор загрузки
                  if (!_isInitialized)
                    Center(
                      child: Column(
                        children: [
                          CircularProgressIndicator(
                            valueColor: AlwaysStoppedAnimation<Color>(
                                Color(0xFFFFD700)),
                          ),
                          SizedBox(height: 16),
                          Text(
                            'loading_products'.tr(),
                            style: TextStyle(color: Colors.white70),
                          ),
                        ],
                      ),
                    )
                  else
                    Row(
                      children: [
                        Expanded(
                          child: _planCard(
                            title: 'pro_plan_month'.tr(),
                            price: BillingManager.getProductPrice(
                                BillingManager.monthlyProductId),
                            selected: selectedPlan == 0,
                            onTap: () => setState(() => selectedPlan = 0),
                            badge: null,
                          ),
                        ),
                        const SizedBox(width: 18),
                        Expanded(
                          child: _planCard(
                            title: 'pro_plan_year'.tr(),
                            price: BillingManager.getProductPrice(
                                BillingManager.yearlyProductId),
                            selected: selectedPlan == 1,
                            onTap: () => setState(() => selectedPlan = 1),
                            badge: 'pro_plan_gold'.tr(),
                          ),
                        ),
                      ],
                    ),

                  const SizedBox(height: 32),

                  Container(
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(16),
                      boxShadow: [
                        BoxShadow(
                          color: Color(0xFFFFD700).withOpacity(0.5),
                          blurRadius: 18,
                          spreadRadius: 2,
                          offset: Offset(0, 6),
                        ),
                      ],
                    ),
                    child: ElevatedButton.icon(
                      icon: _isLoading
                          ? SizedBox(
                              width: 20,
                              height: 20,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                valueColor: AlwaysStoppedAnimation<Color>(
                                    Color(0xFFFFD700)),
                              ),
                            )
                          : Icon(Icons.lock_open_rounded,
                              color: Color(0xFFFFD700)),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.black,
                        padding: const EdgeInsets.symmetric(vertical: 20),
                        textStyle: const TextStyle(
                            fontSize: 20, fontWeight: FontWeight.bold),
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(16)),
                        side: const BorderSide(
                            color: Color(0xFFFFD700), width: 2.5),
                        foregroundColor: Color(0xFFFFD700),
                        elevation: 0,
                      ),
                      onPressed: (_isLoading || !_isInitialized)
                          ? null
                          : _purchaseSubscription,
                      label: Text(
                        _isLoading
                            ? 'processing'.tr() // ✅ ИСПРАВЛЕНО: локализация
                            : (selectedPlan == 0
                                ? 'pro_buy_month'.tr()
                                : 'pro_buy_year'.tr()),
                        style: const TextStyle(
                          color: Color(0xFFFFD700),
                          fontWeight: FontWeight.bold,
                          fontSize: 19,
                          letterSpacing: 1.2,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 18),

                  TextButton(
                    onPressed: () => Navigator.pop(context),
                    child: Text(
                      'later_btn'.tr(),
                      style:
                          const TextStyle(fontSize: 16, color: Colors.white70),
                    ),
                  ),
                  const SizedBox(height: 10),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _feature(String text) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 7.0),
      child: Row(
        children: [
          Icon(Icons.check_circle, color: Color(0xFFFFD700), size: 25),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              text,
              style: const TextStyle(
                  fontSize: 18,
                  color: Colors.white,
                  fontWeight: FontWeight.w500),
            ),
          ),
        ],
      ),
    );
  }

  Widget _planCard({
    required String title,
    required String price,
    required bool selected,
    required VoidCallback onTap,
    String? badge,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Stack(
        children: [
          AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color:
                  selected ? const Color(0xFF2D2D2D) : const Color(0xFF232323),
              border: Border.all(
                color:
                    selected ? const Color(0xFFFFD700) : Colors.grey.shade700,
                width: selected ? 3 : 1.5,
              ),
              borderRadius: BorderRadius.circular(18),
              boxShadow: [
                if (selected)
                  BoxShadow(
                    color: const Color(0xFFFFD700).withOpacity(0.13),
                    blurRadius: 16,
                    offset: const Offset(0, 8),
                  ),
              ],
            ),
            child: Column(
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFFFFD700),
                  ),
                ),
                const SizedBox(height: 10),
                Text(
                  price,
                  style: const TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFFFFD700),
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  selected ? 'pro_selected'.tr() : '',
                  style: const TextStyle(color: Color(0xFFFFD700)),
                ),
              ],
            ),
          ),
          if (badge != null)
            Positioned(
              top: 12,
              right: 12,
              child: Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 12, vertical: 5),
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [Color(0xFFFFD700), Color(0xFFFFA500)],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(12),
                  boxShadow: [
                    BoxShadow(
                      color: Color(0xFFFFD700).withOpacity(0.4),
                      blurRadius: 8,
                      offset: Offset(0, 2),
                    ),
                  ],
                ),
                child: Text(
                  badge,
                  style: const TextStyle(
                    color: Colors.black,
                    fontWeight: FontWeight.bold,
                    fontSize: 14,
                    letterSpacing: 1.2,
                    shadows: [
                      Shadow(
                        color: Colors.white,
                        blurRadius: 6,
                      ),
                    ],
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    BillingManager.onSubscriptionChanged = null;
    super.dispose();
  }
}
