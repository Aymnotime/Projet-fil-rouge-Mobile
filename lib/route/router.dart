import 'package:flutter/material.dart';
import 'package:shop/entry_point.dart';
import 'package:shop/models/product_model.dart';
import 'package:shop/screens/products/views/products_screen.dart';
import 'package:shop/route/screen_export.dart';


// Yuo will get 50+ screens and more once you have the full template
// 🔗 Full template: https://theflutterway.gumroad.com/l/fluttershop

// NotificationPermissionScreen()
// PreferredLanguageScreen()
// SelectLanguageScreen()
// SignUpVerificationScreen()
// ProfileSetupScreen()
// VerificationMethodScreen()
// OtpScreen()
// SetNewPasswordScreen()
// DoneResetPasswordScreen()
// TermsOfServicesScreen()
// SetupFingerprintScreen()
// SetupFingerprintScreen()
// SetupFingerprintScreen()
// SetupFingerprintScreen()
// SetupFaceIdScreen()
// OnSaleScreen()
// BannerLStyle2()
// BannerLStyle3()
// BannerLStyle4()
// SearchScreen()
// SearchHistoryScreen()
// NotificationsScreen()
// EnableNotificationScreen()
// NoNotificationScreen()
// NotificationOptionsScreen()
// ProductInfoScreen()
// ShippingMethodsScreen()
// ProductReviewsScreen()
// SizeGuideScreen()
// BrandScreen()
// CartScreen()
// EmptyCartScreen()
// PaymentMethodScreen()
// ThanksForOrderScreen()
// CurrentPasswordScreen()
// EditUserInfoScreen()
// OrdersScreen()
// OrderProcessingScreen()
// OrderDetailsScreen()
// CancleOrderScreen()
// DelivereOrdersdScreen()
// AddressesScreen()
// NoAddressScreen()
// AddNewAddressScreen()
// ServerErrorScreen()
// NoInternetScreen()
// ChatScreen()
// DiscoverWithImageScreen()
// SubDiscoverScreen()
// AddNewCardScreen()
// EmptyPaymentScreen()
// GetHelpScreen()

// ℹ️ All the comments screen are included in the full template
// 🔗 Full template: https://theflutterway.gumroad.com/l/fluttershop

