import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:scout_os_app/design_system/tokens/colors.dart';
import 'package:scout_os_app/design_system/tokens/typography.dart';
import 'mission_preview_page.dart';

class AcademyDomain {
  final String id;
  final String title;
  final IconData icon;
  final List<SpecializationRole> specializations;

  AcademyDomain({
    required this.id,
    required this.title,
    required this.icon,
    required this.specializations,
  });
}

class SpecializationRole {
  final String id;
  final String title;
  final List<String> packFiles;

  SpecializationRole({
    required this.id,
    required this.title,
    required this.packFiles,
  });
}

class ExplorePage extends ConsumerStatefulWidget {
  const ExplorePage({super.key});

  @override
  ConsumerState<ExplorePage> createState() => _ExplorePageState();
}

class _ExplorePageState extends ConsumerState<ExplorePage> {
  String _searchQuery = "";

  final List<AcademyDomain> _registryData = [
    AcademyDomain(
      id: "ai",
      title: "Artificial Intelligence Academy",
      icon: Icons.psychology_outlined,
      specializations: [
        SpecializationRole(
          id: "ml_eng",
          title: "Machine Learning Engineer",
          packFiles: [
            "Python Fundamentals.pack",
            "NumPy.pack",
            "Pandas.pack",
            "Statistics.pack",
            "Linear Algebra.pack",
            "Calculus.pack",
            "Data Visualization.pack",
            "Scikit Learn.pack",
            "Regression.pack",
            "Classification.pack",
            "Clustering.pack",
            "Feature Engineering.pack",
            "Model Evaluation.pack",
            "ML Deployment.pack",
            "Capstone.pack"
          ],
        ),
        SpecializationRole(
          id: "dl_eng",
          title: "Deep Learning Engineer",
          packFiles: ["PyTorch.pack", "TensorFlow.pack", "Neural Networks.pack", "CNN.pack", "Transformer.pack", "Capstone.pack"],
        ),
        SpecializationRole(
          id: "cv_eng",
          title: "Computer Vision Engineer",
          packFiles: ["OpenCV.pack", "Object Detection.pack", "YOLO.pack", "Image Segmentation.pack", "Capstone.pack"],
        ),
        SpecializationRole(
          id: "nlp_eng",
          title: "NLP Engineer",
          packFiles: ["Tokenization.pack", "BERT.pack", "Embeddings.pack", "RAG Pipeline.pack", "Capstone.pack"],
        ),
        SpecializationRole(
          id: "llm_eng",
          title: "LLM Engineer",
          packFiles: ["Fine-tuning.pack", "LoRA.pack", "LangChain.pack", "Vector DB.pack", "Prompt Architecture.pack", "Capstone.pack"],
        ),
        SpecializationRole(
          id: "mlops_eng",
          title: "MLOps Engineer",
          packFiles: ["MLflow.pack", "Kubeflow.pack", "Model Monitoring.pack", "Feature Store.pack", "Capstone.pack"],
        ),
      ],
    ),
    AcademyDomain(
      id: "cyber",
      title: "Cyber Security Academy",
      icon: Icons.security_outlined,
      specializations: [
        SpecializationRole(
          id: "pentest",
          title: "Penetration Tester",
          packFiles: [
            "Linux.pack",
            "Networking.pack",
            "Bash.pack",
            "Python.pack",
            "Web Security.pack",
            "SQL Injection.pack",
            "XSS.pack",
            "Authentication.pack",
            "Burp Suite.pack",
            "Active Directory.pack",
            "Privilege Escalation.pack",
            "CTF.pack",
            "Capstone.pack"
          ],
        ),
        SpecializationRole(
          id: "soc",
          title: "SOC Analyst",
          packFiles: ["Syslog.pack", "Wireshark.pack", "SIEM.pack", "Splunk.pack", "Incident Analysis.pack", "Capstone.pack"],
        ),
        SpecializationRole(
          id: "malware",
          title: "Malware Analyst",
          packFiles: ["Assembly x86.pack", "Ghidra.pack", "Dynamic Sandbox.pack", "PE Header.pack", "Capstone.pack"],
        ),
        SpecializationRole(
          id: "red_team",
          title: "Red Team Operator",
          packFiles: ["C2 Infrastructure.pack", "Phishing Architecture.pack", "Evasion.pack", "Capstone.pack"],
        ),
      ],
    ),
    AcademyDomain(
      id: "software_eng",
      title: "Software Engineering Academy",
      icon: Icons.code_outlined,
      specializations: [
        SpecializationRole(
          id: "backend",
          title: "Backend Engineer",
          packFiles: [
            "HTTP.pack",
            "REST.pack",
            "Go.pack",
            "PostgreSQL.pack",
            "Authentication.pack",
            "Authorization.pack",
            "Caching.pack",
            "Message Queue.pack",
            "Docker.pack",
            "Testing.pack",
            "Clean Architecture.pack",
            "Capstone.pack"
          ],
        ),
        SpecializationRole(
          id: "frontend",
          title: "Frontend Engineer",
          packFiles: ["HTML_CSS.pack", "TypeScript.pack", "React.pack", "State Management.pack", "Performance.pack", "Capstone.pack"],
        ),
        SpecializationRole(
          id: "fullstack",
          title: "Fullstack Engineer",
          packFiles: ["NodeJS.pack", "NextJS.pack", "Database Indexing.pack", "GraphQL.pack", "CI_CD.pack", "Capstone.pack"],
        ),
      ],
    ),
    AcademyDomain(
      id: "mobile_eng",
      title: "Mobile Engineering Academy",
      icon: Icons.phone_iphone_outlined,
      specializations: [
        SpecializationRole(
          id: "flutter",
          title: "Flutter Engineer",
          packFiles: [
            "Dart.pack",
            "Widget.pack",
            "State Management.pack",
            "Riverpod.pack",
            "Animation.pack",
            "Local Database.pack",
            "REST API.pack",
            "Clean Architecture.pack",
            "Firebase.pack",
            "Capstone.pack"
          ],
        ),
        SpecializationRole(
          id: "android",
          title: "Android Native Engineer",
          packFiles: ["Kotlin.pack", "Jetpack Compose.pack", "Coroutines.pack", "Hilt.pack", "Room.pack", "Capstone.pack"],
        ),
        SpecializationRole(
          id: "ios",
          title: "iOS Native Engineer",
          packFiles: ["Swift.pack", "SwiftUI.pack", "Combine.pack", "CoreData.pack", "Capstone.pack"],
        ),
      ],
    ),
    AcademyDomain(
      id: "startup",
      title: "Startup Academy",
      icon: Icons.rocket_launch_outlined,
      specializations: [
        SpecializationRole(
          id: "founder",
          title: "Startup Founder",
          packFiles: [
            "Idea Validation.pack",
            "Customer Discovery.pack",
            "MVP.pack",
            "Product Market Fit.pack",
            "Metrics.pack",
            "Pricing.pack",
            "Fundraising.pack",
            "Hiring.pack",
            "Pitch Deck.pack",
            "Demo Day.pack"
          ],
        ),
        SpecializationRole(
          id: "pm",
          title: "Product Manager",
          packFiles: ["PRD Writing.pack", "User Research.pack", "Wireframing.pack", "Roadmapping.pack", "A_B Testing.pack"],
        ),
      ],
    ),
    AcademyDomain(
      id: "data_science",
      title: "Data Science Academy",
      icon: Icons.insights_outlined,
      specializations: [
        SpecializationRole(
          id: "data_analyst",
          title: "Data Analyst",
          packFiles: ["SQL Mastery.pack", "Excel Advanced.pack", "Tableau.pack", "PowerBI.pack", "Data Storytelling.pack"],
        ),
        SpecializationRole(
          id: "data_engineer",
          title: "Data Engineer",
          packFiles: ["Spark.pack", "Airflow.pack", "Data Warehouse.pack", "Snowflake.pack", "Kafka.pack"],
        ),
      ],
    ),
    AcademyDomain(
      id: "devops",
      title: "DevOps & Cloud Engineering",
      icon: Icons.cloud_queue_outlined,
      specializations: [
        SpecializationRole(
          id: "devops_engineer",
          title: "DevOps Engineer",
          packFiles: ["Linux Administration.pack", "Docker Containerization.pack", "Kubernetes.pack", "Terraform.pack", "Ansible.pack", "GitHub Actions.pack"],
        ),
        SpecializationRole(
          id: "cloud_architect",
          title: "Cloud Architect",
          packFiles: ["AWS Core.pack", "GCP Fundamentals.pack", "High Availability.pack", "Cloud Cost Optimization.pack"],
        ),
      ],
    ),
    AcademyDomain(
      id: "design",
      title: "UI/UX & Design Academy",
      icon: Icons.palette_outlined,
      specializations: [
        SpecializationRole(
          id: "ui_designer",
          title: "UI/UX Designer",
          packFiles: ["Design System.pack", "Figma Advanced.pack", "User Testing.pack", "Micro Interaction.pack", "Accessibility.pack"],
        ),
      ],
    ),
    AcademyDomain(
      id: "cs_math",
      title: "Computer Science & Mathematics",
      icon: Icons.calculate_outlined,
      specializations: [
        SpecializationRole(
          id: "cs_foundation",
          title: "Computer Science Fundamentals",
          packFiles: ["Data Structures.pack", "Algorithms.pack", "Operating Systems.pack", "Database Systems.pack", "Networking.pack"],
        ),
        SpecializationRole(
          id: "math_foundation",
          title: "Applied Mathematics",
          packFiles: ["Calculus.pack", "Linear Algebra.pack", "Probability.pack", "Discrete Math.pack", "Optimization.pack"],
        ),
      ],
    ),
  ];

