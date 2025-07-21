import 'package:animations/animations.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:shop/constants.dart';
import 'package:shop/route/screen_export.dart';
import 'package:shop/screens/checkout/cart_notifier.dart';
import 'package:shop/services/auth_service.dart';
import 'package:shop/screens/home/views/home_screen.dart';

class EntryPoint extends StatefulWidget {
  const EntryPoint({super.key});

  @override
  State<EntryPoint> createState() => _EntryPointState();
}

class _EntryPointState extends State<EntryPoint> {
  final List _pages = [
    HomeScreen(), // HomeScreen affiche maintenant uniquement ProductsScreen (carrousels unifiés)
    DiscoverScreen(),
    ProductsScreen(),
    // EmptyCartScreen(), // if Cart is empty
    CartScreen(),
    ProfileScreen(),
  ];
  int _currentIndex = 0;
  int cartCount = 0;

  @override
  void initState() {
    super.initState();
    _fetchCartCount();
    // Écouter les changements du panier de manière plus robuste
    cartUpdateNotifier.addListener(_onCartUpdate);
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    // Re-fetch le compteur quand les dépendances changent (ex: retour d'un autre écran)
    _fetchCartCount();
  }

  @override
  void dispose() {
    cartUpdateNotifier.removeListener(_onCartUpdate);
    super.dispose();
  }

  // Méthode appelée à chaque notification de changement du panier
  void _onCartUpdate() {
    if (mounted) {
      // Utiliser directement la valeur du notifier
      setState(() {
        cartCount = cartUpdateNotifier.value;
      });
    }
  }

  // Plus besoin de cette méthode séparée
  Future<void> _fetchCartCount() async {
    try {
      final items = await fetchCartItems();
      if (mounted) {
        final newCartCount = items.fold<int>(0, (sum, item) => sum + (item['quantite'] ?? 1) as int);
        // Éviter les setState inutiles si la valeur n'a pas changé
        if (newCartCount != cartCount) {
          setState(() {
            cartCount = newCartCount;
          });
        }
      }
    } catch (e) {
      // Gérer l'erreur si nécessaire
      debugPrint('Erreur lors de la récupération du panier: $e');
      if (mounted && cartCount != 0) {
        setState(() {
          cartCount = 0;
        });
      }
    }
  }

  // Méthode publique pour forcer la mise à jour (utile pour les autres écrans)
  void refreshCartCount() {
    _fetchCartCount();
  }