Route<dynamic> generateRoute(RouteSettings settings) {
  if (settings.name == successOrderScreenRoute) {
    return MaterialPageRoute(builder: (context) => const SuccessOrderScreen());
  }
  // Ajout des routes personnalisées
  if (settings.name == cguScreenRoute) {
    return MaterialPageRoute(builder: (context) => const CguScreen());
  }
  if (settings.name == privacyPolicyScreenRoute) {
    return MaterialPageRoute(builder: (context) => const PrivacyPolicyScreen());
  }
  if (settings.name == contactServiceScreenRoute) {
    return MaterialPageRoute(builder: (context) => const ContactServiceScreen());
  }
  if (settings.name == faqScreenRoute) {
    return MaterialPageRoute(builder: (context) => const FaqScreen());
  }
  switch (settings.name) {
    case paymentDetailsScreenRoute:
      return MaterialPageRoute(
        builder: (context) => const PaymentDetailsScreen(),
      );
    case orderDetailsScreenRoute:
      return MaterialPageRoute(
        builder: (context) => const OrderDetailsScreen(),
      );


  // case preferredLanuageScreenRoute:
  //   return MaterialPageRoute(
  //     builder: (context) => const PreferredLanguageScreen(),
  //   );
    case logInScreenRoute:
      return MaterialPageRoute(
        builder: (context) => const LoginScreen(),
      );
    case signUpScreenRoute:
      return MaterialPageRoute(
        builder: (context) => const SignUpScreen(),
      );
  // case profileSetupScreenRoute:
  //   return MaterialPageRoute(
  //     builder: (context) => const ProfileSetupScreen(),
  //   );
    case passwordRecoveryScreenRoute:
      return MaterialPageRoute(
        builder: (context) => const PasswordRecoveryScreen(),
      );
  // case verificationMethodScreenRoute:
  //   return MaterialPageRoute(
  //     builder: (context) => const VerificationMethodScreen(),
  //   );
  // case otpScreenRoute:
  //   return MaterialPageRoute(
  //     builder: (context) => const OtpScreen(),
  //   );
  // case newPasswordScreenRoute:
  //   return MaterialPageRoute(
  //     builder: (context) => const SetNewPasswordScreen(),
  //   );
  // case doneResetPasswordScreenRoute:
  //   return MaterialPageRoute(
  //     builder: (context) => const DoneResetPasswordScreen(),
  //   );
  // case termsOfServicesScreenRoute:
  //   return MaterialPageRoute(
  //     builder: (context) => const TermsOfServicesScreen(),
  //   );
  // case noInternetScreenRoute:
  //   return MaterialPageRoute(
  //     builder: (context) => const NoInternetScreen(),
  //   );
  // case serverErrorScreenRoute:
  //   return MaterialPageRoute(
  //     builder: (context) => const ServerErrorScreen(),
  //   );
  // case signUpVerificationScreenRoute:
  //   return MaterialPageRoute(
  //     builder: (context) => const SignUpVerificationScreen(),
  //   );
  // case setupFingerprintScreenRoute:
  //   return MaterialPageRoute(
  //     builder: (context) => const SetupFingerprintScreen(),
  //   );
  // case setupFaceIdScreenRoute:
  //   return MaterialPageRoute(
  //     builder: (context) => const SetupFaceIdScreen(),
  //   );
    case productDetailsScreenRoute:
      return MaterialPageRoute(
        builder: (context) {
          final args = settings.arguments;
          if (args is ProductModel) {
            return ProductDetailsScreen(currentProduct: args);
          } else {
            // Affiche une erreur explicite si l'argument est manquant ou invalide
            return const Scaffold(
              body: Center(child: Text('Produit invalide : argument requis manquant')),
            );
          }
        },
      );



    case productReviewsScreenRoute:
      return MaterialPageRoute(
        builder: (context) => const ProductReviewsScreen(),
      );
  // case addReviewsScreenRoute:
  //   return MaterialPageRoute(
  //     builder: (context) => const AddReviewScreen(),
  //   );
    case homeScreenRoute:
      return MaterialPageRoute(
        builder: (context) => const HomeScreen(),
      );
  // case brandScreenRoute:
  //   return MaterialPageRoute(
  //     builder: (context) => const BrandScreen(),
  //   );
  // case discoverWithImageScreenRoute:
  //   return MaterialPageRoute(
  //     builder: (context) => const DiscoverWithImageScreen(),
  //   );
    case emptyWalletScreenRoute:
      return MaterialPageRoute(
        builder: (context) => const EmptyWalletScreen(),
      );
    case walletScreenRoute:
      return MaterialPageRoute(
        builder: (context) => const WalletScreen(),
      );
    case cartScreenRoute:
      return MaterialPageRoute(
        builder: (context) => const CartScreen(),
      );

  //   );

    case searchScreenRoute:
      return MaterialPageRoute(
        builder: (context) => const SearchScreen(),
      );
  // case searchHistoryScreenRoute:
  //   return MaterialPageRoute(
  //     builder: (context) => const SearchHistoryScreen(),
  //   );
    case productsScreenRoute:
      return MaterialPageRoute(
        builder: (context) => const ProductsScreen(),
        settings: settings,
      );
    case entryPointScreenRoute:
      return MaterialPageRoute(
        builder: (context) => const EntryPoint(),
      );
    case profileScreenRoute:
      return MaterialPageRoute(
        builder: (context) => const ProfileScreen(),
      );
  // case getHelpScreenRoute:
  //   return MaterialPageRoute(
  //     builder: (context) => const GetHelpScreen(),
  //   );
  // case chatScreenRoute:
  //   return MaterialPageRoute(
  //     builder: (context) => const ChatScreen(),
  //   );
    case userInfoScreenRoute:
      return MaterialPageRoute(
        builder: (context) => const UserInfoScreen(),
      );
    case securityScreenRoute:
      return MaterialPageRoute(
        builder: (context) => const SecurityScreen(),
      );
    case deliveryAddressScreenRoute:
      return MaterialPageRoute(
        builder: (context) => const DeliveryAddressScreen(),
      );
  // case currentPasswordScreenRoute:
  //   return MaterialPageRoute(
  //     builder: (context) => const CurrentPasswordScreen(),
  //   );
  // case editUserInfoScreenRoute:
  //   return MaterialPageRoute(
  //     builder: (context) => const EditUserInfoScreen(),
  //   );

  // case notificationsScreenRoute:
  //   return MaterialPageRoute(
  //     builder: (context) => const NotificationsScreen(),
  //   );
  // case noNotificationScreenRoute:
  //   return MaterialPageRoute(
  //     builder: (context) => const NoNotificationScreen(),
  //   );
  // case enableNotificationScreenRoute:
  //   return MaterialPageRoute(
  //     builder: (context) => const EnableNotificationScreen(),
  //   );
  // case notificationOptionsScreenRoute:
  //   return MaterialPageRoute(
  //     builder: (context) => const NotificationOptionsScreen(),
  //   );
  // case selectLanguageScreenRoute:
  //   return MaterialPageRoute(
  //     builder: (context) => const SelectLanguageScreen(),
  //   );
  // case noAddressScreenRoute:
  //   return MaterialPageRoute(
  //     builder: (context) => const NoAddressScreen(),
  //   );

  // case addNewAddressesScreenRoute:
  //   return MaterialPageRoute(
  //     builder: (context) => const AddNewAddressScreen(),
  //   );
    case ordersScreenRoute:
      return MaterialPageRoute(
        builder: (context) => const OrdersScreen(),
      );

    case resetPasswordScreenRoute:
      final args = settings.arguments;
      if (args is String) {
        return MaterialPageRoute(
          builder: (context) => ResetPasswordScreen(token: args),
        );
      }
      return MaterialPageRoute(
        builder: (context) => const Scaffold(
          body: Center(child: Text('Token manquant pour la réinitialisation')), // fallback
        ),
      );
  // case orderProcessingScreenRoute:
  //   return MaterialPageRoute(
  //     builder: (context) => const OrderProcessingScreen(),
  //   );
  // case orderDetailsScreenRoute:
  //   return MaterialPageRoute(
  //     builder: (context) => const OrderDetailsScreen(),
  //   );
  // case cancleOrderScreenRoute:
  //   return MaterialPageRoute(
  //     builder: (context) => const CancleOrderScreen(),
  //   );
  // case deliveredOrdersScreenRoute:
  //   return MaterialPageRoute(
  //     builder: (context) => const DelivereOrdersdScreen(),
  //   );
  // case cancledOrdersScreenRoute:
  //   return MaterialPageRoute(
  //     builder: (context) => const CancledOrdersScreen(),
  //   );
    case preferencesScreenRoute:
      return MaterialPageRoute(
        builder: (context) => const PreferencesScreen(),
      );
  // case emptyPaymentScreenRoute:
  //   return MaterialPageRoute(
  //     builder: (context) => const EmptyPaymentScreen(),
  //   );
    case emptyWalletScreenRoute:
      return MaterialPageRoute(
        builder: (context) => const EmptyWalletScreen(),
      );

    case walletScreenRoute:
      return MaterialPageRoute(
        builder: (context) => const WalletScreen(),
      );
    case cartScreenRoute:
      return MaterialPageRoute(
        builder: (context) => const CartScreen(),
      );

  // case paymentMethodScreenRoute:
  //   return MaterialPageRoute(
  //     builder: (context) => const PaymentMethodScreen(),
  //   );
  // case addNewCardScreenRoute:
  //   return MaterialPageRoute(
  //     builder: (context) => const AddNewCardScreen(),
  //   );
  // case thanksForOrderScreenRoute:
  //   return MaterialPageRoute(
  //     builder: (context) => const ThanksForOrderScreen(),
  //   );
    default:
      return MaterialPageRoute(
        builder: (context) => const Scaffold(
          body: Center(child: Text('Page non trouvée')),
        ),
      );
  }
}
