integer locked = TRUE;
integer holstered;
integer idle;
string shells = "ShellFX - Duo Phys";
integer mouselook;
integer aiming;
integer gVelocity = 150;
string bullet = "Bullet2.8";
integer ammo = 2;
integer reloading;
integer firing;

integer barrel = 7;
rotation bClosed = <-0.707107, 0.000000, 0.000000, 0.707107>;
rotation bOpen = <-0.615434, 0.348196, -0.348196, 0.615435>;

integer shellL = 5;
rotation sLrClosed =  <-0.691655, 0.147016, -0.691655, 0.147016>;
vector sLpClosed = <0.075600, 0.050926, -0.012726>;
rotation sLrOpen = <0.529583, -0.468574, 0.674371, 0.212616>;
vector sLpOpen1 = <0.108660, 0.063113, -0.012732>;
vector sLpOpen2 = <0.084446, 0.103411, -0.012732>;

integer shellR = 6;
rotation sRrClosed = <0.018510, 0.706865, 0.018510, 0.706865>;
vector sRpClosed = <0.075600, 0.051102, 0.012268>;
rotation sRrOpen = <0.364188, 0.606109, -0.331966, 0.624338>;
vector sRpOpen1 = <0.108807, 0.063197, 0.012270>;
vector sRpOpen2 = <0.084594, 0.103495, 0.012270>;

integer lock = 8;
rotation lockClosed = <-0.704280, -0.063165, 0.063165, 0.704280>;
rotation lockOpen = <-0.659587, -0.254844, -0.133408, 0.694408>;

integer particleR = 3;
integer particleL = 2;

burst(integer stage)
{
    if (stage)
    {
        llLinkParticleSystem(ammo+1,
            [
                PSYS_SRC_PATTERN,PSYS_SRC_PATTERN_ANGLE_CONE,
                PSYS_SRC_BURST_RADIUS,0,
                PSYS_SRC_ANGLE_BEGIN,0.2,
                PSYS_SRC_ANGLE_END,0,
                PSYS_SRC_TARGET_KEY,llGetKey(),
                PSYS_PART_START_COLOR,<1.000000,1.000000,1.000000>,
                PSYS_PART_END_COLOR,<0.970245,0.752271,0.443817>,
                PSYS_PART_START_ALPHA,1,
                PSYS_PART_END_ALPHA,1,
                PSYS_PART_START_GLOW,0.1,
                PSYS_PART_END_GLOW,0,
                PSYS_PART_BLEND_FUNC_SOURCE,PSYS_PART_BF_SOURCE_ALPHA,
                PSYS_PART_BLEND_FUNC_DEST,PSYS_PART_BF_ONE_MINUS_SOURCE_ALPHA,
                PSYS_PART_START_SCALE,<0.031250,0.100000,0.000000>,
                PSYS_PART_END_SCALE,<0.031250,0.031250,0.000000>,
                PSYS_SRC_TEXTURE,"c927956e-9d6e-b87c-d651-b339de7a0ad2",
                PSYS_SRC_MAX_AGE,0,
                PSYS_PART_MAX_AGE,0.3,
                PSYS_SRC_BURST_RATE,1,
                PSYS_SRC_BURST_PART_COUNT,50,
                PSYS_SRC_ACCEL,<0.000000,0.000000,-5.000000>,
                PSYS_SRC_OMEGA,<0.000000,0.000000,0.000000>,
                PSYS_SRC_BURST_SPEED_MIN,1,
                PSYS_SRC_BURST_SPEED_MAX,5,
                PSYS_PART_FLAGS,
                    0 |
                    PSYS_PART_EMISSIVE_MASK |
                    PSYS_PART_FOLLOW_VELOCITY_MASK |
                    PSYS_PART_INTERP_COLOR_MASK |
                    PSYS_PART_INTERP_SCALE_MASK
            ]);
        }else
        {
            llLinkParticleSystem(ammo+1,
            [
                PSYS_SRC_PATTERN,PSYS_SRC_PATTERN_ANGLE_CONE,
                PSYS_SRC_BURST_RADIUS,0,
                PSYS_SRC_ANGLE_BEGIN,0.2,
                PSYS_SRC_ANGLE_END,0,
                PSYS_SRC_TARGET_KEY,llGetKey(),
                PSYS_PART_START_COLOR,<0.445313,0.445313,0.445313>,
                PSYS_PART_END_COLOR,<0.000000,0.000000,0.000000>,
                PSYS_PART_START_ALPHA,1,
                PSYS_PART_END_ALPHA,0,
                PSYS_PART_START_GLOW,0,
                PSYS_PART_END_GLOW,0,
                PSYS_PART_BLEND_FUNC_SOURCE,PSYS_PART_BF_SOURCE_ALPHA,
                PSYS_PART_BLEND_FUNC_DEST,PSYS_PART_BF_ONE_MINUS_SOURCE_ALPHA,
                PSYS_PART_START_SCALE,<0.100000,0.031250,0.000000>,
                PSYS_PART_END_SCALE,<1.000000,1.000000,0.000000>,
                PSYS_SRC_TEXTURE,"fc3d7343-c1a9-ee7b-cd7a-beaaf6aa011b",
                PSYS_SRC_MAX_AGE,0,
                PSYS_PART_MAX_AGE,5,
                PSYS_SRC_BURST_RATE,.1,
                PSYS_SRC_BURST_PART_COUNT,100,
                PSYS_SRC_ACCEL,<0.000000,0.000000,0.100000>,
                PSYS_SRC_OMEGA,<0.000000,0.000000,0.000000>,
                PSYS_SRC_BURST_SPEED_MIN,0.1,
                PSYS_SRC_BURST_SPEED_MAX,1,
                PSYS_PART_FLAGS,
                    0 |
                    PSYS_PART_INTERP_COLOR_MASK |
                    PSYS_PART_INTERP_SCALE_MASK |
                    PSYS_PART_WIND_MASK
            ]);
        }
}

