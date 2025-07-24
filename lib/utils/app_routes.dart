import 'package:get/get.dart';
import '../../search/search_screen.dart';
import '../../models/class_model.dart';
import '../../models/quiz_model.dart';
import '../../screens/splash/splash_screen.dart';
import '../../screens/auth/welcome_screen.dart';
import '../../screens/auth/login_screen.dart';
import '../../screens/auth/register_screen.dart';
import '../../screens/main_navigation_screen.dart';
import '../../screens/tasks/task_form_screen.dart';
import '../../screens/tasks/task_alarm_screen.dart';
import '../../screens/notes/notes_list_screen.dart';
import '../../screens/notes/note_form_screen.dart';
import '../../screens/class/class_list_screen.dart';
import '../../screens/class/class_detail_screen.dart';
import '../../screens/quiz/make_quiz_screen.dart';
import '../../screens/quiz/quiz_form_screen.dart';
import '../../screens/quiz/quiz_taking_screen.dart';
import '../../screens/profile/profile_screen.dart';
import '../../screens/profile/change_password_screen.dart';
import '../../screens/quiz/quiz_start_screen.dart';

class AppRoutes {
  static const String splash = '/';
  static const String welcome = '/welcome';
  static const String login = '/login';
  static const String register = '/register';
  static const String main = '/main';
  static const String taskForm = '/task-form';
  static const String noteForm = '/note-form';
  static const String quizForm = '/quiz-form';
  static const String quizTaking = '/quiz-taking';
  static const String taskAlarm = '/task-alarm';
  static const String classList = '/class-list';
  static const String profile = '/profile';
  static const String changePassword = '/change-password';
  static const String notesList = '/notes-list';
  static const String quizStart = '/quiz-start';
  static const String search = '/search';
  static const String classDetail = '/class-detail';
  static const String makeQuiz = '/make-quiz';
  static final List<GetPage> routes = [
    GetPage(name: splash, page: () => const SplashScreen()),
    GetPage(name: welcome, page: () => const WelcomeScreen()),
    GetPage(name: login, page: () => const LoginScreen()),
    GetPage(name: register, page: () => const RegisterScreen()),
    GetPage(name: main, page: () => const MainNavigationScreen()),
    GetPage(name: taskForm, page: () => const TaskFormScreen()),
    GetPage(name: noteForm, page: () => const NoteFormScreen()),
    GetPage(name: quizForm, page: () => const QuizFormScreen()),
    GetPage(name: taskAlarm, page: () => const TaskAlarmScreen()),
    GetPage(name: classList, page: () => const ClassListScreen()),
    GetPage(name: profile, page: () => const ProfileScreen()),
    GetPage(name: changePassword, page: () => const ChangePasswordScreen()),
    GetPage(name: notesList, page: () => const NotesListScreen()),
    GetPage(name: quizStart, page: () => const QuizStartScreen()),
    GetPage(name: search, page: () => const SearchScreen()),
    GetPage(
      name: classDetail,
      page: () => ClassDetailScreen(classModel: Get.arguments as ClassModel),
    ),
    GetPage(
      name: makeQuiz,
      page: () => MakeQuizScreen(classId: Get.arguments as String),
    ),

    GetPage(name: quizStart, page: () => const QuizStartScreen()),
    GetPage(
      name: AppRoutes.quizTaking,
      page: () => QuizTakingScreen(quiz: Get.arguments as Quiz),
    ),
  ];
}
