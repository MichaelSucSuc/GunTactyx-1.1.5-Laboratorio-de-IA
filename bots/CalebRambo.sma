#include "core"
#include "math"
#include "bots"

fight() {
  rotate(3.1415)
  wait(0.02)

  rotate(getDirection() + 0.7854)
  new id = getID()
  if(id == 0) {
    stand()
  } else if(id == 1) {
    stand()
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

  new float:lastSpeakTime = 0.0 
  new const float:SPEAK_COOLDOWN = 0.25
  for(;;) {
    new float:thisTime = getTime()

    //el lider se queda siempre en la base, para defender
    if(id == 0) {//el lider se queda siempre en la base, para defender
      rambear()
    }
    // --- ID 1: Vigía inicial - detecta enemigos y habla ---
    if(getID() == 1) {
      movilizar()
      new const ENEMY_WARRIOR = ITEM_ENEMY | ITEM_WARRIOR
      new item = ENEMY_WARRIOR
      new float:dist, float:yaw, float:pitch
      watch(item, dist, yaw, pitch)
      if(item == ENEMY_WARRIOR && (thisTime - lastSpeakTime > SPEAK_COOLDOWN)) {
        print("ID 1: Enemigo visto, avisando a ID 2\n")
        speak(1, 1)          // Canal 1, palabra 1
        lastSpeakTime = thisTime
      }
    }

    // --- ID 2: Escucha a ID 1, ataca y avisa a ID 3 ---
    if(getID() == 2) {
      new word, sender_id
      if(listen(1, word, sender_id)) {
        if(word == 1) {
          print("ID 2: Orden recibida de ID 1, ATACANDO\n")
          movilizar()
          rambear()
        }
      }
      // Avisar al ID 3 si está en combate
      new const ENEMY_WARRIOR = ITEM_ENEMY | ITEM_WARRIOR
      new item = ENEMY_WARRIOR
      new float:dist, float:yaw, float:pitch
      watch(item, dist, yaw, pitch)
      if(item == ENEMY_WARRIOR && (thisTime - lastSpeakTime > SPEAK_COOLDOWN)) {
        print("ID 2: Enemigo visto, avisando a ID 3\n")
        speak(2, 2)          // Canal 2, palabra 2
        lastSpeakTime = thisTime
      }
    }

    // --- ID 3: Escucha a ID 2, ataca y avisa a ID 4 ---
    if(getID() == 3) {
      new word, sender_id
      if(listen(2, word, sender_id)) {
        if(word == 2) {
          print("ID 3: Orden recibida de ID 2, ATACANDO\n")
          movilizar()
          rambear()
        }
      }
      new const ENEMY_WARRIOR = ITEM_ENEMY | ITEM_WARRIOR
      new item = ENEMY_WARRIOR
      new float:dist, float:yaw, float:pitch
      watch(item, dist, yaw, pitch)
      if(item == ENEMY_WARRIOR && (thisTime - lastSpeakTime > SPEAK_COOLDOWN)) {
        print("ID 3: Enemigo visto, avisando a ID 4\n")
        speak(3, 3)          // Canal 3, palabra 3
        lastSpeakTime = thisTime
      }
    }

    // --- ID 4: Escucha a ID 3, ataca y avisa a ID 5 ---
    if(getID() == 4) {
      new word, sender_id
      if(listen(3, word, sender_id)) {
        if(word == 3) {
          print("ID 4: Orden recibida de ID 3, ATACANDO\n")
          movilizar()
          rambear()
        }
      }
      new const ENEMY_WARRIOR = ITEM_ENEMY | ITEM_WARRIOR
      new item = ENEMY_WARRIOR
      new float:dist, float:yaw, float:pitch
      watch(item, dist, yaw, pitch)
      if(item == ENEMY_WARRIOR && (thisTime - lastSpeakTime > SPEAK_COOLDOWN)) {
        print("ID 4: Enemigo visto, avisando a ID 5\n")
        speak(4, 4)          // Canal 4, palabra 4
        lastSpeakTime = thisTime
      }
    }

    // --- ID 5: Escucha a ID 4, ataca y avisa a ID 6 ---
    if(getID() == 5) {
      new word, sender_id
      if(listen(4, word, sender_id)) {
        if(word == 4) {
          print("ID 5: Orden recibida de ID 4, ATACANDO\n")
          movilizar()
          rambear()
        }
      }
      new const ENEMY_WARRIOR = ITEM_ENEMY | ITEM_WARRIOR
      new item = ENEMY_WARRIOR
      new float:dist, float:yaw, float:pitch
      watch(item, dist, yaw, pitch)
      if(item == ENEMY_WARRIOR && (thisTime - lastSpeakTime > SPEAK_COOLDOWN)) {
        print("ID 5: Enemigo visto, avisando a ID 6\n")
        speak(5, 5)          // Canal 5, palabra 5
        lastSpeakTime = thisTime
      }
    }

    // --- ID 6: Escucha a ID 5, ataca y avisa a ID 7 ---
    if(getID() == 6) {
      new word, sender_id
      if(listen(5, word, sender_id)) {
        if(word == 5) {
          print("ID 6: Orden recibida de ID 5, ATACANDO\n")
          movilizar()
          rambear()
        }
      }
      new const ENEMY_WARRIOR = ITEM_ENEMY | ITEM_WARRIOR
      new item = ENEMY_WARRIOR
      new float:dist, float:yaw, float:pitch
      watch(item, dist, yaw, pitch)
      if(item == ENEMY_WARRIOR && (thisTime - lastSpeakTime > SPEAK_COOLDOWN)) {
        print("ID 6: Enemigo visto, avisando a ID 7\n")
        speak(6, 6)          // Canal 6, palabra 6
        lastSpeakTime = thisTime
      }
    }

    // --- ID 7: Escucha a ID 6, ataca (es el último, no avisa a nadie) ---
    if(getID() == 7) {
      new word, sender_id
      if(listen(6, word, sender_id)) {
        if(word == 6) {
          print("ID 7: Orden recibida de ID 6, ATACANDO\n")
          movilizar()
          rambear()
        }
      }
      // ID 7 también puede atacar por sí mismo
      new const ENEMY_WARRIOR = ITEM_ENEMY | ITEM_WARRIOR
      new item = ENEMY_WARRIOR
      new float:dist, float:yaw, float:pitch
      watch(item, dist, yaw, pitch)
      if(item == ENEMY_WARRIOR && (thisTime - lastSpeakTime > SPEAK_COOLDOWN)) {
        print("ID 7: Enemigo visto, ATACANDO DIRECTAMENTE\n")
        movilizar()
        rambear()
      }
    }
  }
}


rambear() {
  print("Rambeamos")
  // Declarar constantes que usa la función
  new const FRIEND_WARRIOR = ITEM_FRIEND | ITEM_WARRIOR
  new const ENEMY_WARRIOR = ITEM_ENEMY | ITEM_WARRIOR
  new const ENEMY_GUN = ITEM_ENEMY | ITEM_GUN
  
  // Declarar variable local para controlar la rotación de la cabeza
  new float:headDir = 1.047   // 60 grados en radianes
  // cuerpo de la función
  new touched = getTouched()
  if(touched) raise(touched)
  new item = ENEMY_WARRIOR
  new float:dist = 0.0
  new float:yaw
  new float:pitch
  watch(item,dist,yaw,pitch)
  if(item == ENEMY_WARRIOR) {
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

movilizar(){
  new const float:CHANGE_DIR_TIME = 20.0
  new const float:AVOID_WALL_DIR = 0.31415
  static float:lastTime = 0.0
  new float:thisTime = getTime()
  // --- Movimiento y cambio de dirección ---
  if(thisTime-lastTime > CHANGE_DIR_TIME) {
    lastTime = thisTime
    new float:randAngle = float(random(3)-1)*1.5758
    rotate(getDirection()+randAngle)
  } else if(isStanding()) {
    rotate(getDirection()+0.7854)
    if(getID()%2 == 0) {
      wait(0.5)
      crouch()
      wait(1.0)
      walkcr()
    } else {
      walk()
    }
  } else if(sight() < 5.0) {
    rotate(getDirection()+AVOID_WALL_DIR)
  }
}

main() {
  fight()
}