close(integer skip)
{
    if(!skip)
    {
        llSetLinkAlpha(shellL, 1, ALL_SIDES);
        llSetLinkAlpha(shellR, 1, ALL_SIDES);
    }
    llSetLinkPrimitiveParamsFast(shellL,[PRIM_ROT_LOCAL, sLrClosed ,PRIM_POS_LOCAL, sLpClosed]);
    llSetLinkPrimitiveParamsFast(shellR,[PRIM_ROT_LOCAL, sRrClosed ,PRIM_POS_LOCAL, sRpClosed]);
    llSetLinkPrimitiveParamsFast(barrel,[PRIM_ROT_LOCAL, bClosed]);
    llSetLinkPrimitiveParamsFast(lock,[PRIM_ROT_LOCAL, lockClosed]);
}

open()
{
    llSetLinkPrimitiveParamsFast(lock,[PRIM_ROT_LOCAL, lockOpen]);
    llSetLinkPrimitiveParamsFast(barrel,[PRIM_ROT_LOCAL, bOpen]);
    llSetLinkPrimitiveParamsFast(shellL,[PRIM_ROT_LOCAL, sLrOpen ,PRIM_POS_LOCAL, sLpOpen1]);
    llSetLinkPrimitiveParamsFast(shellR,[PRIM_ROT_LOCAL, sRrOpen,PRIM_POS_LOCAL, sRpOpen1]);
    llSleep(0.2);
    llSetLinkPrimitiveParamsFast(shellL,[PRIM_POS_LOCAL, sLpOpen2]);
    llSetLinkPrimitiveParamsFast(shellR,[PRIM_POS_LOCAL, sRpOpen2]);
    llSleep(.2);
    llSetLinkAlpha(shellL, 0, ALL_SIDES);
    llSetLinkAlpha(shellR, 0, ALL_SIDES);
    llRezAtRoot(shells, llGetPos() + < 0.2, -0.1, 0.4> * llGetRot(), ZERO_VECTOR, ZERO_ROTATION, 0);
}

