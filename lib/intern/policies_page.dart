import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../models/intern.dart';
import '../models/policy.dart';
import '../services/api_service.dart';

class PoliciesPage extends StatefulWidget {
  final Intern intern;
  const PoliciesPage({super.key, required this.intern});

  @override
  State<PoliciesPage> createState() => _PoliciesPageState();
}

class _PoliciesPageState extends State<PoliciesPage> {
  List<Policy> policies = [];
  bool isLoading = true;
  String? error;

  @override
  void initState() {
    super.initState();
    _loadPolicies();
  }

  Future<void> _loadPolicies() async {
    try {
      setState(() {
        isLoading = true;
        error = null;
      });

      policies = await ApiService.getPolicies();

      setState(() => isLoading = false);
    } catch (e) {
      setState(() {
        isLoading = false;
        error = "Failed to load policies";
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final primary = const Color(0xFF2D3A8C);

    return RefreshIndicator(
      onRefresh: _loadPolicies,
      color: primary,
      child: SingleChildScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [

            Row(
              children: [
                Icon(Icons.policy, color: primary, size: 28),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    "Company Policies",
                    style: GoogleFonts.poppins(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: primary,
                    ),
                  ),
                ),
                IconButton(
                  icon: Icon(Icons.refresh, color: primary),
                  onPressed: _loadPolicies,
                ),
              ],
            ),

            const SizedBox(height: 8),

            Text(
              "${policies.length} policies available",
              style: GoogleFonts.poppins(
                fontSize: 14,
                color: Colors.grey[600],
              ),
            ),

            const SizedBox(height: 24),


            if (isLoading)
              const Center(child: CircularProgressIndicator())

            else if (error != null)
              Center(child: Text(error!))

            else if (policies.isEmpty)
                Center(
                  child: Text(
                    "No policies available",
                    style: GoogleFonts.poppins(),
                  ),
                )

              else
                ListView.separated(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: policies.length,
                  separatorBuilder: (_, __) => const SizedBox(height: 12),
                  itemBuilder: (context, index) {
                    final policy = policies[index];

                    return Card(
                      elevation: 3,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: Padding(
                        padding: const EdgeInsets.all(20),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [

                            Row(
                              children: [
                                Container(
                                  padding: const EdgeInsets.all(12),
                                  decoration: BoxDecoration(
                                    color: primary.withOpacity(0.1),
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  child: Icon(
                                    Icons.policy,
                                    color: primary,
                                  ),
                                ),
                                const SizedBox(width: 16),

                                Expanded(
                                  child: Text(
                                    policy.title,
                                    style: GoogleFonts.poppins(
                                      fontSize: 16,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                ),
                              ],
                            ),

                            const SizedBox(height: 12),


                            Text(
                              policy.description,
                              style: GoogleFonts.poppins(
                                fontSize: 13,
                                color: Colors.grey[700],
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
          ],
        ),
      ),
    );
  }
}