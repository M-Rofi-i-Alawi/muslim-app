import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:google_fonts/google_fonts.dart';
import '../viewmodel/panduan_ibadahn_viewmodel.dart';
import '../model/panduan_ibadah_model.dart';

const _kTeal      = Color(0xFF00A086);
const _kTealDark  = Color(0xFF007A68);
const _kTealLight = Color(0xFF00C4A7);
const _kGold      = Color(0xFFE8A020);
const _kBg        = Color(0xFFF2F4F7);

class PanduanIbadahPage extends StatelessWidget {
  const PanduanIbadahPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _kBg,
      body: Consumer<PanduanIbadahViewModel>(
        builder: (context, vm, _) {
          if (vm.selectedItem != null) {
            return _DetailPage(item: vm.selectedItem!);
          } else if (vm.selectedCategory != null) {
            return _CategoryItemsPage(category: vm.selectedCategory!);
          } else {
            return _CategoriesPage();
          }
        },
      ),
    );
  }
}

// ─────────────────────────────────────────────
// CATEGORIES PAGE
// ─────────────────────────────────────────────
class _CategoriesPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Column(
        children: [
          _buildAppBar(context),
          Expanded(
            child: Consumer<PanduanIbadahViewModel>(
              builder: (context, vm, _) {
                if (vm.isLoading) {
                  return const Center(
                      child: CircularProgressIndicator(color: _kTeal));
                }
                if (vm.error != null) {
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(Icons.wifi_off_rounded,
                            color: Colors.grey, size: 60),
                        const SizedBox(height: 12),
                        Text('Error: ${vm.error}',
                            style:
                                GoogleFonts.poppins(color: Colors.grey)),
                      ],
                    ),
                  );
                }
                return ListView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: vm.categories.length,
                  itemBuilder: (_, i) =>
                      _CategoryCard(category: vm.categories[i]),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAppBar(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(4, 8, 16, 16),
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [_kTealDark, _kTeal, _kTealLight],
        ),
      ),
      child: Row(
        children: [
          IconButton(
            icon: const Icon(Icons.arrow_back_ios_rounded,
                color: Colors.white),
            onPressed: () => Navigator.pop(context),
          ),
          const SizedBox(width: 4),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Panduan Ibadah',
                    style: GoogleFonts.poppins(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: Colors.white)),
                Text('Pedoman lengkap ibadah sehari-hari',
                    style: GoogleFonts.poppins(
                        fontSize: 12,
                        color: Colors.white.withOpacity(0.9))),
              ],
            ),
          ),
          Text('العبادة',
              style: TextStyle(
                  color: Colors.white.withOpacity(0.2),
                  fontSize: 24,
                  fontFamily: 'serif')),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────
// CATEGORY CARD
// ─────────────────────────────────────────────
class _CategoryCard extends StatelessWidget {
  final PanduanIbadahCategory category;
  const _CategoryCard({required this.category});

  @override
  Widget build(BuildContext context) {
    final vm    = context.read<PanduanIbadahViewModel>();
    final color = vm.getColor(category.color);

    return Container(
      margin: const EdgeInsets.only(bottom: 14),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
        gradient: LinearGradient(
            colors: [color, color.withOpacity(0.8)]),
        boxShadow: [
          BoxShadow(
              color: color.withOpacity(0.3),
              blurRadius: 12,
              offset: const Offset(0, 4)),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(20),
          onTap: () => vm.selectCategory(category),
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(14),
                  ),
                  child: Icon(_getIcon(category.icon),
                      size: 30, color: Colors.white),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(category.title,
                          style: GoogleFonts.poppins(
                              fontSize: 17,
                              fontWeight: FontWeight.bold,
                              color: Colors.white)),
                      const SizedBox(height: 4),
                      Text(category.description,
                          style: GoogleFonts.poppins(
                              fontSize: 12,
                              color:
                                  Colors.white.withOpacity(0.9))),
                      const SizedBox(height: 8),
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 10, vertical: 4),
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.2),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Text(
                          '${category.items.length} Panduan',
                          style: GoogleFonts.poppins(
                              fontSize: 11,
                              fontWeight: FontWeight.w600,
                              color: Colors.white),
                        ),
                      ),
                    ],
                  ),
                ),
                const Icon(Icons.chevron_right_rounded,
                    color: Colors.white, size: 26),
              ],
            ),
          ),
        ),
      ),
    );
  }

  IconData _getIcon(String icon) {
    switch (icon) {
      case 'prayer':           return Icons.self_improvement_rounded;
      case 'water_drop':       return Icons.water_drop_rounded;
      case 'fastfood_off':     return Icons.no_food_rounded;
      case 'volunteer_activism': return Icons.volunteer_activism_rounded;
      case 'flight':           return Icons.flight_rounded;
      default:                 return Icons.menu_book_rounded;
    }
  }
}

