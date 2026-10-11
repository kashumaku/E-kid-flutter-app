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
        id: 'task-ux-design',
        title: 'User experience design',
        description:
            'Task management is the process which is monitoring your fast project\'s tasks through their various stages from start to finish, ensuring design alignment and high usability benchmarks.',
        category: TaskCategory.design,
        priority: TaskPriority.high,
        dueDate: now.add(const Duration(hours: 4)),
        isCompleted: false,
        tags: ['UX', 'Design', 'Research'],
        createdAt: now.subtract(const Duration(days: 1)),
        subtasks: [
          SubTask(id: uuid.v4(), title: 'Website Redesign', isCompleted: true),
          SubTask(id: uuid.v4(), title: 'Website Design', isCompleted: false),
          SubTask(id: uuid.v4(), title: 'Wireframe Usability Testing', isCompleted: true),
          SubTask(id: uuid.v4(), title: 'Component Library Audit', isCompleted: false),
          SubTask(id: uuid.v4(), title: 'Developer Handoff Specs', isCompleted: false),
        ],
      ),
      Task(
        id: 'task-meeting-designer',
        title: 'Meeting with designer',
        description:
            'Weekly sync with senior product designers to evaluate sprint deliverables, UI kits, and interaction design feedback.',
        category: TaskCategory.work,
        priority: TaskPriority.urgent,
        dueDate: now.add(const Duration(hours: 6)),
        isCompleted: false,
        tags: ['Meeting', 'Product', 'Sync'],
        createdAt: now.subtract(const Duration(hours: 8)),
        subtasks: [
          SubTask(id: uuid.v4(), title: 'Prepare Figma interactive demo', isCompleted: true),
          SubTask(id: uuid.v4(), title: 'Review feedback notes', isCompleted: true),
          SubTask(id: uuid.v4(), title: 'Document action items', isCompleted: false),
        ],
      ),
      Task(
        id: 'task-website-design-upcoming',
        title: 'Website Design',
        description:
            'High-converting responsive landing page redesign incorporating sleek glassmorphism, micro-animations, and fast load times.',
        category: TaskCategory.design,
        priority: TaskPriority.medium,
        dueDate: now.add(const Duration(days: 5)),
        isCompleted: false,
        tags: ['Web', 'Creative'],
        createdAt: now.subtract(const Duration(days: 2)),
        subtasks: [
          SubTask(id: uuid.v4(), title: 'Hero section wireframing', isCompleted: true),
          SubTask(id: uuid.v4(), title: 'Responsive grid tokens', isCompleted: false),
        ],
      ),
      Task(
        id: uuid.v4(),
        title: 'Mobile App Wireframing',
        description:
            'Draft low-fidelity wireframes for iOS and Android dashboard navigation flows and task filtering gestures.',
        category: TaskCategory.work,
        priority: TaskPriority.medium,
        dueDate: now.add(const Duration(days: 7)),
        isCompleted: false,
        tags: ['Mobile', 'Wireframe'],
        createdAt: now.subtract(const Duration(days: 3)),
        subtasks: [
          SubTask(id: uuid.v4(), title: 'User journey mapping', isCompleted: true),
          SubTask(id: uuid.v4(), title: 'Low-fi prototypes', isCompleted: false),
        ],
      ),
      Task(
        id: uuid.v4(),
        title: 'Design System Documentation',
        description:
            'Publish comprehensive design token documentation including color contrast standards and elevation rules.',
        category: TaskCategory.study,
        priority: TaskPriority.low,
        dueDate: now.add(const Duration(days: 10)),
        isCompleted: false,
        tags: ['Documentation', 'Tokens'],
        createdAt: now.subtract(const Duration(days: 4)),
        subtasks: [
          SubTask(id: uuid.v4(), title: 'Draft accessibility guidelines', isCompleted: true),
          SubTask(id: uuid.v4(), title: 'Export token specs', isCompleted: true),
        ],
      ),
    ];
  }
}
