import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../core/widgets/aura_app_bar.dart';
import '../../../../services/api_service.dart';
import '../../../../services/socket_service.dart';
import '../widgets/vitals_card.dart';
import '../widgets/vitals_graphs.dart';

class DoctorPatientScreen extends StatefulWidget {
  final int patientId;
  const DoctorPatientScreen({super.key, required this.patientId});

  @override
  State<DoctorPatientScreen> createState() => _DoctorPatientScreenState();
}

class _DoctorPatientScreenState extends State<DoctorPatientScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  Map<String, dynamic>? _patientData;
  List<dynamic> _medications = [];
  bool _isLoading = true;

  // Mock static data for elegance
  final List<Map<String, String>> _history = [
    {'date': '2023-11-15', 'type': 'Diagnosis', 'note': 'Hypertension detected. Prescribed Amlodipine.'},
    {'date': '2023-10-02', 'type': 'Lab Result', 'note': 'Cholesterol levels elevated (240 mg/dL).'},
    {'date': '2023-09-10', 'type': 'Visit', 'note': 'Regular checkup. Patient reported mild dizziness.'},
  ];

  final List<String> _symptoms = [
    "Shortness of breath",
    "Mild Chest Pain",
    "Fatigue"
  ];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    _loadData();
    
    // Connect to live stream immediately
    SocketService().subscribePatient(widget.patientId);
  }

  Future<void> _loadData() async {
    try {
      final data = await ApiService().getPatientTwin(widget.patientId);
      final meds = await ApiService().getPatientMedications(widget.patientId);
      if (mounted) {
        setState(() {
          _patientData = data;
          _medications = meds;
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Scaffold(
        appBar: AuraAppBar(title: "Patient Details"),
        body: Center(child: CupertinoActivityIndicator(radius: 16)),
      );
    }

    if (_patientData == null) {
       return const Scaffold(
        appBar: AuraAppBar(title: "Patient Details"),
        body: Center(child: Text("Patient not found.")),
      );
    }

    // Determine status (Mocking 'Admitted' logic if not in backend, or using what's there)
    // For demo purposes, let's assume if ID is 1, they are admitted.
    bool isAdmitted = widget.patientId == 1; // Logic as requested: Only show vitals if admitted
    // Or check backend field: _patientData!['status'] == 'Admitted';
    
    String status = isAdmitted ? "Admitted" : "Discharged"; // Mocking for now to force the view for Patient 1
    Color statusColor = isAdmitted ? AppColors.error : AppColors.success;

    return Scaffold(
      appBar: AuraAppBar(title: _patientData!['name'] ?? "Unknown Patient"),
      body: RefreshIndicator(
        onRefresh: _loadData,
        child: NestedScrollView(
          physics: const AlwaysScrollableScrollPhysics(), 
          headerSliverBuilder: (context, _) => [
             SliverToBoxAdapter(
               child: _buildHeader(status, statusColor),
             ),
             SliverPersistentHeader(
               pinned: true,
               delegate: _SliverAppBarDelegate(
                 TabBar(
                   controller: _tabController,
                   labelColor: AppColors.primary,
                   unselectedLabelColor: AppColors.textSecondary,
                   indicatorColor: AppColors.primary,
                   tabs: const [
                     Tab(text: "Overview"),
                     Tab(text: "Meds"),
                     Tab(text: "History"),
                   ],
                 ),
               ),
             ),
          ],
          body: TabBarView(
            controller: _tabController,
            children: [
              _buildOverviewTab(isAdmitted),
              _buildMedsTab(),
              _buildHistoryTab(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeader(String status, Color color) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            AppColors.surface,
            AppColors.background,
          ],
        ),
        border: const Border(bottom: BorderSide(color: AppColors.surfaceHighlight, width: 1)),
      ),
      child: Column(
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(3),
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: LinearGradient(
                    colors: [AppColors.primary, AppColors.primaryLight],
                  ),
                ),
                child: CircleAvatar(
                  radius: 32,
                  backgroundColor: AppColors.surface,
                  child: const Icon(CupertinoIcons.person_fill, size: 32, color: AppColors.primary),
                ),
              ),
              const SizedBox(width: 20),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(_patientData!['name'] ?? "Err", style: AppTypography.headlineMedium),
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        _buildBadge(status, color),
                        const SizedBox(width: 12),
                        Text("ID: #${widget.patientId}", style: AppTypography.bodyMedium),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _buildStatItem("Age", "42"), // Mock
              _buildStatItem("Weight", "78 kg"),
              _buildStatItem("Blood", "O+"),
              _buildStatItem("Ward", "General"),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildStatItem(String label, String value) {
    return Column(
      children: [
        Text(
          value, 
          style: AppTypography.titleLarge.copyWith(
            fontWeight: FontWeight.bold,
            fontSize: 20,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          label, 
          style: AppTypography.bodySmall.copyWith(
            color: AppColors.textSecondary,
            fontSize: 12,
          ),
        ),
      ],
    );
  }

  Widget _buildBadge(String text, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color),
      ),
      child: Text(text, style: AppTypography.labelSmall.copyWith(color: color, fontWeight: FontWeight.bold)),
    );
  }

  // --- TABS ---

  Widget _buildOverviewTab(bool showLiveVitals) {
    if (!showLiveVitals) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(CupertinoIcons.bed_double_fill, size: 64, color: AppColors.textSecondary.withOpacity(0.5)),
            const SizedBox(height: 16),
            Text("Patient Not Admitted", style: AppTypography.titleLarge.copyWith(color: AppColors.textSecondary)),
            const SizedBox(height: 8),
            Text("Live vitals monitoring is inactive.", style: AppTypography.bodyMedium),
          ],
        ),
      );
    }

    // Extract real pain data
    final painLevel = _patientData?['current_state']?['pain_level'];
    final painTime = _patientData?['current_state']?['pain_reported_at'];
    
    // If pain level is null or 0, we can assume no pain reported or resolved
    final hasPain = painLevel != null && painLevel > 0;

    return ListView(
      padding: const EdgeInsets.all(20),
      children: [
        // Real Pain Alert
        if (hasPain)
          Container(
            margin: const EdgeInsets.only(bottom: 20),
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
               color: AppColors.error.withOpacity(0.1),
               borderRadius: BorderRadius.circular(16),
               border: Border.all(color: AppColors.error),
            ),
            child: Row(
              children: [
                 const Icon(CupertinoIcons.exclamationmark_triangle_fill, color: AppColors.error),
                 const SizedBox(width: 16),
                 Expanded(
                   child: Column(
                     crossAxisAlignment: CrossAxisAlignment.start,
                     children: [
                       Text("Patient Reported Pain", style: AppTypography.titleMedium.copyWith(color: AppColors.error)),
                       const SizedBox(height: 4),
                       Row(
                         children: [
                           Text("Severity: ", style: AppTypography.bodyMedium),
                           Text("$painLevel/10", style: AppTypography.titleMedium.copyWith(color: AppColors.error, fontWeight: FontWeight.bold)),
                         ],
                       ),
                       if (painTime != null)
                        Text("Timestamp: $painTime", style: AppTypography.bodySmall),
                     ],
                   ),
                 ),
                 TextButton(
                   onPressed: () {
                     // Could implement 'Resolve' logic here to set pain to 0
                   },
                   child: Text("Ack", style: AppTypography.labelLarge.copyWith(color: AppColors.error)),
                 )
              ],
            ),
          )
        else
           Container(
             margin: const EdgeInsets.only(bottom: 20),
             padding: const EdgeInsets.all(16),
             decoration: BoxDecoration(
               color: AppColors.success.withOpacity(0.1),
               borderRadius: BorderRadius.circular(16),
               border: Border.all(color: AppColors.success),
             ),
             child: Row(
               children: [
                 const Icon(CupertinoIcons.checkmark_shield_fill, color: AppColors.success),
                 const SizedBox(width: 16),
                 Text("No active pain reported.", style: AppTypography.bodyMedium.copyWith(color: AppColors.success)),
               ],
             ),
           ),

        Text("Current Symptoms", style: AppTypography.titleMedium),
        const SizedBox(height: 12),
        Wrap(
          spacing: 8,
          children: _symptoms.map((s) => Chip(
            label: Text(s), 
            backgroundColor: AppColors.surfaceHighlight, 
            labelStyle: AppTypography.bodySmall
          )).toList(),
        ),
        const SizedBox(height: 24),
        
        Text("Live Vitals Monitor", style: AppTypography.titleMedium.copyWith(color: AppColors.error)),
        const SizedBox(height: 16),

        // LIVE HEART RATE
        StreamBuilder<int>(
          initialData: (_patientData?['current_state']?['heart_rate'] as num?)?.toInt(),
          stream: SocketService().vitalsStream.map((d) => d['hr'] as int? ?? 0).distinct(),
          builder: (context, snap) {
              final val = (snap.data != null && snap.data! > 0) ? snap.data.toString() : "--";
              return VitalsCard(
                title: "Heart Rate",
                value: val,
                unit: "bpm",
                icon: CupertinoIcons.heart_fill,
                color: AppColors.success,
                graph: SizedBox(
                   height: 120,
                   child: HeartRateGraph(
                     color: AppColors.success,
                     waveStream: SocketService().vitalsStream.map((d) => (d['ecg'] as num?)?.toDouble() ?? 0.0),
                   ),
                ),
              );
          },
        ),

        // LIVE BLOOD PRESSURE
        StreamBuilder<String>(
          initialData: () {
             final raw = _patientData?['current_state']?['blood_pressure'];
             if (raw is Map) {
               return raw['value']?.toString() ?? raw.toString(); 
             }
             return raw?.toString();
          }(),
          stream: SocketService().vitalsStream.map((d) => d['bp'] as String? ?? "--/--").distinct(),
          builder: (context, snap) {
              final val = snap.data ?? "--/--";
              return VitalsCard(
                title: "Blood Pressure",
                value: val,
                unit: "mmHg",
                icon: CupertinoIcons.heart_circle_fill,
                color: AppColors.warning,
                graph: SizedBox(
                   height: 120,
                   child: BloodPressureGraph(
                     color: AppColors.warning,
                   ),
                ),
              );
          },
        ),

        // LIVE SpO2
        StreamBuilder<int>(
          initialData: (_patientData?['current_state']?['spo2'] as num?)?.toInt(),
          stream: SocketService().vitalsStream.map((d) => (d['spo2'] as num?)?.toInt() ?? 0).distinct(),
          builder: (context, snap) {
              final val = (snap.data != null && snap.data! > 0) ? snap.data.toString() : "--";
              return VitalsCard(
                title: "Oxygen Saturation",
                value: val,
                unit: "%",
                icon: CupertinoIcons.drop_fill,
                color: AppColors.info,
                graph: SizedBox(
                   height: 120,
                   child: OxygenGraph(
                     color: AppColors.info,
                     waveStream: SocketService().vitalsStream.map((d) => (d['spo2_wave'] as num?)?.toDouble() ?? 0.0),
                   ),
                ),
              );
          },
        ),
      ],
    );
  }

  Widget _buildMedsTab() {
    if (_medications.isEmpty) {
      return Center(child: Text("No active medications.", style: AppTypography.bodyMedium));
    }
    return ListView.builder(
      padding: const EdgeInsets.all(20),
      itemCount: _medications.length,
      itemBuilder: (context, index) {
        final med = _medications[index];
        return Card(
          child: ListTile(
            leading: CircleAvatar(backgroundColor: AppColors.primary.withOpacity(0.1), child: const Icon(CupertinoIcons.capsule_fill, color: AppColors.primary)),
            title: Text(med['name'] ?? "Medication", style: AppTypography.titleMedium),
            subtitle: Text(med['dosage'] ?? "1 pill daily", style: AppTypography.bodyMedium),
          ),
        );
      },
    );
  }

  Widget _buildHistoryTab() {
    return ListView.builder(
      padding: const EdgeInsets.all(20),
      itemCount: _history.length,
      itemBuilder: (context, index) {
        final item = _history[index];
        return Padding(
          padding: const EdgeInsets.only(bottom: 16),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Column(
                children: [
                  Container(
                    width: 12, height: 12,
                    decoration: const BoxDecoration(color: AppColors.accent, shape: BoxShape.circle),
                  ),
                  Container(width: 2, height: 60, color: AppColors.surfaceHighlight),
                ],
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(item['date']!, style: AppTypography.labelSmall),
                    const SizedBox(height: 4),
                    Text(item['type']!, style: AppTypography.titleSmall),
                    Text(item['note']!, style: AppTypography.bodyMedium),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

class _SliverAppBarDelegate extends SliverPersistentHeaderDelegate {
  final TabBar _tabBar;
  _SliverAppBarDelegate(this._tabBar);

  @override
  double get minExtent => _tabBar.preferredSize.height + 16;
  @override
  double get maxExtent => _tabBar.preferredSize.height + 16;

  @override
  Widget build(BuildContext context, double shrinkOffset, bool overlapsContent) {
    return Container(
      color: AppColors.background,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Container(
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(12),
        ),
        child: _tabBar,
      )
    );
  }

  @override
  bool shouldRebuild(_SliverAppBarDelegate oldDelegate) => false;
}
