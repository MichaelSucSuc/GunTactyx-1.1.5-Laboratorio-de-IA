// Estrategia: Caleb (vigía) + Rambos (atacantes)
// Equipo: 4 bots — ID0=Jefe, ID1=Caleb, ID2=Rambo1, ID3=Rambo2
//
// Flujo:
//   1. Jefe manda a Caleb con say(1)
//   2. Caleb avanza SIN disparar, al ver enemigo hace say(2) y regresa
//   3. Si Caleb muere, el jefe escucha disparos enemigos con hear() y manda a Rambo hacia allá
//   4. Rambo1 sale primero, si muere sale Rambo2

#include "core"
#include "math"
#include "bots"

new const FRIEND_WARRIOR = ITEM_FRIEND|ITEM_WARRIOR
new const ENEMY_WARRIOR  = ITEM_ENEMY|ITEM_WARRIOR
new const ENEMY_GUN      = ITEM_ENEMY|ITEM_GUN

new const SIGNAL_GO      = 1   // jefe → Caleb: "sal a explorar"
new const SIGNAL_REPORT  = 2   // Caleb → jefe: "vi enemigos, ataca aquí"
new const SIGNAL_RAMBO1  = 3   // jefe → Rambo1: "tu turno"
new const SIGNAL_RAMBO2  = 4   // jefe → Rambo2: "tu turno"

new const float:WALL_DIST       = 3.0   // distancia mínima a pared
new const float:CALEB_TIMEOUT   = 20.0  // tiempo máximo que espera el jefe a Caleb
new const float:RAMBO_TIMEOUT   = 25.0  // tiempo que espera antes de mandar al siguiente Rambo

// ── JEFE (ID 0) ──────────────────────────────────────────────────
rolJefe() {
    new item
    new sound
    new float:yaw
    new float:dirAtaque

    // Mandar a Caleb
    say(SIGNAL_GO)

    // Esperar reporte de Caleb o detectar que murió por disparos enemigos
    new float:inicio = getTime()
    new bool:reporteRecibido = false

    for(;;) {
        // Timeout: Caleb tardó demasiado → asumir muerto
        if(getTime() - inicio > CALEB_TIMEOUT)
            break

        item = 0
        new float:dist = hear(item, sound, yaw)

        // Caleb reportó exitosamente
        if(item == FRIEND_WARRIOR && sound == SIGNAL_REPORT) {
            dirAtaque = getDirection() + yaw
            reporteRecibido = true
            break
        }

        // Caleb murió: se escuchan disparos enemigos → esa es la dirección
        if(item == ENEMY_GUN) {
            dirAtaque = getDirection() + yaw
            break
        }
    }

    // Apuntar hacia donde están los enemigos
    rotate(dirAtaque)
    wait(0.3)

    // Mandar a Rambo1
    say(SIGNAL_RAMBO1)

    // Esperar a Rambo1 (si no regresa en RAMBO_TIMEOUT, asumir muerto)
    new float:esperaRambo = getTime()
    for(;;) {
        if(getTime() - esperaRambo > RAMBO_TIMEOUT)
            break
        item = 0
        hear(item, sound, yaw)
        // Si se deja de oír actividad enemiga, Rambo puede haber limpiado la zona
        if(item == FRIEND_WARRIOR && sound == SIGNAL_REPORT)
            break
    }

    // Mandar a Rambo2
    say(SIGNAL_RAMBO2)

    // El jefe se queda en guardia disparando lo que vea
    new float:headDir = 1.047
    for(;;) {
        new float:dist = 0.0
        item = ENEMY_WARRIOR
        new float:eyaw
        new float:pitch
        watch(item, dist, eyaw, pitch)
        if(item == ENEMY_WARRIOR) {
            rotate(eyaw + getDirection())
            bendTorso(pitch)
            bendHead(-pitch)
            rotateHead(0.0)
            new aimItem
            aim(aimItem)
            if(aimItem != FRIEND_WARRIOR)
                shootBullet()
        } else {
            rotateHead(headDir)
            if(getHeadYaw() == headDir)
                headDir = -headDir
        }
    }
}

// ── CALEB — VIGÍA (ID 1) ─────────────────────────────────────────
rolCaleb() {
    new item
    new sound
    new float:yaw

    // Esperar orden del jefe
    do {
        item = 0
        hear(item, sound, yaw)
    } while(sound != SIGNAL_GO)

    // Salir en dirección opuesta al jefe (adentrarse al laberinto)
    new float:giro = 3.1415
    if(yaw > 0) giro = -giro
    rotate(getDirection() + yaw + giro)
    wait(0.5)
    walk()

    // Avanzar SIN disparar — solo buscar con los ojos
    new float:headDir = 1.047
    for(;;) {
        // Evasión de paredes
        if(isStanding()) {
            rotate(getDirection() + 1.5708)
            wait(0.5)
            walk()
        } else if(sight() < WALL_DIST) {
            new float:evade = (getID()%2 == 0) ? 0.5236 : -0.5236
            rotate(getDirection() + evade)
        }

        // Recoger powerups
        new touched = getTouched()
        if(touched) raise(touched)

        // Buscar enemigo — SOLO MIRAR, no disparar
        item = ENEMY_WARRIOR
        new float:dist = 0.0
        new float:eyaw
        new float:pitch
        watch(item, dist, eyaw, pitch)

        if(item == ENEMY_WARRIOR) {
            // ¡Enemigo visto! Reportar al jefe y regresar
            say(SIGNAL_REPORT)
            wait(0.3)

            // Dar media vuelta y correr de regreso
            rotate(getDirection() + 3.1415)
            wait(0.5)
            run()

            // Regresar durante 10 segundos esquivando paredes
            new float:regreso = getTime()
            for(;;) {
                if(getTime() - regreso > 10.0)
                    break
                if(isStanding()) {
                    rotate(getDirection() + 1.5708)
                    wait(0.5)
                    run()
                } else if(sight() < WALL_DIST) {
                    rotate(getDirection() + 0.5236)
                }
                new t = getTouched()
                if(t) raise(t)
            }

            // Ya regresó — quedarse quieto en guardia SIN disparar
            walk()
            for(;;) {
                new t = getTouched()
                if(t) raise(t)
                rotateHead(headDir)
                if(getHeadYaw() == headDir)
                    headDir = -headDir
            }
        }

        // Girar cabeza para ampliar campo visual
        rotateHead(headDir)
        if(getHeadYaw() == headDir)
            headDir = -headDir
    }
}

