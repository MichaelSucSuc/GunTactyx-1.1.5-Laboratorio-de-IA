#include "core"
#include "math"
#include "bots"

fight() {
  rotate(3.1415)
  wait(0.02)
  rotate(getDirection() + 0.7854)
  new id = getID()
  static float:ultimoLatido = 0.0;
  static bool:soldadoActivo = false;

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
      //new int:ramboactivo = 0
      rambear()
      //ordena que salga el explorador
      speak(0, 1)          // Canal 0, palabra 1

      //si escucha que id 1 encontro algo mandamos a rambo 2(primer rambo)
      new word, sender_id
      // Escucha a los soldados y activa al siguiente
      if(listen(1, word, sender_id)) {
        if(word == 1) {
          speak(0, 2)
          soldadoActivo = true;
          ultimoLatido = getTime();
        }
      }
      if(soldadoActivo) {
        new sender;
        if(listen(2, word, sender) && word == 99) {
          ultimoLatido = getTime();   // recibió latido, actualiza
        }
        if(getTime() - ultimoLatido > 6.0) {
          // El soldado murió
          soldadoActivo = false;
          // Activar al siguiente...
          print("se activo el soldado 3")
          speak(0, 3)
        }
      }
    }

    // --- ID 1: Vigía inicial - detecta enemigos y habla ---
    if(getID() == 1) {
      //escucha la orden del jefe
      new word, sender_id
      if(listen(0, word, sender_id)) {
        if(word == 1) {
          movilizar()
        }
      }
      //decir, enemigo visto
      new const ENEMY_WARRIOR = ITEM_ENEMY | ITEM_WARRIOR
      new item = ENEMY_WARRIOR
      new float:dist, float:yaw, float:pitch
      watch(item, dist, yaw, pitch)
      if(item == ENEMY_WARRIOR && (thisTime - lastSpeakTime > SPEAK_COOLDOWN)) {
        speak(1, 1)          // Canal 1, palabra 1
        lastSpeakTime = thisTime
      }
    }

    // --- ID 2: Escucha a ID 1, ataca y avisa a ID 3 ---
    if(getID() == 2) {
      static float:ultimoEnvio = 0.0;
      if(getTime() - ultimoEnvio > 5.0) {
          speak(2, 99);   // Envía "estoy vivo" por el canal 2
          ultimoEnvio = getTime();
      }
      //escucha la orden del jefe
      new word, sender_id
      if(listen(0, word, sender_id)) {
        if(word == 2) {
          movilizar()
          rambear()
        }
      }
    }

    // --- ID 3: Escucha a ID 2, ataca y avisa a ID 4 ---
    if(getID() == 3) {
      //escucha la orden del jefe
      new word, sender_id
      if(listen(0, word, sender_id)) {
        if(word == 3) {
          movilizar()
          rambear()
        }
      }
      // Avisar al jefe si está en combate
      new const ENEMY_WARRIOR = ITEM_ENEMY | ITEM_WARRIOR
      new item = ENEMY_WARRIOR
      new float:dist, float:yaw, float:pitch
      watch(item, dist, yaw, pitch)
      if(item == ENEMY_WARRIOR && (thisTime - lastSpeakTime > SPEAK_COOLDOWN)) {
        speak(3, 3)          // Canal 3, palabra 3
        lastSpeakTime = thisTime
      }
    }

    // --- ID 4: Escucha a ID 3, ataca y avisa a ID 5 ---
    if(getID() == 4) {
      //escucha la orden del jefe
      new word, sender_id
      if(listen(0, word, sender_id)) {
        if(word == 4) {
          movilizar()
          rambear()
        }
      }
      // Avisar al jefe si está en combate
      new const ENEMY_WARRIOR = ITEM_ENEMY | ITEM_WARRIOR
      new item = ENEMY_WARRIOR
      new float:dist, float:yaw, float:pitch
      watch(item, dist, yaw, pitch)
      if(item == ENEMY_WARRIOR && (thisTime - lastSpeakTime > SPEAK_COOLDOWN)) {
        speak(4, 4)          // Canal 3, palabra 3
        lastSpeakTime = thisTime
      }
    }

    // --- ID 5: Escucha a ID 4, ataca y avisa a ID 6 ---
    if(getID() == 5) {
      //escucha la orden del jefe
      new word, sender_id
      if(listen(0, word, sender_id)) {
        if(word == 5) {
          movilizar()
          rambear()
        }
      }
      // Avisar al jefe si está en combate
      new const ENEMY_WARRIOR = ITEM_ENEMY | ITEM_WARRIOR
      new item = ENEMY_WARRIOR
      new float:dist, float:yaw, float:pitch
      watch(item, dist, yaw, pitch)
      if(item == ENEMY_WARRIOR && (thisTime - lastSpeakTime > SPEAK_COOLDOWN)) {
        speak(5, 5)          // Canal 5, palabra 5
        lastSpeakTime = thisTime
      }
    }

    // --- ID 6: Escucha a ID 5, ataca y avisa a ID 7 ---
    if(getID() == 6) {
      //escucha la orden del jefe
      new word, sender_id
      if(listen(0, word, sender_id)) {
        if(word == 6) {
          movilizar()
          rambear()
        }
      }
      // Avisar al jefe si está en combate
      new const ENEMY_WARRIOR = ITEM_ENEMY | ITEM_WARRIOR
      new item = ENEMY_WARRIOR
      new float:dist, float:yaw, float:pitch
      watch(item, dist, yaw, pitch)
      if(item == ENEMY_WARRIOR && (thisTime - lastSpeakTime > SPEAK_COOLDOWN)) {
        speak(6, 6)          // Canal 5, palabra 5
        lastSpeakTime = thisTime
      }
    }

    // --- ID 7: Escucha a ID 6, ataca (es el último, no avisa a nadie) ---
    if(getID() == 7) {
      new word, sender_id
      if(listen(0, word, sender_id)) {
        if(word == 7) {
          movilizar()
          rambear()
        }
      }
      new const ENEMY_WARRIOR = ITEM_ENEMY | ITEM_WARRIOR
      new item = ENEMY_WARRIOR
      new float:dist, float:yaw, float:pitch
      watch(item, dist, yaw, pitch)
      if(item == ENEMY_WARRIOR && (thisTime - lastSpeakTime > SPEAK_COOLDOWN)) {
        speak(7, 7)          // Canal 6, palabra 6
        lastSpeakTime = thisTime
      }
    }
  }
}


rambear() {
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