  @override
  Widget build(BuildContext context) {
    SvgPicture svgIcon(String src, {Color? color}) {
      return SvgPicture.asset(
        src,
        height: 24,
        colorFilter: ColorFilter.mode(
            color ??
                Theme.of(context).iconTheme.color!.withOpacity(
                    Theme.of(context).brightness == Brightness.dark ? 0.3 : 1),
            BlendMode.srcIn),
      );
    }

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).scaffoldBackgroundColor,
        leading: const SizedBox(),
        leadingWidth: 0,
        centerTitle: false,
        title: SvgPicture.asset(
          "assets/logo/tech-shop.svg",
          colorFilter: ColorFilter.mode(
              Theme.of(context).iconTheme.color!, BlendMode.srcIn),
          height: 20,
          width: 80,
        ),
        actions: [
          IconButton(
            onPressed: () {
              Navigator.pushNamed(context, searchScreenRoute);
            },
            icon: SvgPicture.asset(
              "assets/icons/Search.svg",
              height: 24,
              colorFilter: ColorFilter.mode(
                  Theme.of(context).textTheme.bodyLarge!.color!,
                  BlendMode.srcIn),
            ),
          ),
          IconButton(
            onPressed: () {
              Navigator.pushNamed(context, notificationsScreenRoute);
            },
            icon: SvgPicture.asset(
              "assets/icons/Notification.svg",
              height: 24,
              colorFilter: ColorFilter.mode(
                  Theme.of(context).textTheme.bodyLarge!.color!,
                  BlendMode.srcIn),
            ),
          ),
          // Widget du panier avec badge dynamique
          _buildCartIconWithBadge(),
        ],
      ),
      body: PageTransitionSwitcher(
        duration: defaultDuration,
        transitionBuilder: (child, animation, secondAnimation) {
          return FadeThroughTransition(
            animation: animation,
            secondaryAnimation: secondAnimation,
            child: child,
          );
        },
        child: _pages[_currentIndex],
      ),
      bottomNavigationBar: Container(
        padding: const EdgeInsets.only(top: defaultPadding / 2),
        color: Theme.of(context).brightness == Brightness.light
            ? Colors.white
            : const Color(0xFF101015),
        child: BottomNavigationBar(
          currentIndex: _currentIndex,
          onTap: (index) {
            if (index != _currentIndex) {
              setState(() {
                _currentIndex = index;
              });
            }
          },
          backgroundColor: Theme.of(context).brightness == Brightness.light
              ? Colors.white
              : const Color(0xFF101015),
          type: BottomNavigationBarType.fixed,
          selectedFontSize: 12,
          selectedItemColor: primaryColor,
          unselectedItemColor: Colors.transparent,
          items: [
            BottomNavigationBarItem(
              icon: svgIcon("assets/icons/home-icon.svg"),
              activeIcon: svgIcon("assets/icons/home-icon.svg", color: primaryColor),
              label: "Accueil",
            ),
            BottomNavigationBarItem(
              icon: svgIcon("assets/icons/discover-icon.svg"),
              activeIcon:
              svgIcon("assets/icons/discover-icon.svg", color: primaryColor),
              label: "Découvrir",
            ),
            BottomNavigationBarItem(
              icon: svgIcon("assets/icons/cart-shop.svg"),
              activeIcon:
              svgIcon("assets/icons/cart-shop.svg", color: primaryColor),
              label: "Nos Produits",
            ),
            BottomNavigationBarItem(
              icon: _buildBottomNavCartIcon(false),
              activeIcon: _buildBottomNavCartIcon(true),
              label: "Panier",
            ),
            BottomNavigationBarItem(
              icon: svgIcon("assets/icons/user-icon.svg"),
              activeIcon:
              svgIcon("assets/icons/user-icon.svg", color: primaryColor),
              label: "Profil",
            ),
          ],
        ),
      ),
    );
  }

  // Widget pour l'icône du panier dans l'AppBar avec badge animé
  Widget _buildCartIconWithBadge() {
    return Stack(
      children: [
        IconButton(
          onPressed: () {
            setState(() {
              _currentIndex = 3; // index du CartScreen
            });
          },
          icon: SvgPicture.asset(
            "assets/icons/shopping-cart.svg",
            height: 24,
            colorFilter: ColorFilter.mode(
                Theme.of(context).textTheme.bodyLarge!.color!,
                BlendMode.srcIn),
          ),
        ),
        // Badge avec animation et mise à jour dynamique - POSITION CORRIGÉE
        if (cartCount > 0)
          Positioned(
            right: 4,
            top: 4,
            child: AnimatedSwitcher(
              duration: const Duration(milliseconds: 300),
              transitionBuilder: (Widget child, Animation<double> animation) {
                return ScaleTransition(scale: animation, child: child);
              },
              child: Container(
                key: ValueKey(cartCount), // Pour déclencher l'animation
                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                decoration: BoxDecoration(
                  color: Colors.red,
                  borderRadius: BorderRadius.circular(10),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.red.withOpacity(0.3),
                      spreadRadius: 1,
                      blurRadius: 3,
                      offset: const Offset(0, 1),
                    ),
                  ],
                ),
                constraints: const BoxConstraints(
                  minWidth: 18,
                  minHeight: 18,
                ),
                child: Text(
                  cartCount > 999 ? '999+' : cartCount > 99 ? '99+' : '$cartCount',
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 10,
                    fontWeight: FontWeight.bold,
                  ),
                  textAlign: TextAlign.center,
                ),
              ),
            ),
          ),
      ],
    );
  }

  // Widget pour l'icône du panier dans la BottomNavigationBar
  Widget _buildBottomNavCartIcon(bool isActive) {
    return Stack(
      children: [
        SvgPicture.asset(
          "assets/icons/shopping-cart.svg",
          height: 24,
          colorFilter: ColorFilter.mode(
            isActive
                ? primaryColor
                : Theme.of(context).iconTheme.color!.withOpacity(
                Theme.of(context).brightness == Brightness.dark ? 0.3 : 1),
            BlendMode.srcIn,
          ),
        ),
        // Badge pour la bottom navigation avec animation - POSITION CORRIGÉE
        if (cartCount > 0)
          Positioned(
            right: 0,
            top: 0,
            child: AnimatedSwitcher(
              duration: const Duration(milliseconds: 300),
              transitionBuilder: (Widget child, Animation<double> animation) {
                return ScaleTransition(scale: animation, child: child);
              },
              child: Container(
                key: ValueKey('bottom_$cartCount'), // Clé unique pour l'animation
                padding: const EdgeInsets.all(2),
                decoration: BoxDecoration(
                  color: Colors.red,
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                      color: Colors.red.withOpacity(0.3),
                      spreadRadius: 1,
                      blurRadius: 2,
                      offset: const Offset(0, 1),
                    ),
                  ],
                ),
                constraints: const BoxConstraints(
                  minWidth: 14,
                  minHeight: 14,
                ),
                child: Text(
                  cartCount > 99 ? '99+' : cartCount > 9 ? '9+' : '$cartCount',
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 8,
                    fontWeight: FontWeight.bold,
                  ),
                  textAlign: TextAlign.center,
                ),
              ),
            ),
          ),
      ],
    );
  }
}