  @override
  Widget build(BuildContext context) {
    final filteredDomains = _registryData.where((domain) {
      if (_searchQuery.isEmpty) return true;
      final q = _searchQuery.toLowerCase();
      if (domain.title.toLowerCase().contains(q)) return true;
      for (var spec in domain.specializations) {
        if (spec.title.toLowerCase().contains(q)) return true;
        for (var pack in spec.packFiles) {
          if (pack.toLowerCase().contains(q)) return true;
        }
      }
      return false;
    }).toList();

    return Container(
      color: PradigiColors.surface,
      padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 32.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          LayoutBuilder(
            builder: (context, constraints) {
              final isMobile = constraints.maxWidth < 600;

              final titleColumn = Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text("Explore Registry", style: PradigiTypography.h1),
                  const SizedBox(height: 4),
                  Text(
                    "Pradigi OS Registry: Academies, Specializations, & Executable Blueprint Packs.",
                    style: PradigiTypography.bodySecondary,
                  ),
                ],
              );

              final countPill = Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: PradigiColors.background,
                  borderRadius: BorderRadius.circular(6),
                  border: Border.all(color: PradigiColors.border),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(Icons.folder_special_outlined, size: 14, color: PradigiColors.textPrimary),
                    const SizedBox(width: 6),
                    Text(
                      "${_registryData.length} Domains Registered",
                      style: PradigiTypography.caption.copyWith(fontWeight: FontWeight.bold, fontSize: 11),
                    ),
                  ],
                ),
              );

              if (isMobile) {
                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    titleColumn,
                    const SizedBox(height: 12),
                    countPill,
                  ],
                );
              }

              return Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(child: titleColumn),
                  const SizedBox(width: 16),
                  countPill,
                ],
              );
            },
          ),

          const SizedBox(height: 24),

          // Search Registry Bar
          Container(
            decoration: BoxDecoration(
              color: PradigiColors.background,
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: PradigiColors.border),
            ),
            child: TextField(
              onChanged: (val) {
                setState(() {
                  _searchQuery = val;
                });
              },
              decoration: const InputDecoration(
                hintText: "Search OS Registry (e.g. Python, Penetration Tester, Go.pack, Riverpod.pack)...",
                prefixIcon: Icon(Icons.search, color: PradigiColors.textSecondary, size: 20),
                border: InputBorder.none,
                contentPadding: EdgeInsets.symmetric(vertical: 14, horizontal: 16),
              ),
              style: PradigiTypography.body,
            ),
          ),

          const SizedBox(height: 24),
          const Divider(color: PradigiColors.border),
          const SizedBox(height: 16),

          // Registry List
          Expanded(
            child: filteredDomains.isEmpty
                ? Center(
                    child: Text(
                      "No matching registry blueprints found.",
                      style: PradigiTypography.bodySecondary,
                    ),
                  )
                : ListView.builder(
                    itemCount: filteredDomains.length,
                    itemBuilder: (context, index) {
                      final domain = filteredDomains[index];
                      return _buildAcademyDomainNode(domain);
                    },
                  ),
          ),
        ],
      ),
    );
  }

  Widget _buildAcademyDomainNode(AcademyDomain domain) {
    return Container(
      margin: const EdgeInsets.only(bottom: 14),
      decoration: BoxDecoration(
        color: PradigiColors.surface,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: PradigiColors.border),
      ),
      child: Theme(
        data: Theme.of(context).copyWith(dividerColor: Colors.transparent),
        child: ExpansionTile(
          initiallyExpanded: _searchQuery.isNotEmpty,
          leading: Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: PradigiColors.background,
              shape: BoxShape.circle,
              border: Border.all(color: PradigiColors.border),
            ),
            child: Icon(domain.icon, color: PradigiColors.textPrimary, size: 20),
          ),
          title: Text(
            domain.title,
            style: PradigiTypography.body.copyWith(fontWeight: FontWeight.bold, fontSize: 16),
          ),
          subtitle: Text(
            "${domain.specializations.length} Specializations / Roles",
            style: PradigiTypography.caption,
          ),
          children: domain.specializations.map((spec) => _buildSpecializationNode(domain, spec)).toList(),
        ),
      ),
    );
  }

  Widget _buildSpecializationNode(AcademyDomain domain, SpecializationRole spec) {
    return Container(
      margin: const EdgeInsets.only(left: 16, right: 16, bottom: 12),
      decoration: BoxDecoration(
        color: PradigiColors.background,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: PradigiColors.border.withOpacity(0.7)),
      ),
      child: Theme(
        data: Theme.of(context).copyWith(dividerColor: Colors.transparent),
        child: ExpansionTile(
          initiallyExpanded: _searchQuery.isNotEmpty,
          leading: const Icon(Icons.badge_outlined, color: PradigiColors.textPrimary, size: 18),
          title: Text(
            spec.title,
            style: PradigiTypography.body.copyWith(fontWeight: FontWeight.w600, fontSize: 14),
          ),
          subtitle: Text(
            "${spec.packFiles.length} Executable Blueprint Packs",
            style: PradigiTypography.caption.copyWith(fontSize: 12),
          ),
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 0, 16, 12),
              child: Wrap(
                spacing: 8,
                runSpacing: 8,
                children: spec.packFiles.map((packName) => _buildPackChip(domain, spec, packName)).toList(),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPackChip(AcademyDomain domain, SpecializationRole spec, String packName) {
    return InkWell(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => MissionPreviewPage(
              academyId: domain.id,
              academyTitle: domain.title,
              specializationId: spec.id,
              specializationTitle: "${spec.title} ($packName)",
            ),
          ),
        );
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
        decoration: BoxDecoration(
          color: PradigiColors.surface,
          borderRadius: BorderRadius.circular(6),
          border: Border.all(color: PradigiColors.textPrimary.withOpacity(0.25)),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 5,
              height: 5,
              decoration: const BoxDecoration(
                color: PradigiColors.textPrimary,
                shape: BoxShape.circle,
              ),
            ),
            const SizedBox(width: 6),
            Text(
              packName,
              style: const TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.bold,
                fontFamily: 'JetBrains Mono',
                color: PradigiColors.textPrimary,
              ),
            ),
            const SizedBox(width: 4),
            const Icon(Icons.arrow_forward_ios, size: 10, color: PradigiColors.textSecondary),
          ],
        ),
      ),
    );
  }
}