// ─────────────────────────────────────────────
// CATEGORY ITEMS PAGE
// ─────────────────────────────────────────────
class _CategoryItemsPage extends StatelessWidget {
  final PanduanIbadahCategory category;
  const _CategoryItemsPage({required this.category});

  @override
  Widget build(BuildContext context) {
    final vm    = context.read<PanduanIbadahViewModel>();
    final color = vm.getColor(category.color);

    return SafeArea(
      child: Column(
        children: [
          _buildHeader(context, color, vm),
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: category.items.length,
              itemBuilder: (_, i) => _ItemCard(
                  item: category.items[i], color: color),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHeader(
      BuildContext context, Color color, PanduanIbadahViewModel vm) {
    return Container(
      padding: const EdgeInsets.fromLTRB(4, 8, 16, 16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [_kTealDark, _kTeal, _kTealLight]),
      ),
      child: Row(
        children: [
          IconButton(
            icon: const Icon(Icons.arrow_back_ios_rounded,
                color: Colors.white),
            onPressed: vm.backToCategories,
          ),
          const SizedBox(width: 4),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(category.title,
                    style: GoogleFonts.poppins(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: Colors.white)),
                Text(category.description,
                    style: GoogleFonts.poppins(
                        fontSize: 12,
                        color: Colors.white.withOpacity(0.9))),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────
// ITEM CARD
// ─────────────────────────────────────────────
class _ItemCard extends StatelessWidget {
  final PanduanIbadahItem item;
  final Color color;
  const _ItemCard({required this.item, required this.color});

  @override
  Widget build(BuildContext context) {
    final vm = context.read<PanduanIbadahViewModel>();
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
              color: Colors.black.withOpacity(0.04),
              blurRadius: 8,
              offset: const Offset(0, 2)),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        borderRadius: BorderRadius.circular(16),
        child: InkWell(
          borderRadius: BorderRadius.circular(16),
          onTap: () => vm.selectItem(item),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                Container(
                  width: 48, height: 48,
                  decoration: BoxDecoration(
                    color: _kTeal.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Icon(Icons.menu_book_rounded,
                      color: _kTeal, size: 24),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(item.title,
                          style: GoogleFonts.poppins(
                              fontSize: 15,
                              fontWeight: FontWeight.w600,
                              color: const Color(0xFF1A1A2E))),
                      const SizedBox(height: 4),
                      Text(item.shortDesc,
                          style: GoogleFonts.poppins(
                              fontSize: 12,
                              color: Colors.grey[600])),
                    ],
                  ),
                ),
                Icon(Icons.chevron_right_rounded,
                    color: Colors.grey[400]),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────
// DETAIL PAGE
// ─────────────────────────────────────────────
class _DetailPage extends StatelessWidget {
  final PanduanIbadahItem item;
  const _DetailPage({required this.item});

  @override
  Widget build(BuildContext context) {
    final bottomPadding = MediaQuery.of(context).padding.bottom;
    return SafeArea(
      bottom: false,
      child: Column(
        children: [
          _buildHeader(context),
          Expanded(
            child: SingleChildScrollView(
              padding:
                  EdgeInsets.fromLTRB(16, 16, 16, 24 + bottomPadding),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  ...item.sections.map(_buildSection),
                  if (item.references.isNotEmpty) _buildReferences(),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    final vm = context.read<PanduanIbadahViewModel>();
    return Container(
      padding: const EdgeInsets.fromLTRB(4, 8, 16, 16),
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [_kTealDark, _kTeal, _kTealLight],
        ),
      ),
      child: Row(
        children: [
          IconButton(
            icon: const Icon(Icons.arrow_back_ios_rounded,
                color: Colors.white),
            onPressed: vm.backToItems,
          ),
          const SizedBox(width: 4),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(item.title,
                    style: GoogleFonts.poppins(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Colors.white),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis),
                Text(item.shortDesc,
                    style: GoogleFonts.poppins(
                        fontSize: 12,
                        color: Colors.white.withOpacity(0.9))),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSection(PanduanSection section) {
    return Container(
      margin: const EdgeInsets.only(bottom: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(section.title,
              style: GoogleFonts.poppins(
                  fontSize: 17,
                  fontWeight: FontWeight.bold,
                  color: _kTealDark)),
          const SizedBox(height: 10),
          _buildContent(section),
        ],
      ),
    );
  }

  Widget _buildContent(PanduanSection section) {
    switch (section.type) {
      case 'text':   return _buildTextContent(section.content);
      case 'list':   return _buildListContent(section.content);
      case 'steps':  return _buildStepsContent(section.content);
      case 'arabic': return _buildArabicContent(section.content);
      default:       return const SizedBox.shrink();
    }
  }

  Widget _buildTextContent(String text) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
              color: Colors.black.withOpacity(0.04),
              blurRadius: 6,
              offset: const Offset(0, 2)),
        ],
      ),
      child: Text(text,
          style: GoogleFonts.poppins(fontSize: 14, height: 1.7,
              color: Colors.grey[800])),
    );
  }

  Widget _buildListContent(List<String> items) {
    return Column(
      children: items.asMap().entries.map((e) {
        return Container(
          margin: const EdgeInsets.only(bottom: 8),
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: _kTeal.withOpacity(0.2)),
            boxShadow: [
              BoxShadow(
                  color: Colors.black.withOpacity(0.03),
                  blurRadius: 6,
                  offset: const Offset(0, 2)),
            ],
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 26, height: 26,
                decoration: const BoxDecoration(
                    color: _kTeal, shape: BoxShape.circle),
                child: Center(
                  child: Text('${e.key + 1}',
                      style: GoogleFonts.poppins(
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                          color: Colors.white)),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(e.value,
                    style: GoogleFonts.poppins(
                        fontSize: 14, height: 1.5,
                        color: Colors.grey[800])),
              ),
            ],
          ),
        );
      }).toList(),
    );
  }

  Widget _buildStepsContent(List<StepItem> steps) {
    return Column(
        children: steps.map(_buildStepCard).toList());
  }

  Widget _buildStepCard(StepItem step) {
    return Container(
      margin: const EdgeInsets.only(bottom: 14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
              color: Colors.black.withOpacity(0.04),
              blurRadius: 8,
              offset: const Offset(0, 2)),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Step header — teal
          Container(
            padding: const EdgeInsets.all(14),
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                  colors: [_kTealDark, _kTeal]),
              borderRadius: BorderRadius.only(
                topLeft: Radius.circular(16),
                topRight: Radius.circular(16),
              ),
            ),
            child: Row(
              children: [
                Container(
                  width: 38, height: 38,
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.2),
                    shape: BoxShape.circle,
                  ),
                  child: Center(
                    child: Text('${step.number}',
                        style: GoogleFonts.poppins(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: Colors.white)),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(step.title,
                      style: GoogleFonts.poppins(
                          fontSize: 15,
                          fontWeight: FontWeight.bold,
                          color: Colors.white)),
                ),
              ],
            ),
          ),
          // Step content
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(step.description,
                    style: GoogleFonts.poppins(
                        fontSize: 14, height: 1.6,
                        color: Colors.grey[700])),
                if (step.arabic != null) ...[
                  const SizedBox(height: 14),
                  _arabicBox(
                    arab: step.arabic!,
                    latin: step.transliteration,
                    terjemahan: step.translation,
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildArabicContent(ArabicText content) {
    return _arabicBox(
      arab: content.arabic,
      latin: content.transliteration,
      terjemahan: content.translation,
    );
  }

  Widget _arabicBox({
    required String arab,
    String? latin,
    String? terjemahan,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: _kTeal.withOpacity(0.05),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: _kTeal.withOpacity(0.2)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(arab,
              textAlign: TextAlign.right,
              style: const TextStyle(
                  fontSize: 20,
                  fontFamily: 'serif',
                  height: 2.2,
                  color: Color(0xFF1A1A2E))),
          if (latin != null) ...[
            const SizedBox(height: 10),
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(latin,
                  style: GoogleFonts.poppins(
                      fontSize: 13,
                      fontStyle: FontStyle.italic,
                      color: _kTeal,
                      height: 1.6)),
            ),
          ],
          if (terjemahan != null) ...[
            const SizedBox(height: 8),
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: _kGold.withOpacity(0.08),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Icon(Icons.translate_rounded,
                      size: 15, color: _kGold),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(terjemahan,
                        style: GoogleFonts.poppins(
                            fontSize: 13,
                            color: Colors.grey[800],
                            height: 1.6)),
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildReferences() {
    return Container(
      margin: const EdgeInsets.only(top: 20),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: _kGold.withOpacity(0.08),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: _kGold.withOpacity(0.3)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.menu_book_rounded, size: 18, color: _kGold),
              const SizedBox(width: 8),
              Text('Referensi',
                  style: GoogleFonts.poppins(
                      fontSize: 13,
                      fontWeight: FontWeight.bold,
                      color: _kGold)),
            ],
          ),
          const SizedBox(height: 8),
          ...item.references.map((ref) => Padding(
                padding: const EdgeInsets.only(top: 4),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('• ',
                        style: GoogleFonts.poppins(
                            fontSize: 13, color: _kGold)),
                    Expanded(
                      child: Text(ref,
                          style: GoogleFonts.poppins(
                              fontSize: 13,
                              color: Colors.grey[700])),
                    ),
                  ],
                ),
              )),
        ],
      ),
    );
  }
}