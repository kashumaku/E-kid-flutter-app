import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../../core/widgets/empty_state.dart';
import '../../domain/models/task_category.dart';
import '../controllers/task_provider.dart';
import '../widgets/category_pill.dart';
import '../widgets/progress_summary_card.dart';
import '../widgets/search_filter_bar.dart';
import '../widgets/task_card.dart';
import '../widgets/task_form_sheet.dart';
import 'task_detail_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final TextEditingController _searchController = TextEditingController();

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _openCreateSheet(BuildContext context, TaskProvider provider) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Theme.of(context).cardColor,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (ctx) => TaskFormSheet(provider: provider),
    );
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<TaskProvider>();
    final filteredTasks = provider.filteredTasks;
    final categoryCounts = provider.categoryCounts;

    return Scaffold(
      body: SafeArea(
        child: RefreshIndicator(
          onRefresh: () => provider.loadTasks(),
          child: CustomScrollView(
            slivers: [
              // Top Spacing & Summary Card
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(20, 12, 20, 16),
                  child: ProgressSummaryCard(provider: provider),
                ),
              ),

              // Categories Horizontal List
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.only(bottom: 16),
                  child: SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    child: Row(
                      children: TaskCategory.defaultCategories.map((category) {
                        final isSelected = provider.selectedCategory?.id == category.id;
                        final count = categoryCounts[category] ?? 0;
                        return Padding(
                          padding: const EdgeInsets.only(right: 8),
                          child: CategoryPill(
                            category: category,
                            isSelected: isSelected,
                            count: count,
                            onTap: () => provider.setCategory(category),
                          ),
                        );
                      }).toList(),
                    ),
                  ),
                ),
              ),

              // Search & Filter Bar
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(20, 0, 20, 14),
                  child: SearchFilterBar(
                    provider: provider,
                    searchController: _searchController,
                  ),
                ),
              ),

              // Task List or Empty State
              if (provider.isLoading)
                const SliverFillRemaining(
                  child: Center(child: CircularProgressIndicator()),
                )
              else if (filteredTasks.isEmpty)
                SliverFillRemaining(
                  hasScrollBody: false,
                  child: EmptyStateWidget(
                    icon: Icons.checklist_rounded,
                    title: 'No tasks found',
                    message: provider.searchQuery.isNotEmpty
                        ? 'No tasks match "${provider.searchQuery}". Try a different keyword.'
                        : 'You are all caught up in this view! Enjoy your momentum.',
                    buttonLabel: 'Create a Task',
                    onAction: () => _openCreateSheet(context, provider),
                  ),
                )
              else
                SliverPadding(
                  padding: const EdgeInsets.fromLTRB(20, 0, 20, 90),
                  sliver: SliverList(
                    delegate: SliverChildBuilderDelegate(
                      (context, index) {
                        final task = filteredTasks[index];
                        return TaskCard(
                          task: task,
                          onTap: () {
                            Navigator.of(context).push(
                              MaterialPageRoute(
                                builder: (_) => TaskDetailScreen(
                                  taskId: task.id,
                                  provider: provider,
                                ),
                              ),
                            );
                          },
                          onToggleComplete: () {
                            provider.toggleTaskCompletion(task.id);
                          },
                          onDelete: () {
                            provider.deleteTask(task.id);
                          },
                        );
                      },
                      childCount: filteredTasks.length,
                    ),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}
