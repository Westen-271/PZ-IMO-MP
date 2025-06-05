# Immersive Medical Overhaul
### A mod to overhaul the medical system and interactions between players, thereby making mechanical PVP in multiplayer engaging.


## Current Problems:
1. Time to kill (TTK) is too high (you can plausibly die in under a second, especially if the server is laggy).
2. Injuries are basic and can be fixed by anyone as long as they have the requisite items.
3. Level 10 first aid, outside of some specific server rules, does not do anything other than change the rate at which you heal.

## Aims of this mod:
1. Give the first aid perk more skill expression - make 10 first aid actually make a difference to give people a reason to reach it.
2. Increase the TTK in multiplayer PVP significantly.
3. Make the system more fun to interact with beyond "you're bandaged/stitched, now wait a week for it to heal".

## Systems:
### 1. Health -> Overall Picture
- In base game Zomboid, you take overall health damage based on injuries and other damage such as fall damage / being shot.
- This has been overhauled so that the overall health of your character is now a holistic picture of their health.
- For example, if you are shot in the thigh, you won't lose 50% of your health. Instead, you will lose health based on the % of blood volume you are losing. A shot to the artery will see you lose health significantly faster than if it were a graze to the arm.

### 2. Overhauling Death
- When you drop below Incapacity Health Threshold (sandbox settings), barring something that causes instant health loss above this value, your character will be placed into the Incapacitated state where they cannot move.
- The player can be revived once their health is brought above this level.
- This means that for, say, significant blood loss, you will either need to wait a while or have a medic perform a blood transfusion. 

### 3. New medical items to stop bleeding, with Sandbox settings to enable or disable based on year your server is based on.
- Tourniquets are always available and can be made or found. Tourniquets that are made have less durability unless done by a tailor.
- Hemostatics are available based on year, with different versions of Celox and QuikClot (including their own side effects).

### 4. Vital signs are added along with tools to monitor them, to help medics keep an eye on their patient.
- Equipment from different years is available with different functionality or capability.
- Equipment can be used to monitor vitals, and characters with a higher first aid skill will take vitals and use equipment faster.

## Implementation Stages:
### 1. Vitals (part 1)
- Heart Rate, Blood Pressure and Respiration Rate 
- Injuries affect heart rate and blood pressure. Exercise affects RR, which can also affect HR and BP (though only in extremes)
- Overall health value roughly mirrors HR/BP.
- Capability for players to check pulse and blood pressure of themselves and other players by hand (non-electric blood pressure cuff).
- The speed of these scale with the user's skill level.

### 2. Vitals (part 2)
- Blood oxygen saturation and skin temperature
- These are affected by moodles / infection / injuries and can be used to help identify problems.
- Battery operated pulse oximeter and digital thermometer.

### 3. Injury Overhaul
- Re-design the ISHealthPanel UI to fit with the new health system, show basic vital signs where possible.
- Propagate this to the "Health Check" function available in multiplayer.
