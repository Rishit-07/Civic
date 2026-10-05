library dataconnect_generated;
import 'package:firebase_data_connect/firebase_data_connect.dart';
import 'package:flutter/foundation.dart';
import 'dart:convert';

part 'create_user.dart';

part 'update_user.dart';

part 'delete_user.dart';

part 'get_user.dart';

part 'list_users.dart';

part 'create_category.dart';

part 'update_category.dart';

part 'delete_category.dart';

part 'get_category.dart';

part 'list_categories.dart';

part 'create_term.dart';

part 'update_term.dart';

part 'delete_term.dart';

part 'get_term.dart';

part 'list_terms.dart';

part 'create_workflow.dart';

part 'update_workflow.dart';

part 'delete_workflow.dart';

part 'get_workflow.dart';

part 'list_workflows.dart';

part 'create_workflow_step.dart';

part 'update_workflow_step.dart';

part 'delete_workflow_step.dart';

part 'get_workflow_step.dart';

part 'list_workflow_steps.dart';

part 'create_user_bookmark.dart';

part 'delete_user_bookmark.dart';

part 'list_my_bookmarks.dart';







class ExampleConnector {
  
  
  CreateUserVariablesBuilder createUser () {
    return CreateUserVariablesBuilder(dataConnect, );
  }
  
  
  UpdateUserVariablesBuilder updateUser () {
    return UpdateUserVariablesBuilder(dataConnect, );
  }
  
  
  DeleteUserVariablesBuilder deleteUser () {
    return DeleteUserVariablesBuilder(dataConnect, );
  }
  
  
  GetUserVariablesBuilder getUser () {
    return GetUserVariablesBuilder(dataConnect, );
  }
  
  
  ListUsersVariablesBuilder listUsers () {
    return ListUsersVariablesBuilder(dataConnect, );
  }
  
  
  CreateCategoryVariablesBuilder createCategory () {
    return CreateCategoryVariablesBuilder(dataConnect, );
  }
  
  
  UpdateCategoryVariablesBuilder updateCategory () {
    return UpdateCategoryVariablesBuilder(dataConnect, );
  }
  
  
  DeleteCategoryVariablesBuilder deleteCategory () {
    return DeleteCategoryVariablesBuilder(dataConnect, );
  }
  
  
  GetCategoryVariablesBuilder getCategory () {
    return GetCategoryVariablesBuilder(dataConnect, );
  }
  
  
  ListCategoriesVariablesBuilder listCategories () {
    return ListCategoriesVariablesBuilder(dataConnect, );
  }
  
  
  CreateTermVariablesBuilder createTerm () {
    return CreateTermVariablesBuilder(dataConnect, );
  }
  
  
  UpdateTermVariablesBuilder updateTerm () {
    return UpdateTermVariablesBuilder(dataConnect, );
  }
  
  
  DeleteTermVariablesBuilder deleteTerm () {
    return DeleteTermVariablesBuilder(dataConnect, );
  }
  
  
  GetTermVariablesBuilder getTerm () {
    return GetTermVariablesBuilder(dataConnect, );
  }
  
  
  ListTermsVariablesBuilder listTerms () {
    return ListTermsVariablesBuilder(dataConnect, );
  }
  
  
  CreateWorkflowVariablesBuilder createWorkflow () {
    return CreateWorkflowVariablesBuilder(dataConnect, );
  }
  
  
  UpdateWorkflowVariablesBuilder updateWorkflow () {
    return UpdateWorkflowVariablesBuilder(dataConnect, );
  }
  
  
  DeleteWorkflowVariablesBuilder deleteWorkflow () {
    return DeleteWorkflowVariablesBuilder(dataConnect, );
  }
  
  
  GetWorkflowVariablesBuilder getWorkflow () {
    return GetWorkflowVariablesBuilder(dataConnect, );
  }
  
  
  ListWorkflowsVariablesBuilder listWorkflows () {
    return ListWorkflowsVariablesBuilder(dataConnect, );
  }
  
  
  CreateWorkflowStepVariablesBuilder createWorkflowStep () {
    return CreateWorkflowStepVariablesBuilder(dataConnect, );
  }
  
  
  UpdateWorkflowStepVariablesBuilder updateWorkflowStep () {
    return UpdateWorkflowStepVariablesBuilder(dataConnect, );
  }
  
  
  DeleteWorkflowStepVariablesBuilder deleteWorkflowStep () {
    return DeleteWorkflowStepVariablesBuilder(dataConnect, );
  }
  
  
  GetWorkflowStepVariablesBuilder getWorkflowStep () {
    return GetWorkflowStepVariablesBuilder(dataConnect, );
  }
  
  
  ListWorkflowStepsVariablesBuilder listWorkflowSteps () {
    return ListWorkflowStepsVariablesBuilder(dataConnect, );
  }
  
  
  CreateUserBookmarkVariablesBuilder createUserBookmark () {
    return CreateUserBookmarkVariablesBuilder(dataConnect, );
  }
  
  
  DeleteUserBookmarkVariablesBuilder deleteUserBookmark () {
    return DeleteUserBookmarkVariablesBuilder(dataConnect, );
  }
  
  
  ListMyBookmarksVariablesBuilder listMyBookmarks () {
    return ListMyBookmarksVariablesBuilder(dataConnect, );
  }
  

  static ConnectorConfig connectorConfig = ConnectorConfig(
    'asia-south1',
    'example',
    'civic',
  );

  ExampleConnector({required this.dataConnect});
  static ExampleConnector get instance {
    
    CacheSettings cacheSettings = CacheSettings(
      maxAge: Duration(milliseconds:0),
      storage: CacheStorage.persistent,
    );
    
    return ExampleConnector(
        dataConnect: FirebaseDataConnect.instanceFor(
            connectorConfig: connectorConfig,
            
            cacheSettings: cacheSettings,
            
            sdkType: CallerSDKType.generated));
  }

  FirebaseDataConnect dataConnect;
}
