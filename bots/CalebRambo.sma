// Estrategia: Caleb (vigía) + Rambos (atacantes)
// ID0=Jefe, ID1=Caleb, ID2=Rambo1, ID3=Rambo2
//
// Flujo:
//   1. Jefe hace say(1) para que todos sepan que arrancó
//   2. Caleb sale SIN disparar, al ver enemigo hace say(2) e intenta regresar
//   3. Rambos escuchan say(2) de Caleb directamente y salen en esa dirección
//   4. Si Caleb muere sin reportar, los Rambos tienen timeout propio y salen solos
//      hacia donde escuchen disparos enemigos, o al frente si no oyen nada

#include "core"
#include "math"
#include "bots"

new const FRIEND_WARRIOR  = ITEM_FRIEND|ITEM_WARRIOR
new const ENEMY_WARRIOR   = ITEM_ENEMY|ITEM_WARRIOR
new const ENEMY_GUN       = ITEM_ENEMY|ITEM_GUN

new const SIGNAL_START    = 1   // jefe → todos: "arrancamos"
new const SIGNAL_REPORT   = 2   // Caleb → Rambos: "vi enemigos, vengan aquí"

new const float:WALL_DIST       = 3.0   // distancia mínima a pared
new const float:CALEB_EXPLORE   = 25.0  // tiempo máximo explorando antes de rendirse
new const float:CALEB_RETURN    = 12.0  // tiempo intentando regresar
new const float:RAMBO_TIMEOUT   = 30.0  // si no oye a Caleb en X segs, sale solo

// ── JEFE (ID 0) ──────────────────────────────────────────────────
rolJefe() {
    // Solo da la señal de inicio y se pone en guardia
    wait(0.5)
    say(SIGNAL_START)

    // Guardia: dispara lo que vea
    new float:headDir = 1.047
    for(;;) {
        new touched = getTouched()
        if(touched) raise(touched)

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

    // Esperar señal de inicio del jefe
    do {
        item = 0
        hear(item, sound, yaw)
    } while(sound != SIGNAL_START)

    // Salir en dirección opuesta al jefe
    new float:giro = 3.1415
    if(yaw > 0) giro = -giro
    rotate(getDirection() + yaw + giro)
    wait(0.5)
    walk()

    // ── FASE 1: explorar sin disparar ──
    new float:headDir = 1.047
    new float:inicioExplora = getTime()
    new bool:encontro = false

    for(;;) {
        if(getTime() - inicioExplora > CALEB_EXPLORE)
            break  // timeout: no encontró nada, igual regresa

        if(isStanding()) {
            rotate(getDirection() + 1.5708)
            wait(0.5)
            walk()
        } else if(sight() < WALL_DIST) {
            new float:evade = (getID()%2 == 0) ? 0.5236 : -0.5236
            rotate(getDirection() + evade)
        }

        new touched = getTouched()
        if(touched) raise(touched)

        // Solo mirar — nunca disparar
        item = ENEMY_WARRIOR
        new float:dist = 0.0
        new float:eyaw
        new float:pitch
        watch(item, dist, eyaw, pitch)

        if(item == ENEMY_WARRIOR) {
            encontro = true
            break
        }

        rotateHead(headDir)
        if(getHeadYaw() == headDir)
            headDir = -headDir
    }

    // Reportar si encontró enemigo
    if(encontro) {
        say(SIGNAL_REPORT)
        wait(0.2)
    }

    // ── FASE 2: intentar regresar ──
    // Dar media vuelta y correr de regreso esquivando paredes
    rotate(getDirection() + 3.1415)
    wait(0.5)
    run()

    new float:inicioRegreso = getTime()
    for(;;) {
        if(getTime() - inicioRegreso > CALEB_RETURN)
            break

        if(isStanding()) {
            // Alternar giros para no quedar atascado en esquinas
            new float:giroLocal = (getTime() - inicioRegreso < CALEB_RETURN/2.0)
                ? 1.5708 : -1.5708
            rotate(getDirection() + giroLocal)
            wait(0.4)
            run()
        } else if(sight() < WALL_DIST) {
            rotate(getDirection() + 0.7854)
        }

        new touched = getTouched()
        if(touched) raise(touched)
    }

    // ── FASE 3: quedarse donde paró, en guardia SIN disparar ──
    walk()
    for(;;) {
        new touched = getTouched()
        if(touched) raise(touched)
        rotateHead(headDir)
        if(getHeadYaw() == headDir)
            headDir = -headDir
    }
}

// ── LÓGICA DE ATAQUE COMPARTIDA ───────────────────────────────────
atacar(float:dirInicial) {
    rotate(dirInicial)
    wait(0.5)
    run()

    new float:headDir = 1.047
    for(;;) {
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
    new float:dirAtaque

    // Esperar say(2) de Caleb, con timeout propio
    new float:inicio = getTime()
    new bool:recibioOrden = false

    for(;;) {
        // Timeout: Caleb probablemente murió → buscar sonido enemigo
        if(getTime() - inicio > RAMBO_TIMEOUT)
            break

        item = 0
        hear(item, sound, yaw)

        if(item == FRIEND_WARRIOR && sound == SIGNAL_REPORT) {
            // Caleb reportó: ir en la dirección de su voz
            new float:giro = 3.1415
            if(yaw > 0) giro = -giro
            dirAtaque = getDirection() + yaw + giro
            recibioOrden = true
            break
        }

        // Oportunidad: si oye disparos enemigos, guardar esa dirección
        if(item == ENEMY_GUN) {
            dirAtaque = getDirection() + yaw
            // No romper todavía — seguir esperando por si llega Caleb
        }
    }

    // Si nunca recibió orden, usar la dirección de disparos enemigos
    // o simplemente ir al frente si no oyó nada
    if(!recibioOrden && dirAtaque == 0.0)
        dirAtaque = getDirection()

    atacar(dirAtaque)
}

// ── RAMBO 2 (ID 3) ───────────────────────────────────────────────
rolRambo2() {
    new item
    new sound
    new float:yaw
    new float:dirAtaque

    // Rambo2 espera más que Rambo1 para no salir al mismo tiempo
    new float:inicio = getTime()
    new bool:recibioOrden = false

    for(;;) {
        // Timeout más largo: deja que Rambo1 actúe primero
        if(getTime() - inicio > RAMBO_TIMEOUT + 20.0)
            break

        item = 0
        hear(item, sound, yaw)

        if(item == FRIEND_WARRIOR && sound == SIGNAL_REPORT) {
            new float:giro = 3.1415
            if(yaw > 0) giro = -giro
            dirAtaque = getDirection() + yaw + giro
            recibioOrden = true
            break
        }

        if(item == ENEMY_GUN) {
            dirAtaque = getDirection() + yaw
        }
    }

    if(!recibioOrden && dirAtaque == 0.0)
        dirAtaque = getDirection()

    atacar(dirAtaque)
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