import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';

class ProfileView extends StatefulWidget {
  const ProfileView({super.key});

  @override
  State<ProfileView> createState() => _ProfileViewState();
}

class _ProfileViewState extends State<ProfileView> {
  // 사용자의 현재 닉네임 (기본값은 이메일 앞부분)
  String _nickname = "";
  final user = FirebaseAuth.instance.currentUser;

  @override
  void initState() {
    super.initState();
    // 초기 닉네임을 이메일 아이디로 설정
    _nickname = user?.email?.split('@')[0] ?? "우주 여행자";
  }

  // 닉네임 수정 다이얼로그 띄우기
  void _editNickname() {
    final TextEditingController controller = TextEditingController(
      text: _nickname,
    );

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text(
          "닉네임 수정",
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        content: TextField(
          controller: controller,
          autofocus: true,
          decoration: const InputDecoration(
            hintText: "새 닉네임을 입력하세요",
            focusedBorder: UnderlineInputBorder(
              borderSide: BorderSide(color: Color(0xFFC084FC)),
            ),
          ),
          maxLength: 10, // 닉네임 길이 제한
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("취소", style: TextStyle(color: Colors.grey)),
          ),
          ElevatedButton(
            onPressed: () {
              if (controller.text.trim().isNotEmpty) {
                setState(() {
                  _nickname = controller.text.trim();
                });
                Navigator.pop(context);
                ScaffoldMessenger.of(
                  context,
                ).showSnackBar(const SnackBar(content: Text("닉네임이 변경되었습니다.")));
              }
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFFC084FC),
              foregroundColor: Colors.white,
            ),
            child: const Text("저장"),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          const SizedBox(height: 20),
          // 🛸 프로필 이미지 영역
          _buildProfileImage(),
          const SizedBox(height: 24),

          // 닉네임 표시 및 수정 버튼
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const SizedBox(width: 40), // 아이콘과 균형을 맞추기 위한 빈 공간
              Text(
                _nickname,
                style: const TextStyle(
                  fontSize: 26,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF030213),
                ),
              ),
              IconButton(
                onPressed: _editNickname,
                icon: const Icon(Icons.edit, size: 20, color: Colors.grey),
                padding: const EdgeInsets.only(left: 8),
                constraints: const BoxConstraints(),
              ),
            ],
          ),

          const SizedBox(height: 8),
          _buildLevelBadge(),

          const SizedBox(height: 32),

          // 📊 활동 통계 카드
          Row(
            children: [
              _buildStatCard(
                icon: Icons.timer,
                color: Colors.blue,
                label: "총 집중 시간",
                value: "0.0시간",
              ),
              const SizedBox(width: 16),
              _buildStatCard(
                icon: Icons.check_circle,
                color: Colors.green,
                label: "완료한 일",
                value: "0개",
              ),
            ],
          ),

          const SizedBox(height: 24),
          _buildExperienceBar(),
        ],
      ),
    );
  }

  // --- UI 컴포넌트들 ---

  Widget _buildProfileImage() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: const Color(0xFFC084FC).withOpacity(0.2),
            blurRadius: 20,
            spreadRadius: 5,
          ),
        ],
      ),
      child: Image.asset(
        'assets/icon/profile.png',
        width: 80,
        height: 80,
        fit: BoxFit.contain,
      ),
    );
  }

  Widget _buildLevelBadge() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: const Color(0xFFC084FC).withOpacity(0.1),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: const Color(0xFFC084FC)),
      ),
      child: const Text(
        "Lv.1 지구 정복 꿈나무",
        style: TextStyle(color: Color(0xFFC084FC), fontWeight: FontWeight.bold),
      ),
    );
  }

  Widget _buildExperienceBar() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text("다음 레벨까지", style: TextStyle(fontWeight: FontWeight.bold)),
              Text("0 / 100 XP", style: TextStyle(color: Colors.grey)),
            ],
          ),
          const SizedBox(height: 10),
          ClipRRect(
            borderRadius: BorderRadius.circular(10),
            child: LinearProgressIndicator(
              value: 0.05,
              minHeight: 10,
              backgroundColor: Colors.grey[100],
              color: const Color(0xFFC084FC),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatCard({
    required IconData icon,
    required Color color,
    required String label,
    required String value,
  }) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          children: [
            Icon(icon, color: color, size: 32),
            const SizedBox(height: 8),
            Text(
              value,
              style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 4),
            Text(
              label,
              style: TextStyle(fontSize: 12, color: Colors.grey[600]),
            ),
          ],
        ),
      ),
    );
  }
}
