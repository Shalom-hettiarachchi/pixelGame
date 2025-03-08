import 'dart:async';

import 'package:flame/components.dart';
import 'package:flame_tiled/flame_tiled.dart';
import 'package:mobilegame/components/background_tile.dart';
import 'package:mobilegame/components/collision_block.dart';
import 'package:mobilegame/components/fruit.dart';
import 'package:mobilegame/components/player.dart';
import 'package:mobilegame/components/saw.dart';
import 'package:mobilegame/pixel_game.dart';

class Level extends World with HasGameRef<PixelGame> {
  final String levelName;
  final Player player;

  Level({required this.levelName, required this.player});

  late TiledComponent level;
  List<CollisionBlock> collisionBlocks = [];

  @override
  FutureOr<void> onLoad() async {
    level = await TiledComponent.load('$levelName.tmx', Vector2.all(16));

    add(level);

    _scrollingBackground();
    _spawningObjects();
    _addCollisions();

    return super.onLoad();
  }

  void _scrollingBackground() {
    final backgroundLayer = level.tileMap.getLayer('Background');

    const tileSize = 64;

    final numTilesY = (game.size.y / tileSize).floor();
    final numTilesX = (game.size.x / tileSize).floor();

    if (backgroundLayer != null) {
      final backgroundColor =
          backgroundLayer.properties.getValue('backgroundColor');

      for (double y = 0; y < game.size.y / numTilesY; y++) {
        for(double x = 0; x < numTilesX; x++) {
          final backgroundTile = BackgroundTile(
          color: backgroundColor ?? 'Gray',
          position: Vector2(x * tileSize, y * tileSize - tileSize),
        );

        add(backgroundTile);
        }
        
      }
    }
  }

  void _spawningObjects() {
    final spawnpointslayer = level.tileMap.getLayer<ObjectGroup>('Spawnpoints');

    if (spawnpointslayer != null) {
      for (final spawnPoint in spawnpointslayer.objects) {
        switch (spawnPoint.class_) {
          case 'Player':
            player.position = Vector2(spawnPoint.x, spawnPoint.y);
            add(player);
            break;
          case 'Fruit':
          final fruit = Fruit(
            fruit: spawnPoint.name,
            position: Vector2(spawnPoint.x, spawnPoint.y),
            size: Vector2(spawnPoint.width, spawnPoint.height),
          );
          add(fruit);
          break;
          case 'Saw':
          final isVertical =  spawnPoint.properties.getValue('isVertical');
          final offneg =  spawnPoint.properties.getValue('offneg');
          final offpos =  spawnPoint.properties.getValue('offpos');
          final saw = Saw(
            isVertical: isVertical,
            offpos: offpos,
            offneg: offneg,
            position: Vector2(spawnPoint.x, spawnPoint.y),
            size: Vector2(spawnPoint.width, spawnPoint.height),
          );
          add(saw);
          break;
          default:
        }
      }
    }
  }

  void _addCollisions() {
    final collisionsLayer = level.tileMap.getLayer<ObjectGroup>('Collisions');

    if (collisionsLayer != null) {
      for (final collision in collisionsLayer.objects) {
        switch (collision.class_) {
          case 'Platforms':
            final platform = CollisionBlock(
              position: Vector2(collision.x, collision.y),
              size: Vector2(collision.width, collision.height),
              isPlatform: true,
            );
            collisionBlocks.add(platform);
            add(platform);
            break;
          default:
            final block = CollisionBlock(
              position: Vector2(collision.x, collision.y),
              size: Vector2(collision.width, collision.height),
            );
            collisionBlocks.add(block);
            add(block);
        }
      }
    }
    player.collisionBlocks = collisionBlocks;
  }
}
