import 'package:uuid/uuid.dart';
import '../domain/models/task.dart';
import '../domain/models/subtask.dart';
import '../domain/models/task_category.dart';
import '../domain/models/task_priority.dart';

class TaskMockData {
  TaskMockData._();

  static List<Task> getInitialTasks() {
    final now = DateTime.now();
    const uuid = Uuid();

    return [
      Task(
        id: uuid.v4(),
        title: 'Design Mobile Design System & Tokens',
        description: 'Finalize primary, secondary color palettes, glassmorphism cards, and typography scales for the new design release.',
        category: TaskCategory.design,
        priority: TaskPriority.urgent,
        dueDate: now.add(const Duration(hours: 4)),
        isCompleted: false,
        tags: ['Design', 'UI/UX', 'Figma'],
        createdAt: now.subtract(const Duration(days: 1)),
        subtasks: [
          SubTask(id: uuid.v4(), title: 'Audit current color variables', isCompleted: true),
          SubTask(id: uuid.v4(), title: 'Define dark mode contrast ratios', isCompleted: true),
          SubTask(id: uuid.v4(), title: 'Build interactive Figma component library', isCompleted: false),
          SubTask(id: uuid.v4(), title: 'Export tokens to JSON format', isCompleted: false),
        ],
      ),
      Task(
        id: uuid.v4(),
        title: 'Sprint Planning & Architecture Review',
        description: 'Review technical debt, roadmap priorities, and microservice decoupling strategy with the core engineering leads.',
        category: TaskCategory.work,
        priority: TaskPriority.high,
        dueDate: now.add(const Duration(hours: 8)),
        isCompleted: false,
        tags: ['Work', 'Engineering', 'Agile'],
        createdAt: now.subtract(const Duration(hours: 12)),
        subtasks: [
          SubTask(id: uuid.v4(), title: 'Review backlog Jira tickets', isCompleted: true),
          SubTask(id: uuid.v4(), title: 'Finalize Q4 milestones', isCompleted: false),
          SubTask(id: uuid.v4(), title: 'Sync with QA lead on test automation', isCompleted: false),
        ],
      ),
      Task(
        id: uuid.v4(),
        title: '5km Sunset Trail Run & Hydration',
        description: 'Complete cadence-focused run at the riverside park. Target heart rate zone 2-3.',
        category: TaskCategory.health,
        priority: TaskPriority.medium,
        dueDate: now.add(const Duration(hours: 6)),
        isCompleted: false,
        tags: ['Health', 'Cardio', 'Fitness'],
        createdAt: now.subtract(const Duration(days: 2)),
        subtasks: [
          SubTask(id: uuid.v4(), title: 'Dynamic stretch & warm-up', isCompleted: true),
          SubTask(id: uuid.v4(), title: '5km steady run at 5:15 pace', isCompleted: false),
          SubTask(id: uuid.v4(), title: 'Electrolytes & protein shake', isCompleted: false),
        ],
      ),
      Task(
        id: uuid.v4(),
        title: 'Complete Distributed Systems Chapter 4',
        description: 'Study Byzantine fault tolerance, Raft consensus algorithm, and replication models.',
        category: TaskCategory.study,
        priority: TaskPriority.medium,
        dueDate: now.add(const Duration(days: 1, hours: 2)),
        isCompleted: false,
        tags: ['Study', 'Computer Science', 'Raft'],
        createdAt: now.subtract(const Duration(days: 3)),
        subtasks: [
          SubTask(id: uuid.v4(), title: 'Read raft paper sections 1-5', isCompleted: true),
          SubTask(id: uuid.v4(), title: 'Implement leader election toy demo', isCompleted: false),
        ],
      ),
      Task(
        id: uuid.v4(),
        title: 'Monthly Budget & Investment Allocation',
        description: 'Rebalance portfolio index funds, review recurring subscriptions, and update emergency fund savings.',
        category: TaskCategory.finance,
        priority: TaskPriority.low,
        dueDate: now.add(const Duration(days: 2)),
        isCompleted: false,
        tags: ['Finance', 'Budget', 'Savings'],
        createdAt: now.subtract(const Duration(days: 4)),
        subtasks: [
          SubTask(id: uuid.v4(), title: 'Export credit card statements', isCompleted: true),
          SubTask(id: uuid.v4(), title: 'Cancel unused gym subscription', isCompleted: true),
          SubTask(id: uuid.v4(), title: 'Transfer 20% to index ETF', isCompleted: false),
        ],
      ),
      Task(
        id: uuid.v4(),
        title: 'Prepare Espresso Machine Deep Clean',
        description: 'Descale boiler, backflush group head with Cafiza, clean burrs on grinder.',
        category: TaskCategory.personal,
        priority: TaskPriority.low,
        dueDate: now.subtract(const Duration(hours: 5)),
        isCompleted: true,
        completedAt: now.subtract(const Duration(hours: 2)),
        tags: ['Home', 'Coffee'],
        createdAt: now.subtract(const Duration(days: 5)),
        subtasks: [
          SubTask(id: uuid.v4(), title: 'Chemical backflush with blind basket', isCompleted: true),
          SubTask(id: uuid.v4(), title: 'Soak portafilter & steam wand', isCompleted: true),
        ],
      ),
      Task(
        id: uuid.v4(),
        title: 'Ship Authentication & Biometrics Module',
        description: 'Implement FaceID / TouchID biometric fallback and securely store JWT tokens in keychain.',
        category: TaskCategory.work,
        priority: TaskPriority.high,
        dueDate: now.subtract(const Duration(days: 1)),
        isCompleted: true,
        completedAt: now.subtract(const Duration(hours: 18)),
        tags: ['Security', 'Mobile', 'Release'],
        createdAt: now.subtract(const Duration(days: 6)),
        subtasks: [
          SubTask(id: uuid.v4(), title: 'Configure iOS LocalAuthentication plist', isCompleted: true),
          SubTask(id: uuid.v4(), title: 'Unit test auth interceptor', isCompleted: true),
          SubTask(id: uuid.v4(), title: 'QA regression testing', isCompleted: true),
        ],
      ),
    ];
  }
}
