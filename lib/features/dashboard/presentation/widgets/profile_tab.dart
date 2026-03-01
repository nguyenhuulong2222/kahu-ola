import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class ProfileTab extends StatefulWidget {
  const ProfileTab({super.key});

  @override
  State<ProfileTab> createState() => _ProfileTabState();
}

class _ProfileTabState extends State<ProfileTab> {
  Locale _selectedLocale = const Locale('en');

  final DocumentReference<Map<String, dynamic>> _userDocRef =
      FirebaseFirestore.instance
          .collection('users')
          .doc('Q9rVN0uRBRePsUnrWxZf');

  Future<void> _saveProfile() async {
    try {
      await _userDocRef.update({
        'fullName': 'Nguyen Van A',
        'address': 'Kihei, Maui, HI',
        'memberCount': 4,
      });

      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Da luu thong tin len Firebase')),
      );
    } on FirebaseException catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Loi luu du lieu: ${e.message ?? e.code}')),
      );
    }
  }

  String _memberCountText(Object? memberCount) {
    if (memberCount is int) {
      return '$memberCount nguoi';
    }
    if (memberCount is double) {
      return '${memberCount.toInt()} nguoi';
    }
    if (memberCount is String && memberCount.isNotEmpty) {
      return '$memberCount nguoi';
    }
    return '4 nguoi';
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;

    return Localizations.override(
      context: context,
      locale: _selectedLocale,
      child: Builder(
        builder: (context) {
          final tt = Theme.of(context).textTheme;

          return Stack(
            children: [
              StreamBuilder<DocumentSnapshot<Map<String, dynamic>>>(
                stream: _userDocRef.snapshots(),
                builder: (context, snapshot) {
                  final data = snapshot.data?.data();
                  final fullName =
                      (data?['fullName'] as String?) ?? 'Nguyen Van A';
                  final address =
                      (data?['address'] as String?) ?? 'Kihei, Maui, HI';
                  final memberCount = _memberCountText(data?['memberCount']);

                  if (snapshot.connectionState == ConnectionState.waiting &&
                      data == null) {
                    return const Center(child: CircularProgressIndicator());
                  }

                  return ListView(
                    padding: const EdgeInsets.fromLTRB(16, 60, 16, 16),
                    children: [
                      Padding(
                        padding: const EdgeInsets.only(bottom: 12),
                        child: Text(
                          'Ho so ca nhan',
                          style: tt.headlineSmall?.copyWith(
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ),
                      Card(
                        elevation: 0,
                        color: cs.surfaceContainerHighest,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                        ),
                        child: Padding(
                          padding: const EdgeInsets.all(16),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  Icon(Icons.home_rounded, color: cs.primary),
                                  const SizedBox(width: 8),
                                  Text(
                                    'Thong tin ho gia dinh',
                                    style: tt.titleMedium?.copyWith(
                                      fontWeight: FontWeight.w700,
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 12),
                              _InfoRow(label: 'Ho ten', value: fullName),
                              _InfoRow(label: 'Dia chi', value: address),
                              _InfoRow(
                                label: 'So thanh vien',
                                value: memberCount,
                              ),
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(height: 12),
                      Card(
                        elevation: 0,
                        color: cs.surfaceContainerHighest,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                        ),
                        child: Padding(
                          padding: const EdgeInsets.all(16),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  Icon(
                                    Icons.checklist_rounded,
                                    color: cs.primary,
                                  ),
                                  const SizedBox(width: 8),
                                  Text(
                                    'Danh sach sinh ton',
                                    style: tt.titleMedium?.copyWith(
                                      fontWeight: FontWeight.w700,
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 12),
                              const _ChecklistItem(
                                label: 'Nuoc',
                                checked: true,
                              ),
                              const _ChecklistItem(
                                label: 'Luong kho',
                                checked: true,
                              ),
                              const _ChecklistItem(
                                label: 'Den pin',
                                checked: false,
                              ),
                              const _ChecklistItem(
                                label: 'Radio',
                                checked: false,
                              ),
                              const _ChecklistItem(
                                label: 'Giay to tuy than',
                                checked: true,
                              ),
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(height: 12),
                      Card(
                        elevation: 0,
                        color: cs.surface,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                        ),
                        child: Padding(
                          padding: const EdgeInsets.all(16),
                          child: SizedBox(
                            width: double.infinity,
                            child: FilledButton.icon(
                              style: FilledButton.styleFrom(
                                backgroundColor: Colors.green,
                                foregroundColor: Colors.white,
                                padding: const EdgeInsets.symmetric(vertical: 14),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                              ),
                              onPressed: _saveProfile,
                              icon: const Icon(Icons.save_rounded),
                              label: const Text('Luu'),
                            ),
                          ),
                        ),
                      ),
                    ],
                  );
                },
              ),
              Positioned(
                top: 8,
                right: 12,
                child: Card(
                  elevation: 1,
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 8),
                    child: DropdownButtonHideUnderline(
                      child: DropdownButton<Locale>(
                        value: _selectedLocale,
                        icon: const Icon(Icons.language_rounded, size: 18),
                        style: tt.bodySmall,
                        items: const [
                          DropdownMenuItem(
                            value: Locale('en'),
                            child: Text('English'),
                          ),
                          DropdownMenuItem(
                            value: Locale('vi'),
                            child: Text('Tieng Viet'),
                          ),
                          DropdownMenuItem(
                            value: Locale('haw'),
                            child: Text('Olelo Hawaii'),
                          ),
                        ],
                        onChanged: (value) {
                          if (value == null) return;
                          setState(() {
                            _selectedLocale = value;
                          });
                        },
                      ),
                    ),
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}

class _InfoRow extends StatelessWidget {
  const _InfoRow({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    final tt = Theme.of(context).textTheme;

    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 120,
            child: Text(
              '$label:',
              style: tt.bodyMedium?.copyWith(
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: tt.bodyMedium,
            ),
          ),
        ],
      ),
    );
  }
}

class _ChecklistItem extends StatelessWidget {
  const _ChecklistItem({required this.label, required this.checked});

  final String label;
  final bool checked;

  @override
  Widget build(BuildContext context) {
    return ListTile(
      contentPadding: EdgeInsets.zero,
      dense: true,
      leading: Icon(
        checked
            ? Icons.check_circle_rounded
            : Icons.radio_button_unchecked_rounded,
        color: checked ? Colors.green : Theme.of(context).colorScheme.outline,
      ),
      title: Text(label),
    );
  }
}
