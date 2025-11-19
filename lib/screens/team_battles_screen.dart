import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../models/social_model.dart';
import '../providers/social_provider.dart';
import '../utils/app_colors.dart';

class TeamBattlesScreen extends StatelessWidget {
  const TeamBattlesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final socialProvider = context.watch<SocialProvider>();
    final currentTeam = socialProvider.currentUserTeam;
    final teams = socialProvider.teams;
    final activeBattles = socialProvider.activeTeamBattles;

    return Scaffold(
      backgroundColor: AppColors.backgroundDark,
      appBar: AppBar(
        backgroundColor: AppColors.backgroundCard,
        title: const Text(
          'TEAM BATTLES',
          style: TextStyle(
            fontFamily: 'Bebas Neue',
            fontSize: 24,
            letterSpacing: 2,
            color: Colors.white,
          ),
        ),
        centerTitle: true,
      ),
      body: currentTeam == null
          ? _buildNoTeamView(context, socialProvider)
          : _buildTeamView(context, currentTeam, teams, activeBattles, socialProvider),
    );
  }

  Widget _buildNoTeamView(BuildContext context, SocialProvider socialProvider) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(32),
              decoration: BoxDecoration(
                color: AppColors.primaryRed.withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.groups,
                size: 80,
                color: AppColors.primaryRed,
              ),
            ),
            const SizedBox(height: 24),
            const Text(
              'Join the Battle!',
              style: TextStyle(
                fontFamily: 'Bebas Neue',
                fontSize: 28,
                color: Colors.white,
                letterSpacing: 1.5,
              ),
            ),
            const SizedBox(height: 12),
            Text(
              'Create or join a team to compete in epic fitness battles',
              textAlign: TextAlign.center,
              style: TextStyle(
                color: AppColors.textGray,
                fontSize: 14,
              ),
            ),
            const SizedBox(height: 32),
            ElevatedButton.icon(
              onPressed: () => _showCreateTeamDialog(context, socialProvider),
              icon: const Icon(Icons.add),
              label: const Text('CREATE TEAM'),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primaryRed,
                padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
            const SizedBox(height: 16),
            TextButton(
              onPressed: () {
                // TODO: Show available teams to join
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('Browse teams feature coming soon!')),
                );
              },
              child: const Text(
                'Browse Teams',
                style: TextStyle(color: AppColors.primaryRed),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTeamView(BuildContext context, Team currentTeam, List<Team> allTeams,
      List<TeamBattle> activeBattles, SocialProvider socialProvider) {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        // Current Team Card
        _buildCurrentTeamCard(currentTeam),
        const SizedBox(height: 24),

        // Active Battles Section
        if (activeBattles.isNotEmpty) ...[
          const Text(
            'ACTIVE BATTLES',
            style: TextStyle(
              fontFamily: 'Bebas Neue',
              fontSize: 20,
              color: Colors.white,
              letterSpacing: 1.5,
            ),
          ),
          const SizedBox(height: 12),
          ...activeBattles.map((battle) => _buildBattleCard(battle)),
          const SizedBox(height: 24),
        ],

        // Available Teams Section
        const Text(
          'CHALLENGE OTHER TEAMS',
          style: TextStyle(
            fontFamily: 'Bebas Neue',
            fontSize: 20,
            color: Colors.white,
            letterSpacing: 1.5,
          ),
        ),
        const SizedBox(height: 12),
        ...allTeams
            .where((team) => team.id != currentTeam.id)
            .map((team) => _buildTeamChallengeCard(context, team, socialProvider)),
      ],
    );
  }

  Widget _buildCurrentTeamCard(Team team) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            AppColors.primaryRed.withOpacity(0.3),
            AppColors.primaryRedDark.withOpacity(0.1),
          ],
        ),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.primaryRed, width: 2),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: AppColors.primaryRed,
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.shield,
                  color: Colors.white,
                  size: 32,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      team.name,
                      style: const TextStyle(
                        fontFamily: 'Bebas Neue',
                        fontSize: 24,
                        color: Colors.white,
                        letterSpacing: 1.2,
                      ),
                    ),
                    Text(
                      'Captain: ${team.members.firstWhere((m) => m.userId == team.captainId, orElse: () => team.members.first).userName}',
                      style: TextStyle(
                        color: AppColors.textGray,
                        fontSize: 13,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          Row(
            children: [
              Expanded(
                child: _buildTeamStat('MEMBERS', '${team.members.length}', Icons.people),
              ),
              Expanded(
                child: _buildTeamStat('TOTAL XP', '${team.totalXP}', Icons.stars),
              ),
              Expanded(
                child: _buildTeamStat('WORKOUTS', '${team.totalWorkouts}', Icons.fitness_center),
              ),
            ],
          ),
          const SizedBox(height: 16),
          const Divider(color: Colors.white24),
          const SizedBox(height: 12),
          const Text(
            'TEAM MEMBERS',
            style: TextStyle(
              fontFamily: 'Bebas Neue',
              fontSize: 14,
              color: Colors.white,
              letterSpacing: 1.2,
            ),
          ),
          const SizedBox(height: 8),
          ...team.members.map((member) => Padding(
                padding: const EdgeInsets.symmetric(vertical: 4),
                child: Row(
                  children: [
                    CircleAvatar(
                      radius: 16,
                      backgroundColor: AppColors.primaryRed,
                      child: Text(
                        member.userName[0].toUpperCase(),
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        member.userName,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 14,
                        ),
                      ),
                    ),
                    Text(
                      '${member.contributedXP} XP',
                      style: const TextStyle(
                        color: Colors.amber,
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              )),
        ],
      ),
    );
  }

  Widget _buildTeamStat(String label, String value, IconData icon) {
    return Column(
      children: [
        Icon(icon, color: AppColors.primaryRed, size: 24),
        const SizedBox(height: 4),
        Text(
          value,
          style: const TextStyle(
            fontFamily: 'Bebas Neue',
            fontSize: 22,
            color: Colors.white,
          ),
        ),
        Text(
          label,
          style: TextStyle(
            color: AppColors.textGray,
            fontSize: 11,
          ),
        ),
      ],
    );
  }

  Widget _buildBattleCard(TeamBattle battle) {
    final daysRemaining = battle.endDate.difference(DateTime.now()).inDays;
    final progress = battle.team1Score / (battle.team1Score + battle.team2Score + 1);
    final isTeam1Winning = battle.team1Score > battle.team2Score;

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.backgroundCard,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: battle.isActive ? AppColors.primaryRed : Colors.green,
          width: 2,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                battle.isActive ? 'ONGOING BATTLE' : 'BATTLE ENDED',
                style: TextStyle(
                  color: battle.isActive ? AppColors.primaryRed : Colors.green,
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 1.2,
                ),
              ),
              if (battle.isActive)
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: AppColors.primaryRed.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    '$daysRemaining days left',
                    style: const TextStyle(
                      color: AppColors.primaryRed,
                      fontSize: 11,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(
                          Icons.shield,
                          color: isTeam1Winning ? AppColors.primaryRed : AppColors.textGray,
                          size: 20,
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            battle.team1Name,
                            style: TextStyle(
                              color: isTeam1Winning ? Colors.white : AppColors.textGray,
                              fontSize: 16,
                              fontWeight: isTeam1Winning ? FontWeight.bold : FontWeight.normal,
                            ),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '${battle.team1Score} XP',
                      style: const TextStyle(
                        color: Colors.amber,
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
              const Padding(
                padding: EdgeInsets.symmetric(horizontal: 16),
                child: Text(
                  'VS',
                  style: TextStyle(
                    fontFamily: 'Bebas Neue',
                    fontSize: 20,
                    color: Colors.white,
                  ),
                ),
              ),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        Expanded(
                          child: Text(
                            battle.team2Name,
                            style: TextStyle(
                              color: !isTeam1Winning ? Colors.white : AppColors.textGray,
                              fontSize: 16,
                              fontWeight: !isTeam1Winning ? FontWeight.bold : FontWeight.normal,
                            ),
                            overflow: TextOverflow.ellipsis,
                            textAlign: TextAlign.right,
                          ),
                        ),
                        const SizedBox(width: 8),
                        Icon(
                          Icons.shield,
                          color: !isTeam1Winning ? AppColors.primaryRed : AppColors.textGray,
                          size: 20,
                        ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '${battle.team2Score} XP',
                      style: const TextStyle(
                        color: Colors.amber,
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: LinearProgressIndicator(
              value: progress,
              backgroundColor: Colors.blue.shade700,
              valueColor: const AlwaysStoppedAnimation<Color>(AppColors.primaryRed),
              minHeight: 10,
            ),
          ),
          if (!battle.isActive && battle.winnerId != null) ...[
            const SizedBox(height: 12),
            Center(
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                decoration: BoxDecoration(
                  color: Colors.green.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: Colors.green, width: 2),
                ),
                child: Text(
                  'WINNER: ${battle.winnerId == battle.team1Id ? battle.team1Name : battle.team2Name}',
                  style: const TextStyle(
                    color: Colors.green,
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 1.2,
                  ),
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildTeamChallengeCard(
      BuildContext context, Team team, SocialProvider socialProvider) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.backgroundCard,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.white24, width: 1),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.blue.withOpacity(0.2),
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.shield,
              color: Colors.blue,
              size: 24,
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  team.name,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 4),
                Row(
                  children: [
                    Icon(Icons.people, size: 14, color: AppColors.textGray),
                    const SizedBox(width: 4),
                    Text(
                      '${team.members.length} members',
                      style: TextStyle(
                        color: AppColors.textGray,
                        fontSize: 12,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Icon(Icons.stars, size: 14, color: AppColors.textGray),
                    const SizedBox(width: 4),
                    Text(
                      '${team.totalXP} XP',
                      style: TextStyle(
                        color: AppColors.textGray,
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          ElevatedButton(
            onPressed: () {
              _showChallengeBattleDialog(context, team, socialProvider);
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primaryRed,
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
            child: const Text(
              'CHALLENGE',
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _showCreateTeamDialog(BuildContext context, SocialProvider socialProvider) {
    final nameController = TextEditingController();

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: AppColors.backgroundCard,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text(
          'CREATE TEAM',
          style: TextStyle(
            fontFamily: 'Bebas Neue',
            fontSize: 24,
            color: Colors.white,
            letterSpacing: 1.5,
          ),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: nameController,
              style: const TextStyle(color: Colors.white),
              decoration: InputDecoration(
                labelText: 'Team Name',
                labelStyle: TextStyle(color: AppColors.textGray),
                enabledBorder: OutlineInputBorder(
                  borderSide: BorderSide(color: AppColors.textGray),
                  borderRadius: BorderRadius.circular(8),
                ),
                focusedBorder: OutlineInputBorder(
                  borderSide: const BorderSide(color: AppColors.primaryRed),
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('CANCEL', style: TextStyle(color: AppColors.textGray)),
          ),
          ElevatedButton(
            onPressed: () {
              if (nameController.text.trim().isNotEmpty) {
                socialProvider.createTeam(name: nameController.text.trim());
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('Team created successfully!')),
                );
              }
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primaryRed,
            ),
            child: const Text('CREATE'),
          ),
        ],
      ),
    );
  }

  void _showChallengeBattleDialog(
      BuildContext context, Team opponentTeam, SocialProvider socialProvider) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: AppColors.backgroundCard,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text(
          'CHALLENGE TEAM',
          style: TextStyle(
            fontFamily: 'Bebas Neue',
            fontSize: 24,
            color: Colors.white,
            letterSpacing: 1.5,
          ),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              'Challenge ${opponentTeam.name} to a 7-day XP battle?',
              style: const TextStyle(color: Colors.white, fontSize: 16),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),
            Text(
              'The team with the highest combined XP at the end wins!',
              style: TextStyle(color: AppColors.textGray, fontSize: 13),
              textAlign: TextAlign.center,
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('CANCEL', style: TextStyle(color: AppColors.textGray)),
          ),
          ElevatedButton(
            onPressed: () {
              // TODO: Implement team battle creation
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text('Battle challenge sent!')),
              );
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primaryRed,
            ),
            child: const Text('CHALLENGE'),
          ),
        ],
      ),
    );
  }
}
