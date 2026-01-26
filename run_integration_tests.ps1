Write-Host "🚀 Lancement des tests d'intégration web..." -ForegroundColor Green

# Test auth
Write-Host "`n📝 Test authentification..." -ForegroundColor Cyan
flutter drive --driver=test_driver/integration_test.dart --target=integration_test/auth/auth_flow_test.dart -d chrome --profile

# Test orders
Write-Host "`n📝 Test commandes..." -ForegroundColor Cyan
flutter drive --driver=test_driver/integration_test.dart --target=integration_test/orders/order_flow_test.dart -d chrome --profile

# Test navigation
Write-Host "`n📝 Test navigation..." -ForegroundColor Cyan
flutter drive --driver=test_driver/integration_test.dart --target=integration_test/navigation/navigation_test.dart -d chrome --profile

# Test gestion des erreurs
Write-Host "`n📝 Test gestion des erreurs..." -ForegroundColor Cyan
flutter drive --driver=test_driver/integration_test.dart --target=integration_test/errors/error_handling_test.dart -d chrome --profile


Write-Host "`n✅ Tous les tests terminés !" -ForegroundColor Green