reload()
{
    reloading = TRUE;
    llStopAnimation("shotgunHold" + (string)idle);
    llStopAnimation("HipAim");
    llStartAnimation("ShotgunReload");
    llPlaySound("ShotgunLoad",1);
    llSleep(.2);
    llSetLinkPrimitiveParamsFast(lock,[PRIM_ROT_LOCAL, lockOpen]);
    llSetLinkPrimitiveParamsFast(barrel,[PRIM_ROT_LOCAL, bOpen]);
    llSetLinkPrimitiveParamsFast(shellL,[PRIM_ROT_LOCAL, sLrOpen ,PRIM_POS_LOCAL, sLpOpen1]);
    llSetLinkPrimitiveParamsFast(shellR,[PRIM_ROT_LOCAL, sRrOpen,PRIM_POS_LOCAL, sRpOpen1]);
    llSleep(0.2);

    llSetLinkPrimitiveParamsFast(shellL,[PRIM_POS_LOCAL, sLpOpen2]);
    llSetLinkPrimitiveParamsFast(shellR,[PRIM_POS_LOCAL, sRpOpen2]);
    llSleep(.2);

    llSetLinkAlpha(shellL, 0, ALL_SIDES);
    llSetLinkAlpha(shellR, 0, ALL_SIDES);
    llRezAtRoot(shells, llGetPos() + < 0.3, -0.2, 0.4> * llGetRot(), ZERO_VECTOR, ZERO_ROTATION, 0);
    llSleep(.2);

    llSetLinkAlpha(shellL, 1, ALL_SIDES);
    llSleep(.1);
    llSetLinkPrimitiveParamsFast(shellL,[PRIM_ROT_LOCAL, sLrOpen ,PRIM_POS_LOCAL, sLpOpen1]);
    llSleep(.2);

    llSetLinkAlpha(shellR, 1, ALL_SIDES);
    llSleep(.1);
    llSetLinkPrimitiveParamsFast(shellR,[PRIM_ROT_LOCAL, sRrOpen,PRIM_POS_LOCAL, sRpOpen1]);
    llSleep(.4);

    llSetLinkPrimitiveParamsFast(shellL,[PRIM_ROT_LOCAL, sLrClosed ,PRIM_POS_LOCAL, sLpClosed]);
    llSetLinkPrimitiveParamsFast(shellR,[PRIM_ROT_LOCAL, sRrClosed ,PRIM_POS_LOCAL, sRpClosed]);
    llSetLinkPrimitiveParamsFast(barrel,[PRIM_ROT_LOCAL, bClosed]);
    llSetLinkPrimitiveParamsFast(lock,[PRIM_ROT_LOCAL, lockClosed]);
    if(aiming)
    {
        llStartAnimation("HipAim");
    }else
    {
        llStartAnimation("shotgunHold" + (string)idle);
        llStopAnimation("ShotgunReload");
    }
    ammo = 2;
    reloading = FALSE;
}

updateIdle()
{
    llStopAnimation("shotgunHold" + (string)idle);
    if (idle <2)
    {
        idle++;
    }else
    {
        idle = 0;
    }
    llStartAnimation("shotgunHold" + (string)idle);
}

