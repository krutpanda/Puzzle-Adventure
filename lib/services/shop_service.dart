import 'dart:async';
import 'package:shared_preferences.dart';

enum SubscriptionTier {
  free,
  basic,
  premium,
  vip
}

enum PowerUpType {
  timeFreeze,
  hint,
  shuffle,
  undo,
  colorBomb,
  lineClear
}

class PowerUp {
  final PowerUpType type;
  final String name;
  final String description;
  final int cost;
  final int duration;
  final bool isConsumable;

  const PowerUp({
    required this.type,
    required this.name,
    required this.description,
    required this.cost,
    required this.duration,
    required this.isConsumable,
  });
}

class ShopItem {
  final String id;
  final String name;
  final String description;
  final int cost;
  final bool isSubscriptionOnly;
  final SubscriptionTier requiredTier;

  const ShopItem({
    required this.id,
    required this.name,
    required this.description,
    required this.cost,
    this.isSubscriptionOnly = false,
    this.requiredTier = SubscriptionTier.free,
  });
}

class ShopService {
  static const String _inventoryKey = 'player_inventory';
  static const String _subscriptionKey = 'subscription_status';
  late SharedPreferences _prefs;
  
  final _inventoryController = StreamController<Map<String, int>>.broadcast();
  final _subscriptionController = StreamController<SubscriptionTier>.broadcast();
  
  Map<String, int> _inventory = {};
  SubscriptionTier _currentTier = SubscriptionTier.free;

  // Singleton pattern
  static final ShopService _instance = ShopService._internal();
  factory ShopService() => _instance;
  ShopService._internal();

  static final Map<PowerUpType, PowerUp> powerUps = {
    PowerUpType.timeFreeze: PowerUp(
      type: PowerUpType.timeFreeze,
      name: 'Time Freeze',
      description: 'Pause the timer for 10 seconds',
      cost: 100,
      duration: 10,
      isConsumable: true,
    ),
    PowerUpType.hint: PowerUp(
      type: PowerUpType.hint,
      name: 'Hint',
      description: 'Highlight a possible move',
      cost: 50,
      duration: 0,
      isConsumable: true,
    ),
    PowerUpType.shuffle: PowerUp(
      type: PowerUpType.shuffle,
      name: 'Shuffle',
      description: 'Rearrange all pieces on the board',
      cost: 150,
      duration: 0,
      isConsumable: true,
    ),
    PowerUpType.undo: PowerUp(
      type: PowerUpType.undo,
      name: 'Undo',
      description: 'Reverse your last move',
      cost: 75,
      duration: 0,
      isConsumable: true,
    ),
    PowerUpType.colorBomb: PowerUp(
      type: PowerUpType.colorBomb,
      name: 'Color Bomb',
      description: 'Remove all pieces of a selected color',
      cost: 200,
      duration: 0,
      isConsumable: true,
    ),
    PowerUpType.lineClear: PowerUp(
      type: PowerUpType.lineClear,
      name: 'Line Clear',
      description: 'Clear an entire row or column',
      cost: 175,
      duration: 0,
      isConsumable: true,
    ),
  };

  static final List<ShopItem> subscriptionBenefits = [
    ShopItem(
      id: 'daily_coins',
      name: 'Daily Coins',
      description: 'Get 100 coins every day',
      cost: 0,
      isSubscriptionOnly: true,
      requiredTier: SubscriptionTier.basic,
    ),
    ShopItem(
      id: 'premium_themes',
      name: 'Premium Themes',
      description: 'Access to exclusive game themes',
      cost: 0,
      isSubscriptionOnly: true,
      requiredTier: SubscriptionTier.premium,
    ),
    ShopItem(
      id: 'vip_powerups',
      name: 'VIP Power-ups',
      description: 'Special power-ups for VIP members',
      cost: 0,
      isSubscriptionOnly: true,
      requiredTier: SubscriptionTier.vip,
    ),
  ];

  Future<void> initialize() async {
    _prefs = await SharedPreferences.getInstance();
    await _loadInventory();
    await _loadSubscription();
  }

  Stream<Map<String, int>> get inventoryStream => _inventoryController.stream;
  Stream<SubscriptionTier> get subscriptionStream => _subscriptionController.stream;

  Future<void> _loadInventory() async {
    final savedInventory = _prefs.getString(_inventoryKey);
    if (savedInventory != null) {
      _inventory = Map<String, int>.from(
        // ignore: unnecessary_cast
        (const JsonDecoder().convert(savedInventory) as Map),
      );
    }
    _inventoryController.add(_inventory);
  }

  Future<void> _loadSubscription() async {
    final savedTier = _prefs.getString(_subscriptionKey);
    if (savedTier != null) {
      _currentTier = SubscriptionTier.values.firstWhere(
        (t) => t.toString() == savedTier,
        orElse: () => SubscriptionTier.free,
      );
    }
    _subscriptionController.add(_currentTier);
  }

  Future<void> saveInventory() async {
    await _prefs.setString(
      _inventoryKey,
      const JsonEncoder().convert(_inventory),
    );
  }

  Future<void> saveSubscription() async {
    await _prefs.setString(
      _subscriptionKey,
      _currentTier.toString(),
    );
  }

  bool hasPowerUp(PowerUpType type) {
    return (_inventory[type.toString()] ?? 0) > 0;
  }

  Future<bool> usePowerUp(PowerUpType type) async {
    if (!hasPowerUp(type)) return false;

    _inventory[type.toString()] = (_inventory[type.toString()] ?? 0) - 1;
    _inventoryController.add(_inventory);
    await saveInventory();
    return true;
  }

  Future<bool> purchasePowerUp(PowerUpType type, {int quantity = 1}) async {
    final powerUp = powerUps[type];
    if (powerUp == null) return false;

    // Here you would integrate with your actual payment system
    // For now, we'll just add it to the inventory
    _inventory[type.toString()] = (_inventory[type.toString()] ?? 0) + quantity;
    _inventoryController.add(_inventory);
    await saveInventory();
    return true;
  }

  Future<bool> updateSubscription(SubscriptionTier tier) async {
    // Here you would integrate with your actual subscription system
    _currentTier = tier;
    _subscriptionController.add(_currentTier);
    await saveSubscription();
    return true;
  }

  bool canAccessFeature(SubscriptionTier requiredTier) {
    return _currentTier.index >= requiredTier.index;
  }

  Future<void> giftPowerUp(String friendId, PowerUpType type) async {
    if (!hasPowerUp(type)) return;

    // Here you would integrate with your friend system
    await usePowerUp(type);
    // Add power-up to friend's inventory through your backend
  }

  void dispose() {
    _inventoryController.close();
    _subscriptionController.close();
  }
} 