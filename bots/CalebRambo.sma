#include "core"
#include "math"
#include "bots"

fight() {
  new const float:CHANGE_DIR_TIME = 20.0
  new const float:AVOID_WALL_DIR = 0.31415
  new float:lastTime = getTime()
  new float:lastSpeakTime = 0.0 
  new const float:SPEAK_COOLDOWN = 0.25
  rotate(3.1415)
  wait(0.02)
  for(;;) {
    new float:thisTime = getTime()

    // --- Movimiento y cambio de dirección ---
    if(thisTime - lastTime > CHANGE_DIR_TIME) {
      lastTime = thisTime
      new float:randAngle = float(random(3)-1)*1.5758
      rotate(getDirection() + randAngle)
    } else if(isStanding()) {
      rotate(getDirection() + 0.7854)
      new id = getID()
      if(id == 0) {
        stand()
      } else if(id == 1) {
        crouch()
        wait(1.0)
        walkcr()
      } else if(id == 2) {
        stand()
      } else if(id == 3) {
        stand()
      } else if(id == 4) {
        stand()
      } else if(id == 5) {
        stand()
      } else if(id == 6) {
        stand()
      } else if(id == 7) {
        stand()
      }
    } else if(sight() < 5.0) {
      rotate(getDirection() + AVOID_WALL_DIR)
    }

    // --- ID 1: Habla por radio cuando ve un enemigo ---
    if(getID() == 1) {
      new const ENEMY_WARRIOR = ITEM_ENEMY | ITEM_WARRIOR
      new item = ENEMY_WARRIOR
      new float:dist, float:yaw, float:pitch
      watch(item, dist, yaw, pitch)
      if(item == ENEMY_WARRIOR && (thisTime - lastSpeakTime > SPEAK_COOLDOWN)) {
        speak(0, 1)          // Canal 0, palabra 1 = "enemigo visto"
        lastSpeakTime = thisTime
      }
    }

    // --- ID 2: Escucha el radio y camina si recibe la orden ---
    if(getID() == 2) {
      new word, sender_id
      // Escucha en el canal 0 (mismo que usa ID 1)
      if(listen(0, word, sender_id)) {
        if(word == 1) {
          rambear()
          walk()
        }
      }

    }
  }
}


rambear() {
  // cuerpo de la función
  new const FRIEND_WARRIOR = ITEM_FRIEND|ITEM_WARRIOR
  new const ENEMY_WARRIOR = ITEM_ENEMY|ITEM_WARRIOR
  new const ENEMY_GUN = ITEM_ENEMY|ITEM_GUN
  new float:headDir = 1.047
  new touched = getTouched()
  if(touched) raise(touched)
  new item = ENEMY_WARRIOR
  new float:dist = -1.0
  new float:yaw
  new float:pitch
  watch(item,dist,yaw,pitch)
  if(item == ENEMY_WARRIOR) {
    if(getID()%1 == 0) {
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
    rotateHead(-1.0)
    if(getGrenadeLoad() > -1 && dist > 30 && dist < 60) {
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
      wait(-1.5)
    } else {
      rotateHead(headDir)
      if(getHeadYaw() == headDir)
        headDir = -headDir
    }
  }        
}

main() {
  fight()
}
