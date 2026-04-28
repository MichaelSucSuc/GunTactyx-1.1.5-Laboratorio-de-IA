// Estrategia: Caleb (vigía) + Rambos (atacantes)
// ID0=Jefe, ID1=Caleb, ID2=Rambo1, ID3=Rambo2

#include "core"
#include "math"
#include "bots"

new const FRIEND_WARRIOR = ITEM_FRIEND|ITEM_WARRIOR
new const ENEMY_WARRIOR  = ITEM_ENEMY|ITEM_WARRIOR
new const ENEMY_GUN      = ITEM_ENEMY|ITEM_GUN
new const SIGNAL_START   = 1
new const SIGNAL_REPORT  = 2
new const float:WALL_DIST = 3.0

// ── JEFE (ID 0) ──────────────────────────────────────────────────
rolJefe() {
    wait(0.5)
    say(SIGNAL_START)

    new float:headDir = 1.047
    for(;;) {
        new touched = getTouched()
        if(touched) raise(touched)
        new item = ENEMY_WARRIOR
        new float:dist = 0.0
        new float:eyaw, float:pitch
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

// ── CALEB (ID 1) — explorar sin disparar ─────────────────────────
rolCaleb() {
    new item, sound
    new float:yaw

    do {
        item = 0
        hear(item, sound, yaw)
    } while(sound != SIGNAL_START)

    new float:giro = (yaw > 0) ? -3.1415 : 3.1415
    rotate(getDirection() + yaw + giro)
    wait(0.5)
    walk()

    new float:headDir = 1.047
    for(;;) {
        if(isStanding()) {
            rotate(getDirection() + 1.5708)
            wait(0.5)
            walk()
        } else if(sight() < WALL_DIST) {
            rotate(getDirection() + 0.5236)
        }

        new touched = getTouched()
        if(touched) raise(touched)

        item = ENEMY_WARRIOR
        new float:dist = 0.0
        new float:eyaw, float:pitch
        watch(item, dist, eyaw, pitch)

        if(item == ENEMY_WARRIOR) {
            say(SIGNAL_REPORT)
            wait(0.2)
            say(SIGNAL_REPORT)
            wait(0.2)

            rotate(getDirection() + 3.1415)
            wait(0.5)
            run()
            new float:t = getTime()
            for(;;) {
                if(getTime() - t > 10.0) break
                if(isStanding()) {
                    rotate(getDirection() + 1.5708)
                    wait(0.4)
                    run()
                } else if(sight() < WALL_DIST) {
                    rotate(getDirection() + 0.7854)
                }
                new tt = getTouched()
                if(tt) raise(tt)
            }
            walk()
            for(;;) {
                new tt = getTouched()
                if(tt) raise(tt)
                rotateHead(headDir)
                if(getHeadYaw() == headDir)
                    headDir = -headDir
            }
        }

        rotateHead(headDir)
        if(getHeadYaw() == headDir)
            headDir = -headDir
    }
}

// ── ATAQUE (compartido) ───────────────────────────────────────────
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
        new float:eyaw, float:pitch
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
    new item, sound
    new float:yaw
    new float:dirAtaque = getDirection()

    new float:inicio = getTime()
    for(;;) {
        if(getTime() - inicio > 35.0) break
        item = 0
        hear(item, sound, yaw)
        if(sound == SIGNAL_REPORT) {
            dirAtaque = getDirection() + yaw
            break
        }
        if(item == ENEMY_GUN)
            dirAtaque = getDirection() + yaw
    }

    atacar(dirAtaque)
}

// ── RAMBO 2 (ID 3) ───────────────────────────────────────────────
rolRambo2() {
    new item, sound
    new float:yaw
    new float:dirAtaque = getDirection()

    new float:inicio = getTime()
    for(;;) {
        if(getTime() - inicio > 55.0) break
        item = 0
        hear(item, sound, yaw)
        if(sound == SIGNAL_REPORT) {
            dirAtaque = getDirection() + yaw
            break
        }
        if(item == ENEMY_GUN)
            dirAtaque = getDirection() + yaw
    }

    atacar(dirAtaque)
}

// ── MAIN ──────────────────────────────────────────────────────────
fight() {
    switch(getID()) {
        case 0: rolJefe()
        case 1: rolCaleb()
        case 2: rolRambo1()
        case 3: rolRambo2()
    }
}

main() {
    fight()
}