// ── FUNCIÓN COMPARTIDA: lógica de ataque para Rambos ─────────────
atacar(float:dirInicial) {
    rotate(dirInicial)
    wait(0.5)
    run()

    new float:headDir = 1.047
    for(;;) {
        // Evasión de paredes
        if(isStanding()) {
            rotate(getDirection() + 1.5708)
            wait(0.5)
            run()
        } else if(sight() < WALL_DIST) {
            new float:evade = (getID()%2 == 0) ? 0.5236 : -0.5236
            rotate(getDirection() + evade)
        }

        new touched = getTouched()
        if(touched) raise(touched)

        // Buscar y atacar enemigos
        new item = ENEMY_WARRIOR
        new float:dist = 0.0
        new float:eyaw
        new float:pitch
        watch(item, dist, eyaw, pitch)

        if(item == ENEMY_WARRIOR) {
            rotate(eyaw + getDirection())
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
        } else {
            // Oír disparos y girar hacia ellos
            new sound
            new float:syaw
            new sitem = ENEMY_GUN
            hear(sitem, sound, syaw)
            if(sitem == ENEMY_GUN) {
                rotate(syaw + getDirection())
                wait(0.3)
            } else {
                rotateHead(headDir)
                if(getHeadYaw() == headDir)
                    headDir = -headDir
            }
        }
    }
}

// ── RAMBO 1 (ID 2) ───────────────────────────────────────────────
rolRambo1() {
    new item
    new sound
    new float:yaw

    // Esperar señal del jefe
    do {
        item = 0
        hear(item, sound, yaw)
    } while(sound != SIGNAL_RAMBO1)

    // Salir en dirección opuesta al jefe
    new float:giro = 3.1415
    if(yaw > 0) giro = -giro
    new float:dir = getDirection() + yaw + giro

    atacar(dir)
}

// ── RAMBO 2 (ID 3) ───────────────────────────────────────────────
rolRambo2() {
    new item
    new sound
    new float:yaw

    // Esperar señal del jefe
    do {
        item = 0
        hear(item, sound, yaw)
    } while(sound != SIGNAL_RAMBO2)

    // Salir en dirección opuesta al jefe
    new float:giro = 3.1415
    if(yaw > 0) giro = -giro
    new float:dir = getDirection() + yaw + giro

    atacar(dir)
}

// ── FIGHT ─────────────────────────────────────────────────────────
fight() {
    switch(getID()) {
        case 0: rolJefe()
        case 1: rolCaleb()
        case 2: rolRambo1()
        case 3: rolRambo2()
    }
}

// ── SOCCER (básico) ───────────────────────────────────────────────
soccer() {
    new const float:PI = 3.1415
    new const float:AVOID_WALL_DIR = (getID()%2 == 0? PI/10.0: -PI/10.0)
    new const float:CHANGE_DIR_TIME = 10.0
    new float:lastTime = getTime()
    rotate(getDirection()+PI*2.0)
    new float:dist
    new float:yaw
    new item
    do {
        item = ITEM_TARGET
        dist = 0.0
        watch(item,dist,yaw)
    } while(item != ITEM_TARGET)
    rotate(getDirection()+yaw)
    setKickSpeed(getMaxKickSpeed())
    bendTorso(0.3)
    bendHead(-0.3)
    new float:waitTime = 3-getTime()+lastTime
    if(waitTime > 0) wait(waitTime)
    walk()
    wait(0.1)
    for(;;) {
        new float:thisTime = getTime()
        if(thisTime-lastTime > CHANGE_DIR_TIME) {
            lastTime = thisTime
            rotate(getDirection()+(float(random(2))-0.5)*PI)
        } else if(isStanding()) {
            rotate(getDirection()+(float(random(2))-0.5)*PI)
            wait(1.0)
            walk()
        } else if(sight() < 2.0) {
            rotate(getDirection()+AVOID_WALL_DIR)
        }
        new touched = getTouched()
        if(touched) raise(touched)
        item = ITEM_TARGET
        dist = 0.0
        watch(item,dist,yaw)
        if(item == ITEM_TARGET) {
            rotate(yaw+getDirection())
            if(isWalking()) run()
        }
    }
}

// ── MAIN ──────────────────────────────────────────────────────────
main() {
    switch(getPlay()) {
        case PLAY_FIGHT:  fight()
        case PLAY_SOCCER: soccer()
        case PLAY_RACE:   fight()
    }
}