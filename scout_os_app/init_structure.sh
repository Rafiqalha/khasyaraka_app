#!/bin/bash

echo "🚀 Initializing Scout OS Flutter project structure..."

# ===== ASSETS =====
mkdir -p assets/{images/{logo,onboarding,badges},icons/{training,hiking,cyber,dashboard},animations,maps/offline_tiles}

# ===== LIB ROOT =====
mkdir -p lib/{core,config,shared,services,modules,routes}

touch lib/{main.dart,app.dart}

# ===== CORE =====
mkdir -p lib/core/{constants,errors,utils,enums}

touch lib/core/constants/{api_constants.dart,app_constants.dart,supabase_constants.dart}
touch lib/core/errors/{api_error.dart,network_error.dart,auth_error.dart}
touch lib/core/utils/{date_utils.dart,xp_utils.dart,validation_utils.dart}
touch lib/core/enums/{question_type.dart,lesson_status.dart,user_role.dart}

# ===== CONFIG =====
touch lib/config/{environment.dart,supabase_config.dart,api_config.dart,theme_config.dart}

# ===== SHARED =====
mkdir -p lib/shared/{widgets,layouts,dialogs}

touch lib/shared/widgets/{progress_bar.dart,xp_badge.dart,lesson_card.dart,path_card.dart,loading_overlay.dart}
touch lib/shared/layouts/{main_scaffold.dart,dashboard_layout.dart}
touch lib/shared/dialogs/{confirm_dialog.dart,error_dialog.dart}

# ===== SERVICES =====
mkdir -p lib/services/{api,supabase}

touch lib/services/api/{api_client.dart,api_interceptor.dart}
touch lib/services/supabase/{supabase_client.dart,supabase_auth_service.dart}
touch lib/services/{training_service.dart,user_service.dart,xp_service.dart,streak_service.dart}

# ===== MODULES =====

# TRAINING
mkdir -p lib/modules/training/{data/{models,repositories},logic,views,widgets}

touch lib/modules/training/data/models/{training_path.dart,training_lesson.dart,training_question.dart,user_answer.dart}
touch lib/modules/training/data/repositories/training_repository.dart
touch lib/modules/training/logic/{training_controller.dart,lesson_controller.dart}
touch lib/modules/training/views/{training_paths_page.dart,lesson_list_page.dart,lesson_page.dart,lesson_result_page.dart}
touch lib/modules/training/widgets/{question_card.dart,option_button.dart,lesson_progress_header.dart}

# DASHBOARD
mkdir -p lib/modules/dashboard/{data/models,logic,views}

touch lib/modules/dashboard/data/models/dashboard_summary.dart
touch lib/modules/dashboard/logic/dashboard_controller.dart
touch lib/modules/dashboard/views/dashboard_page.dart

# PROFILE
mkdir -p lib/modules/profile/{data/models,logic,views}

touch lib/modules/profile/data/models/user_profile.dart
touch lib/modules/profile/logic/profile_controller.dart
touch lib/modules/profile/views/profile_page.dart

# HIKING (FUTURE)
mkdir -p lib/modules/hiking/{data/models,logic,views}

touch lib/modules/hiking/data/models/hiking_route.dart
touch lib/modules/hiking/logic/hiking_controller.dart
touch lib/modules/hiking/views/hiking_map_page.dart

# CYBER MODE
mkdir -p lib/modules/cyber/{data/models,logic,views}

touch lib/modules/cyber/data/models/cyber_challenge.dart
touch lib/modules/cyber/logic/cyber_controller.dart
touch lib/modules/cyber/views/cyber_mode_page.dart

# ===== ROUTES =====
touch lib/routes/{app_routes.dart,route_names.dart,route_guard.dart}

echo "✅ Scout OS Flutter structure created successfully!"