default
{
    attach(key id)
    {
        if (id)     // is a valid key and not NULL_KEY
        {
            llResetScript();
        }
    }
    
    state_entry()
    {
        close(0);

        integer gPermFlags = PERMISSION_TRIGGER_ANIMATION | PERMISSION_TAKE_CONTROLS | PERMISSION_TRACK_CAMERA;
        if ( llGetAttached() )
            llRequestPermissions(llGetOwner(), gPermFlags);

        llListen(1, "", llGetOwner(), "");
    }
    run_time_permissions(integer perm)
    {
        if (perm & PERMISSION_TRIGGER_ANIMATION)
        {
            llTakeControls(CONTROL_ML_LBUTTON, TRUE, FALSE);
            llSetLinkAlpha(LINK_SET, 0, ALL_SIDES);
            llSay(-1988, "holster");
            integer i;
            while(i < 3)
                {
                    llStopAnimation("shotgunHold" + (string)i);
                    i++;
                }
            holstered = TRUE;
            llOwnerSay("Shotgun Ready");
        }
    }

    touch_start(integer num)
    {
        if (llDetectedKey(0) == llGetOwner())
        {
            /*
            llOwnerSay("\n PrimName : " +
                llList2String(llGetLinkPrimitiveParams(llDetectedLinkNumber(0), [PRIM_NAME]),0) +
                "\n Linknumber: " +
                (string)llDetectedLinkNumber(0) +
                "\n Rotation: " +
                llList2String(llGetLinkPrimitiveParams(llDetectedLinkNumber(0), [PRIM_ROT_LOCAL]),0) +
                "\n Position: " +
                llList2String(llGetLinkPrimitiveParams(llDetectedLinkNumber(0), [PRIM_POS_LOCAL]),0));
    
            if (locked)
            {
                open();
                locked = FALSE;
            }else
            {
                close(1);
                locked = TRUE;
            }
            */
            if (!holstered) updateIdle();
        }

    }

    listen(integer chan, string name, key id, string msg)
    {
        if (msg == "reload")
        {
            if(!reloading)
            {
                if(!holstered)reload();
            }
        }

        if (msg == "draw")
        {
            if (holstered)
            {
                llTakeControls(CONTROL_ML_LBUTTON, TRUE, FALSE);
                llStartAnimation("sling");
                llSleep(.7);
                llPlaySound("unslingSound",1);
                llSay(-1988, "unholster");
                llSetLinkAlpha(LINK_SET, 1, ALL_SIDES);
                llStartAnimation("shotgunHold" + (string)idle);
                holstered = FALSE;
                llSetTimerEvent(.1);
            }else
            {
                llStartAnimation("sling");
                llSleep(.2);
                llPlaySound("slingSound",1);
                llSay(-1988, "holster");
                llSetLinkAlpha(LINK_SET, 0, ALL_SIDES);
                llStopAnimation("shotgunHold" + (string)idle);
                holstered = TRUE;
                llSetTimerEvent(0);
            }
        }
    }

     control(key id, integer held, integer change)
    {
        if (!holstered && !reloading)
        {
            integer start = held & change;
            integer end = ~held & change;
            integer held = held & ~change;
            integer untouched = ~(held | change);
            if ( held & CONTROL_ML_LBUTTON)
            {
                if (ammo > 0)
                {
                    if (!firing)
                    {
                        firing = TRUE;
                        llTriggerSound("Shotgun",1);
                        burst(1);
                        llStopAnimation("HipAim");                    
                        llStartAnimation("HipRecoil");
                        rotation Rot = llGetCameraRot();
                        llRezAtRoot(bullet, llGetCameraPos() + (<1, 0, 0>*Rot), gVelocity*llRot2Fwd(Rot), Rot, 0);
                        llStartAnimation("HipAim");
                        burst(0);
                        ammo--;
                        llSleep(.5);
                        firing = FALSE;
                    }
                }else
                {
                     if (!firing)
                    {
                        firing = TRUE;
                        llPlaySound("ClickOpen",1);
                        llSleep(.5);
                        firing = FALSE;
                    }
                }
            }
        }
    }

    timer()
    {
        llLinkParticleSystem(3, []);
        llLinkParticleSystem(2, []);
        integer new_mouselook = llGetAgentInfo(llGetOwner())&AGENT_MOUSELOOK;
        if (new_mouselook != mouselook)
        {
            mouselook = new_mouselook;
            if(mouselook)
            {
                aiming = TRUE;
                llStopAnimation("shotgunHold" + (string)idle);
                llStartAnimation("HipAim");
            }
            else
            {
                aiming = FALSE;
                llStopAnimation("HipAim");
                llStartAnimation("shotgunHold" + (string)idle);
            }
        }
    }
}
