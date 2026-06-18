import 'package:flutter/material.dart';
import '../services/api_service.dart';
import 'threat_details_screen.dart';

class ThreatIntelScreen extends StatefulWidget {
  const ThreatIntelScreen({super.key});

  @override
  State<ThreatIntelScreen> createState() => _ThreatIntelScreenState();
}

class _ThreatIntelScreenState extends State<ThreatIntelScreen> {
  List<dynamic> _allThreats = [];
  List<dynamic> _filteredThreats = [];

  final TextEditingController _searchController = TextEditingController();
  bool _isLoading = true;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _fetchThreatData();
  }

  // Helper method to assign weight values for severity sorting rules
  int _getSeverityWeight(String? severity) {
    switch (severity?.toUpperCase()) {
      case 'CRITICAL': return 4;
      case 'HIGH': return 3;
      case 'MEDIUM': return 2;
      case 'LOW': return 1;
      default: return 0;
    }
  }

  // Fetch threat datasets on initialization or refresh
  Future<void> _fetchThreatData() async {
    try {
      final data = await ApiService.getThreats();

      // Sort data dynamically by custom severity hierarchy (highest priority first)
      data.sort((a, b) {
        final weightA = _getSeverityWeight(a["severity"]);
        final weightB = _getSeverityWeight(b["severity"]);
        return weightB.compareTo(weightA); // Descending order
      });

      setState(() {
        _allThreats = data;
        _isLoading = false;
        _errorMessage = null;

        if (_searchController.text.isEmpty) {
          _filteredThreats = data;
        } else {
          _filterSearch(_searchController.text);
        }
      });
    } catch (e) {
      setState(() {
        _errorMessage = e.toString();
        _isLoading = false;
      });
    }
  }

  // Local collection content filtering rule mechanics
  void _filterSearch(String query) {
    setState(() {
      if (query.isEmpty) {
        _filteredThreats = _allThreats;
      } else {
        final lowercaseQuery = query.toLowerCase();
        _filteredThreats = _allThreats.where((threat) {
          final cve = (threat["cve"] ?? "").toString().toLowerCase();
          final title = (threat["title"] ?? "").toString().toLowerCase();
          final vendor = (threat["vendor"] ?? "").toString().toLowerCase();
          final product = (threat["product"] ?? "").toString().toLowerCase();

          return cve.contains(lowercaseQuery) ||
              title.contains(lowercaseQuery) ||
              vendor.contains(lowercaseQuery) ||
              product.contains(lowercaseQuery);
        }).toList();
      }
    });
  }

  // Logic to parse count totals for the Summary Metric Cards widget
  int _getCountBySeverity(String severityLevel) {
    return _filteredThreats.where((t) =>
    (t["severity"] ?? "").toString().toUpperCase() == severityLevel.toUpperCase()
    ).length;
  }

  Color _getSeverityColor(String? severity) {
    switch (severity?.toUpperCase()) {
      case 'CRITICAL': return Colors.red.shade900;
      case 'HIGH': return Colors.red.shade400;
      case 'MEDIUM': return Colors.orange.shade400;
      case 'LOW': return Colors.green.shade400;
      default: return Colors.grey.shade400;
    }
  }

  // Completely Native Replacement: Shows a beautiful detailed layout modal sheet directly in-app
  void _showThreatDetails(Map<String, dynamic> threat) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) {
        final severity = threat["severity"] ?? 'UNKNOWN';
        final accentColor = _getSeverityColor(severity);

        return Container(
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
          ),
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: Container(
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: Colors.grey.shade300,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
              const SizedBox(height: 16),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    threat["cve"] ?? "Unknown CVE",
                    style: const TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                      color: Colors.blueGrey,
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(
                      color: accentColor,
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      severity,
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: 12,
                      ),
                    ),
                  ),
                ],
              ),
              const Divider(height: 24),
              const Text(
                "VULNERABILITY DESCRIPTION",
                style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Colors.grey),
              ),
              const SizedBox(height: 6),
              Text(
                threat["title"] ?? "No Description Provided",
                style: const TextStyle(fontSize: 16, height: 1.4, fontWeight: FontWeight.w500),
              ),
              const SizedBox(height: 20),
              const Text(
                "AFFECTED METRICS",
                style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Colors.grey),
              ),
              const SizedBox(height: 8),
              _buildDetailRow(Icons.business, "Vendor", threat["vendor"]),
              _buildDetailRow(Icons.layers, "Product", threat["product"]),
              _buildDetailRow(Icons.calendar_today, "Date Added", threat["dateAdded"]),
              const SizedBox(height: 24),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.blueGrey.shade900,
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                  ),
                  onPressed: () => Navigator.pop(context),
                  child: const Text("Dismiss Review", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildDetailRow(IconData icon, String label, String? value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        children: [
          Icon(icon, size: 18, color: Colors.blueGrey.shade700),
          const SizedBox(width: 10),
          Text("$label: ", style: const TextStyle(fontWeight: FontWeight.bold)),
          Expanded(child: Text(value ?? 'N/A', overflow: TextOverflow.ellipsis)),
        ],
      ),
    );
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          "Threat Intelligence",
          style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white),
        ),
        backgroundColor: Colors.blueGrey.shade900,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh, color: Colors.white),
            tooltip: "Refresh Feed",
            onPressed: _fetchThreatData,
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _errorMessage != null
          ? Center(child: Text("Error fetching records: $_errorMessage"))
          : Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
            child: TextField(
              controller: _searchController,
              onChanged: (value) {
                _filterSearch(value);
              },
              decoration: InputDecoration(
                labelText: "Search CVE, Vendor, or Product",
                prefixIcon: const Icon(Icons.search, color: Colors.blueGrey),
                suffixIcon: _searchController.text.isNotEmpty
                    ? IconButton(
                  icon: const Icon(Icons.clear),
                  onPressed: () {
                    _searchController.clear();
                    _filterSearch('');
                  },
                )
                    : null,
                border: const OutlineInputBorder(
                  borderRadius: BorderRadius.all(Radius.circular(12.0)),
                ),
              ),
            ),
          ),

          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
            child: Text(
              "${_filteredThreats.length} Threats Found",
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: Colors.blueGrey,
              ),
            ),
          ),

          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                _buildSummaryCard("CRITICAL", _getCountBySeverity("CRITICAL"), Colors.red.shade900),
                _buildSummaryCard("HIGH", _getCountBySeverity("HIGH"), Colors.red.shade400),
                _buildSummaryCard("MEDIUM", _getCountBySeverity("MEDIUM"), Colors.orange.shade400),
                _buildSummaryCard("LOW", _getCountBySeverity("LOW"), Colors.green.shade400),
              ],
            ),
          ),

          const Divider(height: 16, thickness: 1),

          Expanded(
            child: _filteredThreats.isEmpty
                ? const Center(
              child: Text(
                "No threat records match your search criteria.",
                style: TextStyle(color: Colors.grey, fontSize: 16),
              ),
            )
                : RefreshIndicator(
              onRefresh: _fetchThreatData,
              color: Colors.blueGrey.shade900,
              child: ListView.builder(
                padding: const EdgeInsets.only(left: 16, right: 16, bottom: 24),
                itemCount: _filteredThreats.length,
                physics: const AlwaysScrollableScrollPhysics(),
                itemBuilder: (context, index) {
                  final threat = _filteredThreats[index];
                  final cveId = threat["cve"] ?? "Unknown CVE";

                  return Card(
                    elevation: 3,
                    margin: const EdgeInsets.symmetric(vertical: 8),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    child: InkWell(
                      borderRadius: BorderRadius.circular(12),
                      // ── ROUTE TO FULL SCREEN INTEL DEEP DIVE ──
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => ThreatDetailsScreen(threat: threat),
                          ),
                        );
                      },
                      child: Padding(
                        padding: const EdgeInsets.all(16),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  cveId,
                                  style: const TextStyle(
                                    fontSize: 18,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.blueGrey,
                                  ),
                                ),
                                const Icon(Icons.arrow_forward_ios, size: 14, color: Colors.grey),
                              ],
                            ),
                            const SizedBox(height: 8),
                            Text(
                              threat["title"] ?? "No Title Provided",
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                              style: const TextStyle(
                                fontSize: 15,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                            const SizedBox(height: 12),
                            Text(
                              "Vendor: ${threat["vendor"] ?? 'N/A'}",
                              style: TextStyle(color: Colors.grey.shade700),
                            ),
                            Text(
                              "Product: ${threat["product"] ?? 'N/A'}",
                              style: TextStyle(color: Colors.grey.shade700),
                            ),
                            Text(
                              "Added: ${threat["dateAdded"] ?? 'N/A'}",
                              style: TextStyle(color: Colors.grey.shade700),
                            ),
                            const SizedBox(height: 12),
                            Row(
                              children: [
                                Icon(
                                  Icons.warning,
                                  color: _getSeverityColor(threat["severity"]),
                                  size: 20,
                                ),
                                const SizedBox(width: 8),
                                Chip(
                                  backgroundColor: _getSeverityColor(threat["severity"]),
                                  label: Text(
                                    threat["severity"] ?? 'UNKNOWN',
                                    style: const TextStyle(
                                      color: Colors.white,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSummaryCard(String title, int count, Color accentColor) {
    return Expanded(
      child: Card(
        elevation: 2,
        margin: const EdgeInsets.symmetric(horizontal: 4),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 4),
          child: Column(
            children: [
              Text(
                title,
                style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: accentColor),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
              const SizedBox(height: 4),
              Text(
                "$count",
                style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
            ],
          ),
        ),
      ),
    );
  }
}