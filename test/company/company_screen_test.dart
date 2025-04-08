import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:judeh_accounting/company/controllers/company_controller.dart';
import 'package:judeh_accounting/company/screens/company_screen.dart';
import 'package:judeh_accounting/company/models/company.dart';
import 'package:judeh_accounting/shared/widgets/widgets.dart';
import 'package:mockito/mockito.dart';
import 'package:mockito/annotations.dart';
import 'package:sqflite/sqflite.dart';

// Import the generated mocks
import 'company_screen_test.mocks.dart';

// Keep GenerateNiceMocks, but we will explicitly stub onStart
@GenerateNiceMocks([MockSpec<CompanyController>(), MockSpec<Database>()])
void main() {
  late MockCompanyController mockController;
  late MockDatabase mockDatabase;

  // Helper function (keep as before)
  Future<void> pumpScreen(WidgetTester tester) async {
    await tester.pumpWidget(
      ScreenUtilInit(
        designSize: const Size(360, 690),
        minTextAdapt: true,
        splitScreenMode: true,
        builder: (_, __) => GetMaterialApp(
          home: CompanyScreen(),
        ),
      ),
    );
    await tester.pump(); // Initial build
    await tester.pumpAndSettle(); // Settle animations/futures
  }

  // --- Consolidated Setup Function ---
  // To avoid repetition in each test
  void setupMockEnvironment({
    List<Map<String, Object?>> dbQueryResult = const [], // Default to empty
    List<Company> initialCompanies = const [], // Default to empty
    int initialSelectedIndex = -1,
  }) {
    Get.reset(); // Ensure clean GetX state

    // Create new mock instances for isolation
    mockController = MockCompanyController();
    mockDatabase = MockDatabase();

    // Stub Database
    Get.put<Database>(mockDatabase);
    when(mockDatabase.query(Company.tableName, limit: 25))
        .thenAnswer((_) async => dbQueryResult);

    // Stub Controller properties and methods
    when(mockController.companies).thenReturn(initialCompanies.obs);
    when(mockController.selectedIndex).thenReturn(initialSelectedIndex);
    // Stub the setter for selectedIndex verification
    when(mockController.selectedIndex = any)
        .thenReturn(null); // Or return the input value if needed

    // Stub methods called by UI or lifecycle
    when(mockController.getData()).thenAnswer((_) async {
      // Optional: simulate the list update if needed for specific tests
      mockController.companies.assignAll(initialCompanies);
    });
    when(mockController.create()).thenAnswer((_) async {});
    // Inside setupMockEnvironment
    when(mockController.edit()).thenAnswer((_) async {});

    // *** ADD EXPLICIT STUB FOR onStart ***
    // Return a simple void callback to satisfy GetX's expectation
    when(mockController.onStart)
        .thenReturn(InternalFinalCallback(callback: () {}));

    // Put the controller AFTER all its dependencies and stubs are set up
    Get.put<CompanyController>(mockController);
  }

  // Use the setup function in setUp for default behavior (optional)
  // setUp(() {
  //   setupMockEnvironment();
  // });

  // Use tearDown for consistency (optional but good practice)
  tearDown(() {
    Get.reset();
  });

  // --- TESTS ---

  testWidgets('CompanyScreen displays title and essential UI elements',
      (tester) async {
    // Arrange: Use the setup function for a clean environment
    setupMockEnvironment();

    // Act
    await pumpScreen(tester);

    // Assert
    expect(find.text('الشركات'), findsOneWidget);
    expect(find.byType(AppTable), findsOneWidget);
    expect(find.text('المعرف'), findsOneWidget);
    expect(find.text('الاسم'), findsOneWidget);
    expect(find.text('الرقم'), findsOneWidget);
    expect(find.text('ملاحظات'), findsOneWidget);
    expect(find.widgetWithText(AppButton, 'إضافة شركة'), findsOneWidget);
    expect(find.widgetWithText(AppButton, 'التعديل على السطر'), findsOneWidget);
  });

  testWidgets('CompanyScreen displays company data from controller',
      (tester) async {
    // Arrange
    final companiesData = [
      {
        'id': 1,
        'name': 'Test Co. 1',
        'phoneNumber': '123',
        'description': 'Desc 1',
        'createdAt': DateTime.now().toIso8601String()
      },
      {
        'id': 2,
        'name': 'Test Co. 2',
        'phoneNumber': '456',
        'description': 'Desc 2',
        'createdAt': DateTime.now().toIso8601String()
      },
    ];
    final companiesList =
        companiesData.map((e) => Company.fromDatabase(e)).toList();

    // Use setup function with specific data for this test
    setupMockEnvironment(
      dbQueryResult: companiesData,
      initialCompanies: companiesList,
    );
    // Simulate initial data load if pumpScreen doesn't trigger it via onInit effectively
    // This might be needed if Get.put happens too late for onInit logic sometimes
    mockController.companies.assignAll(companiesList);

    // Act
    await pumpScreen(tester);
    await tester.pump(); // Extra pump for Obx

    // Assert
    expect(find.text('Test Co. 1'), findsOneWidget);
    expect(find.text('123'), findsOneWidget);
    expect(find.text('Test Co. 2'), findsOneWidget);
    expect(find.text('456'), findsOneWidget);
  });

  testWidgets('Tapping a row selects it (verify controller interaction)',
      (tester) async {
    // Arrange
    final companiesData = [
      {
        'id': 1,
        'name': 'Select Me',
        'phoneNumber': '789',
        'description': 'Desc',
        'createdAt': DateTime.now().toIso8601String()
      },
    ];
    final companiesList =
        companiesData.map((e) => Company.fromDatabase(e)).toList();

    setupMockEnvironment(
        dbQueryResult: companiesData,
        initialCompanies: companiesList,
        initialSelectedIndex: -1 // Start with no selection
        );
    mockController.companies
        .assignAll(companiesList); // Ensure list is populated

    await pumpScreen(tester);
    await tester.pump();

    // Act
    expect(find.text('Select Me'), findsOneWidget);
    await tester.tap(find.text('Select Me'));
    await tester.pump();

    // Assert
    // Verify the setter was called with the correct index (0 for the first row)
    verify(mockController.selectedIndex = 0).called(1);
  });

  testWidgets('Add button calls controller.create', (tester) async {
    // Arrange
    setupMockEnvironment();

    await pumpScreen(tester);

    // Act
    await tester.tap(find.widgetWithText(AppButton, 'إضافة شركة'));
    await tester.pumpAndSettle();

    // Assert
    verify(mockController.create()).called(1);
  });

  testWidgets('Edit button calls controller.edit when item selected',
      (tester) async {
    // Arrange
    final companiesData = [
      {
        'id': 1,
        'name': 'Edit Me',
        'phoneNumber': '111',
        'description': 'Desc',
        'createdAt': DateTime.now().toIso8601String()
      },
    ];
    final companiesList =
        companiesData.map((e) => Company.fromDatabase(e)).toList();

    setupMockEnvironment(
        dbQueryResult: companiesData,
        initialCompanies: companiesList,
        initialSelectedIndex: 0 // Simulate item is selected
        );
    mockController.companies.assignAll(companiesList);

    await pumpScreen(tester);
    await tester.pump();

    // Act
    await tester.tap(find.widgetWithText(AppButton, 'التعديل على السطر'));
    await tester.pumpAndSettle();

    // Assert
    verify(mockController.edit()).called(1);
  });

  testWidgets('Edit button calls controller.edit and handles no selection',
      (tester) async {
    // Arrange
    setupMockEnvironment(initialSelectedIndex: -1);
    await pumpScreen(tester);

// Find the button *before* tapping
    final editButtonFinder =
        find.widgetWithText(AppButton, 'التعديل على السطر');
    expect(editButtonFinder, findsOneWidget,
        reason: "Edit button should be present"); // Add this check

// Act
    await tester.tap(editButtonFinder);
    await tester.pumpAndSettle();

// Assert
    verify(mockController.edit()).called(1);
  });
}
