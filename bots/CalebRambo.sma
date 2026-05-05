#include "core"
#include "math"
#include "bots"

fight() {
  new const FRIEND_WARRIOR = ITEM_FRIEND|ITEM_WARRIOR
  new const ENEMY_WARRIOR = ITEM_ENEMY|ITEM_WARRIOR
  new const ENEMY_GUN = ITEM_ENEMY|ITEM_GUN
  new const float:CHANGE_DIR_TIME = 20.0
  new const float:AVOID_WALL_DIR = 0.31415
  new float:headDir = 1.047
  new float:lastTime = getTime()
  rotate(3.1415)
  wait(2.0)
  if(getID()%2 == 0)
    crouch()
  wait(1.0)
  if(getID()%2 == 0)
    walkcr()
  else
    walk()
  wait(0.02)
  for(;;) {
    new float:thisTime = getTime()
    if(thisTime-lastTime > CHANGE_DIR_TIME) {
      lastTime = thisTime
      new float:randAngle = float(random(3)-1)*1.5758
      rotate(getDirection()+randAngle)
    } else if(isStanding()) {
      rotate(getDirection()+0.7854)
        
      new id = getID()
      if(id == 0) {
        stand()
      } else if(id == 1) {
        wait(0.5)
        walk()
      } else if(id == 2) {
        wait(0.5)
        walk()
      } else if(id == 3) {
        wait(0.5)
        walk()
      } else if(id == 4) {
        wait(0.5)
        walk()
      } else if(id == 5) {
        wait(0.5)
        walk()
      } else if(id == 6) {
        wait(0.5)
        walk()
      } else if(id == 7) {
        wait(0.5)
        walk()
      }

    } else if(sight() < 5.0) {
      rotate(getDirection()+AVOID_WALL_DIR)
    }
    new touched = getTouched()
    if(touched) raise(touched)
    new item = ENEMY_WARRIOR
    new float:dist = 0.0
    new float:yaw
    new float:pitch
    watch(item,dist,yaw,pitch)
    if(item == ENEMY_WARRIOR) {
      if(getID()%2 == 0) {
        new float:oldDist = dist
        new float:oldYaw = yaw
        new float:oldPitch =pitch
        item = ENEMY_WARRIOR
        watch(item,dist,yaw,pitch)
        if(item == ITEM_NONE) {
          item = ENEMY_WARRIOR
          dist = oldDist
          yaw = oldYaw
          pitch = oldPitch
        }
      }
      rotate(yaw+getDirection())
      bendTorso(pitch)
      bendHead(-pitch)
      rotateHead(0.0)
      if(getGrenadeLoad() > 0 && dist > 30 && dist < 60) {
        new aimItem
        aim(aimItem)
        if(aimItem != FRIEND_WARRIOR)
          launchGrenade()
      } else {
        new aimItem
        aim(aimItem)
        if(aimItem != FRIEND_WARRIOR)
          shootBullet()
      }
    }
    if(item != ENEMY_WARRIOR) {
      new sound
      dist = hear(item,sound,yaw)
      if(item == ENEMY_GUN) {
        rotate(yaw+getDirection())
        wait(0.5)
      } else {
        rotateHead(headDir)
        if(getHeadYaw() == headDir)
          headDir = -headDir
      }
    }
  }
}

main() {
  fight()
}

