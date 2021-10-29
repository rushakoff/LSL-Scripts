integer cylinder;
integer hammer;
integer trigger;
integer lever;
integer piston;
integer emitter;

integer cocked = FALSE;
integer spinning = FALSE;
integer holstered = FALSE;
integer reloading = FALSE;
integer gPermFlags;

integer flipflop;
string holdstyle = "GunArmDown";
string savedAnim;
string aA = "GunArmDown";
string hA = "GunGrip";

integer mouselook;
integer aiming = FALSE;
integer hipfire = 0;
vector chamberdefrot = <2.11262, -0.00203, 0.00003>;
integer ammo = 6;
integer cylindex;
list chamberlist = [2,3,6,0,5,1];
list ammolist = [1,1,1,1,1,1];

integer target;
key targetkey;
string  gBullet = "Bullet1.0";
float   gVelocity = 50;
integer emit = 0;
integer tgtisav;
integer tgttype;
integer dist = 1;
integer bulletSettings;

integer started;

Preload()
{
    llOwnerSay("Preloading Sounds and Animations. Please Wait.");
    integer x;
    integer SOUNDS_COUNT= llGetInventoryNumber(INVENTORY_SOUND);
    for (x=0;x<SOUNDS_COUNT;x++){llPreloadSound(llGetInventoryName(INVENTORY_SOUND,x));}

    integer ANIM_COUNT= llGetInventoryNumber(INVENTORY_ANIMATION);
    for (x=0;x<ANIM_COUNT;x++)
    {
        llStartAnimation(llGetInventoryName(INVENTORY_ANIMATION,x));
        llStopAnimation(llGetInventoryName(INVENTORY_ANIMATION,x));
    }
    llOwnerSay("Done");
    started = TRUE;
}

burst()
{
    emit = 2;
    llSetLinkPrimitiveParamsFast(emitter,[PRIM_POINT_LIGHT, TRUE, <1.000, 0.500, 0.000>, 1, .4, 0]);
    llLinkParticleSystem(emitter,[
       PSYS_SRC_PATTERN,PSYS_SRC_PATTERN_ANGLE_CONE,
        PSYS_SRC_BURST_RADIUS,0,
        PSYS_SRC_ANGLE_BEGIN,0.2,
        PSYS_SRC_ANGLE_END,0,
        PSYS_SRC_TARGET_KEY,llGetKey(),
        PSYS_PART_START_COLOR,<1.000000,1.000000,1.000000>,
        PSYS_PART_END_COLOR,<1.000000,0.500000,0.000000>,
        PSYS_PART_START_ALPHA,1,
        PSYS_PART_END_ALPHA,0,
        PSYS_PART_START_GLOW,1,
        PSYS_PART_END_GLOW,0,
        PSYS_PART_BLEND_FUNC_SOURCE,PSYS_PART_BF_SOURCE_ALPHA,
        PSYS_PART_BLEND_FUNC_DEST,PSYS_PART_BF_ONE_MINUS_SOURCE_ALPHA,
        PSYS_PART_START_SCALE,<0.031250,0.031250,0.000000>,
        PSYS_PART_END_SCALE,<0.100000,0.200000,0.000000>,
        PSYS_SRC_TEXTURE,"c927956e-9d6e-b87c-d651-b339de7a0ad2",
        PSYS_SRC_MAX_AGE,.3,
        PSYS_PART_MAX_AGE,0.2,
        PSYS_SRC_BURST_RATE,4,
        PSYS_SRC_BURST_PART_COUNT,50,
        PSYS_SRC_ACCEL,<0.000000,0.000000,-5.000000>,
        PSYS_SRC_OMEGA,<0.000000,0.000000,0.000000>,
        PSYS_SRC_BURST_SPEED_MIN,0.5,
        PSYS_SRC_BURST_SPEED_MAX,10,
        PSYS_PART_FLAGS,
            0 |
            PSYS_PART_EMISSIVE_MASK |
            PSYS_PART_FOLLOW_VELOCITY_MASK |
            PSYS_PART_INTERP_COLOR_MASK |
            PSYS_PART_INTERP_SCALE_MASK
    ]);
}

HipFire()
{
    savedAnim = "HipHold";
    if (spinning)
    {
        SpinGun(FALSE);
    }else
    {
        UpdateArm("HipHold");
    }
    llStartAnimation("HipFire");
    vector cock = <3.14159, 0.00009, 0.78540>;
    vector chamber = llRot2Euler(llList2Rot(llGetLinkPrimitiveParams(cylinder,[PRIM_ROT_LOCAL]),0));
    chamber.x -= (60 * DEG_TO_RAD);
    llTriggerSound("Cock",1);
    llSleep(.15);
    llSetLinkPrimitiveParamsFast( hammer, [PRIM_ROT_LOCAL, llEuler2Rot(cock)]);
    llSleep(0.02);
    llSetLinkPrimitiveParamsFast( cylinder, [PRIM_ROT_LOCAL, llEuler2Rot(chamber)]);
    if (cylindex < 5)
    {
        cylindex++;
    }else
    {
        cylindex = 0;
    }
    vector pull = <3.14159, 0.00018, -0.34910>;
    llSetLinkPrimitiveParamsFast(trigger, [PRIM_ROT_LOCAL, llEuler2Rot(pull)]);
    cock = <3.14159, 0.00009, 0.00000>;
    llSetLinkPrimitiveParamsFast(hammer, [PRIM_ROT_LOCAL, llEuler2Rot(cock)]);
    if (ammo > 0 && llList2Integer(ammolist, cylindex) == 1)
    {
        burst();
        ammo--;
        llTriggerSound("Bang" + (string)llRound(llFrand(2)+1),1);
        llSetLinkAlpha(cylinder, 0.0, llList2Integer(chamberlist, cylindex));
        if (target)
        {
            if ((llGetParcelFlags(llGetPos()) & PARCEL_FLAG_ALLOW_CREATE_GROUP_OBJECTS))
            {
                rotation Rot = llGetRot();
                vector TargetPos = llList2Vector(llGetObjectDetails(targetkey, [OBJECT_POS]), 0);
                if (tgtisav)
                {
                    TargetPos.z += .4;
                }else
                {
                    TargetPos.z += .1;
                }
                vector GunPos = llGetPos() + (<1, 0.0, 0.2>*Rot);
                vector direction = llVecNorm(TargetPos - GunPos);
                llRezAtRoot(gBullet, GunPos, gVelocity*direction, llRotBetween(<2,0,0>,direction), dist);
            }
        }else
        {
             if ((llGetParcelFlags(llGetPos()) & PARCEL_FLAG_ALLOW_CREATE_GROUP_OBJECTS))
                {
                    rotation Rot = llGetRot();
                    llRezAtRoot(gBullet, llGetPos() + (<1, 0.0, 0.2>*Rot), gVelocity*(<1.0, 0.0, 0.0>*Rot), Rot, dist);
                }
        }
        ammolist = llListReplaceList(ammolist,[0], cylindex, cylindex);
    }else
    {
        llTriggerSound("Click",1);
    }
    cocked = FALSE;
}

Reload()
{
    reloading = TRUE;
    if (spinning)SpinGun(FALSE);
    if (!cocked && hipfire < 1 && ammo > 0)
    {
        CockFire(FALSE);
    }else if (ammo < 6)
    {
        while (ammo < 6)
        {
            UpdateArm("ReloadHold");
            vector cock;
            vector pull;
            if(cocked)
            {
                llStartAnimation("GunDecock");
                llTriggerSound("Decock",1);
                llSleep(.1);
                pull = <3.14159, 0.00018, -0.34910>;
                llSetLinkPrimitiveParamsFast(trigger, [PRIM_ROT_LOCAL, llEuler2Rot(pull)]);
                llSleep(.2);
                cock = <3.14159, 0.00009, 0.00000>;
                llSetLinkPrimitiveParamsFast( hammer, [PRIM_ROT_LOCAL, llEuler2Rot(cock)]);
            }
            llStopAnimation("GunTrigger");
            llStartAnimation("GunCock");
            llSleep(.1);
            llTriggerSound("Cock",1);
            llSleep(.15);
            cock = <3.14159, 0.00009, 0.78540>;
            llSetLinkPrimitiveParamsFast( hammer, [PRIM_ROT_LOCAL, llEuler2Rot(cock)]);
            llSleep(0.02);
            vector chamber = llRot2Euler(llList2Rot(llGetLinkPrimitiveParams(cylinder,[ PRIM_ROT_LOCAL]),0));
            chamber.x -= (60 * DEG_TO_RAD);
            llSetLinkPrimitiveParamsFast( cylinder, [PRIM_ROT_LOCAL, llEuler2Rot(chamber)]);
            pull = <3.14159, 0.00018, -0.00003>;
            llSetLinkPrimitiveParamsFast(trigger, [PRIM_ROT_LOCAL, llEuler2Rot(pull)]);
            if (cylindex < 5)
            {
                cylindex++;
            }else
            {
                cylindex = 0;
            }
            cocked = TRUE;
            integer i = cylindex;
            //integer doublecheck;
            while (llList2Integer(ammolist, i) == 1 /*&& doublecheck < 5*/)
            {
                CockFire(TRUE);
                llSleep(0.1);
                CockFire(FALSE);
                i = cylindex;
                //doublecheck++;
            }
            vector push = llList2Vector(llGetLinkPrimitiveParams(piston,[PRIM_POS_LOCAL]),0);
            vector move = llList2Vector(llGetLinkPrimitiveParams(piston,[PRIM_SIZE]),0);
            llStartAnimation("ReloadAction");
            llSleep(.6);
            llTriggerSound("Lever" + (string)llRound(llFrand(3)+1),1);
            vector load = <3.14159, 0.00018, -1.04723>;
            push.x -= move.x*.21;
            llSetLinkPrimitiveParamsFast(lever, [PRIM_ROT_LOCAL, llEuler2Rot(load)]);
            llSetLinkPrimitiveParamsFast(piston, [PRIM_POS_LOCAL, push]);
            llSleep(.3);
            load = <3.14159, 0.00018, -0.00003>;
            llSetLinkPrimitiveParamsFast(lever, [PRIM_ROT_LOCAL, llEuler2Rot(load)]);
            push.x += move.x*.21;
            llSetLinkPrimitiveParamsFast(piston, [PRIM_POS_LOCAL, push]);
            llSetLinkAlpha(cylinder, 1.0, llList2Integer(chamberlist, cylindex));
            ammolist = llListReplaceList(ammolist,[1], cylindex, cylindex);
            ammo++;
        }
        UpdateArm(savedAnim);
    }
    reloading = FALSE;
}

CockFire(integer decock)
{
    if (decock)
    {
        llStartAnimation("GunDecock");
        llTriggerSound("Decock",1);
        llSleep(.1);
        vector pull = <3.14159, 0.00018, -0.34910>;
        llSetLinkPrimitiveParamsFast(trigger, [PRIM_ROT_LOCAL, llEuler2Rot(pull)]);
        llSleep(.2);
        vector cock = <3.14159, 0.00009, 0.00000>;
        llSetLinkPrimitiveParamsFast(hammer, [PRIM_ROT_LOCAL, llEuler2Rot(cock)]);
        cocked = FALSE;
    }else
    {
        if (spinning)
        {
            SpinGun(FALSE);
        }
        if (cocked)
        {
            llStopAnimation("GunCock");
            llStartAnimation("GunTrigger");
            llSleep(.1);
            vector pull = <3.14159, 0.00018, -0.34910>;
            llSetLinkPrimitiveParamsFast(trigger, [PRIM_ROT_LOCAL, llEuler2Rot(pull)]);
            vector cock = <3.14159, 0.00009, 0.00000>;
            llSetLinkPrimitiveParamsFast(hammer, [PRIM_ROT_LOCAL, llEuler2Rot(cock)]);
            if (ammo > 0 && llList2Integer(ammolist, cylindex) == 1 )
            {
                ammo--;
                burst();
                llStartAnimation("GunArmFire");
                llTriggerSound("Bang" + (string)llRound(llFrand(2)+1),1);
                llSetLinkAlpha(cylinder, 0.0, llList2Integer(chamberlist, cylindex));
                if ((llGetParcelFlags(llGetPos()) & PARCEL_FLAG_ALLOW_CREATE_GROUP_OBJECTS))
                {
                    rotation Rot = llGetCameraRot();
                    llRezAtRoot(gBullet, llGetCameraPos() + (<1, 0.0, 0.0>*Rot), gVelocity*llRot2Fwd(Rot), Rot, dist);
                }
                ammolist = llListReplaceList(ammolist,[0], cylindex, cylindex);
            }else
            {
                llTriggerSound("Click",1);
            }
            cocked = FALSE;
        }else
        {
            vector cock = <3.14159, 0.00009, 0.78540>;
            vector chamber = llRot2Euler(llList2Rot(llGetLinkPrimitiveParams(cylinder,[PRIM_ROT_LOCAL]),0));
            chamber.x -= (60 * DEG_TO_RAD);
            llStopAnimation("GunTrigger");
            llStartAnimation("GunCock");
            llSleep(.1);
            llTriggerSound("Cock",1);
            llSleep(.15);
            llSetLinkPrimitiveParamsFast( hammer, [PRIM_ROT_LOCAL, llEuler2Rot(cock)]);
            llSleep(0.02);
            llSetLinkPrimitiveParamsFast( cylinder, [PRIM_ROT_LOCAL, llEuler2Rot(chamber)]);
            
            vector pull = <3.14159, 0.00018, -0.00003>;
            llSetLinkPrimitiveParamsFast(trigger, [PRIM_ROT_LOCAL, llEuler2Rot(pull)]);
            if (cylindex < 5)
            {
                cylindex++;
            }else
            {
                cylindex = 0;
            }
            cocked = TRUE;
        }
    }
}

UpdateArm(string Aanim)
{
    llStopAnimation(aA);
    aA = Aanim;
    llStartAnimation(aA);
}
UpdateHand(string Hanim)
{
    llStopAnimation(hA);
    hA = Hanim;
    llStartAnimation(hA);
}

SpinGun(integer spin)
{
    if (spin)
    {
        savedAnim = aA;
        UpdateArm("GunArmSpin");
        UpdateHand("GunSpin");
        llTargetOmega(<0.0,0.0,-3.5>*llGetLocalRot(),TWO_PI,1);
        llLoopSound("SpinSound",1);
        spinning = TRUE;
    }else
    {
        UpdateArm(savedAnim);
        UpdateHand("GunGrip");
        llTargetOmega(<0.0,0.0,0.0>*llGetLocalRot(),TWO_PI,0);
        llStopSound();
        spinning = FALSE;
        llSetText("1", ZERO_VECTOR, 1.0);llSetText("", ZERO_VECTOR, 0.0);       
    }   
}

Mishap()
{
        vector pull = <3.14159, 0.00018, -0.34910>;
        llSetLinkPrimitiveParamsFast(trigger, [PRIM_ROT_LOCAL, llEuler2Rot(pull)]);
        vector cock = <3.14159, 0.00009, 0.00000>;
        llSetLinkPrimitiveParamsFast(hammer, [PRIM_ROT_LOCAL, llEuler2Rot(cock)]);
        if (ammo > 0 && llList2Integer(ammolist, cylindex) == 1 )
        {
            llStopSound();
            ammo--;
            burst();
            llTriggerSound("ricochet",1);
            llStopAnimation(aA);
            llStartAnimation("GunSpinMishap");
            llTargetOmega(<0.0,0.0,0.0>*llGetLocalRot(),TWO_PI,0);
            llTriggerSound("wack",1);
            llSetText("1", ZERO_VECTOR, 1.0);llSetText("", ZERO_VECTOR, 0.0);     
            llSetLinkAlpha(cylinder, 0.0, llList2Integer(chamberlist, cylindex));
            ammolist = llListReplaceList(ammolist,[0], cylindex, cylindex);
            llSetLinkPrimitiveParamsFast(emitter,[PRIM_POINT_LIGHT, FALSE, <1.000, 0.500, 0.000>, 1, 0.4, 0]);
            llSleep(1);
            UpdateArm(savedAnim);
            UpdateHand("GunGrip");
            spinning = FALSE;  
        }else
        {
            llTriggerSound("Click",1);
        }
        cocked = FALSE;
}

default
{
    attach(key id)
    {
        if (id)
        {
            llResetScript();
        }else
        {
            integer perm = llGetPermissions();
            if(perm & PERMISSION_TRIGGER_ANIMATION)
            {
                llStopAnimation(aA);
                llStopAnimation(hA);
            }
        }
    }
    
    changed(integer change)
    {
        if (change & CHANGED_OWNER )
            llResetScript();
    }
    
    state_entry()
    {
        integer i;
        while (i <= llGetNumberOfPrims())
        {
            string name = llList2String(llGetLinkPrimitiveParams(i,[PRIM_NAME]),0);
            if (name == "cylinder")cylinder = i; //llOwnerSay("found cylinder " + (string)i);}
            if (name == "hammer")hammer = i; //llOwnerSay("found hammer " + (string)i);}
            if (name == "trigger")trigger = i; //llOwnerSay("found trigger " + (string)i);}
            if (name == "lever")lever = i; //llOwnerSay("found lever " + (string)i);}
            if (name == "piston")piston = i; //llOwnerSay("found piston " + (string)i);}
            if (name == "emitter")emitter = i; //llOwnerSay("found emitter " + (string)i);}
            i++;
        }
        llSetLinkPrimitiveParamsFast(cylinder, [PRIM_ROT_LOCAL, llEuler2Rot(chamberdefrot)]);
        llListen(1899,"","","");
        gPermFlags = PERMISSION_TRIGGER_ANIMATION | PERMISSION_TAKE_CONTROLS | PERMISSION_TRACK_CAMERA;
        if ( llGetAttached() )
            llRequestPermissions(llGetOwner(), gPermFlags);
    }
    
    run_time_permissions(integer perm)
    {
        if ( (perm & gPermFlags) == gPermFlags)
        {
            if (!started)
            {
                llStopAnimation(hA);
                llSetLinkAlpha(LINK_SET,0.0,ALL_SIDES);
                llTriggerSound("Holster",1);
                llSay(-1899, "holster");
                llStartAnimation("HandRelaxer");
                holstered = TRUE;
                mouselook = 0;
                llSensorRepeat("", NULL_KEY, AGENT|ACTIVE, 10, 0.6,.1);
                Preload();
                list bInfo = llParseString2List(llList2String(llGetLinkPrimitiveParams(5, [PRIM_DESC]),0),[","],[]);
                gVelocity = llList2Float(bInfo,0);
                dist = llList2Integer(bInfo,1);
                llOwnerSay("Gun Ready");
            }
            llTakeControls(CONTROL_ML_LBUTTON|CONTROL_LBUTTON, TRUE, FALSE);
        }
    }
    
     sensor( integer id )
    {  
        integer vBitType;
        string vStrType;
        integer index;

        vBitType = llDetectedType(index);
        if (llDetectedKey(0) != targetkey && llDetectedName(0) != gBullet && llDetectedName(0) != "HolePlane")
        {
            if (vBitType & AGENT)
            {
                //llOwnerSay("target is av : " + llDetectedName(0) );
                targetkey = llDetectedKey(0);
                tgtisav = TRUE;
                target = TRUE;
            }else
            {
                //llOwnerSay("target is not av : " + llDetectedName(0));
                targetkey = llDetectedKey(0);
                tgtisav = FALSE;
                target = TRUE;
            }  
        }
    }
    
    no_sensor()
    {
        if (target)
        {
            //llOwnerSay("Target Lost");
            targetkey = NULL_KEY;
            target = FALSE;
        }
    }
    
    listen(integer chan, string name, key id, string msg)
    {
        if (llGetOwnerKey(id) == llGetOwner())
        {
            llSetLinkPrimitiveParamsFast(emitter,[PRIM_POINT_LIGHT, FALSE, <1.000, 0.500, 0.000>, 1, 0.4, 0]);
            if (msg == "draw")
            {
                if (holstered)
                {
                    llRequestPermissions(llGetOwner(), gPermFlags);
                    llStartAnimation("GunArmDraw");
                    llStopAnimation("HandRelaxer");
                    llSleep(.5);
                    llSay(-1899, "unholster");
                    llSetLinkAlpha(LINK_SET,1.0,ALL_SIDES);
                    integer i;
                    for (i=0;i<5;i++)
                    {
                        if (llList2Integer(ammolist,i) == 0)
                        {
                            llSetLinkAlpha(cylinder, 0.0, llList2Integer(chamberlist,i));
                        }
                    }
                    llTriggerSound("Unholster",1);
                    UpdateHand("GunGrip");
                    llSleep(.1);
                    holstered = FALSE;
                    UpdateArm(holdstyle);
                    llSetTimerEvent(.1);
                }else
                {
                    if (cocked)
                    {
                        if (spinning)SpinGun(FALSE);
                        CockFire(TRUE);
                    }else
                    {
                        hipfire = 1;
                        llSetTimerEvent(0);
                        if (spinning)
                        {
                            UpdateArm("GunArmSpinHolster");
                            llSleep(.3);
                            llTargetOmega(<0.0,0.0,0.0>*llGetLocalRot(),TWO_PI,0);
                            llSetText("1", ZERO_VECTOR, 1.0);llSetText("", ZERO_VECTOR, 0.0);
                            llStopSound();
                            spinning = FALSE;
                        }else
                        {
                            llStartAnimation("GunArmHolster");
                            llStopAnimation(aA);
                            llSleep(.9);
                        }
                        llStopAnimation(hA);
                        llSetLinkAlpha(LINK_SET,0.0,ALL_SIDES);
                        llTriggerSound("Holster",1);
                        llSay(-1899, "holster");
                        llStartAnimation("HandRelaxer");
                        holstered = TRUE;
                        mouselook = 0;
                    }
                }
            }
            
            if (msg == "av")
            {
                 llSensorRepeat("", NULL_KEY, AGENT, 10, 0.5,.1);
                 llOwnerSay("Hipfire targets set to av's"); 
                 targetkey = NULL_KEY; target = FALSE;}
            if (msg == "object")
            {
                 llSensorRepeat("", NULL_KEY, ACTIVE, 10, 0.5,.1);
                 llOwnerSay("Hipfire targets set to objects"); 
                 targetkey = NULL_KEY; target = FALSE;}
            if (msg == "all")
            {
                 llSensorRepeat("", NULL_KEY, AGENT|ACTIVE, 10, 0.5,.1);
                 llOwnerSay("Hipfire targets set to all");
                 targetkey = NULL_KEY; target = FALSE;
            }
            
            if (msg == "reload")
            {
                if(!holstered)
                {
                    if(!spinning)savedAnim = aA;
                    Reload();
                }
            }
            if (msg == "spin")
            {
                if (!holstered)
                {
                    if (spinning)
                    {
                        SpinGun(FALSE);
                    }else
                    {
                        SpinGun(TRUE);
                    }
                }
            }
            
            if (msg == "bullet")
            {
                bulletSettings = llListen(-1899, "", llGetOwner(), "");
                llTextBox( llGetOwner(), "Welcome to the Bullet Balancing Menu. \n Please don't use this function unless you understand how it works. \nInput 2 numbers separated by a comma. \nThe first number is the bullet velocity. \nThe second number is bullet padding, or how many meters the bullet should detect in front of it to accurately proc the bullet effect and collisions. (Default 75,3). \nThe Goal of this menu is to fine tune the bullet to create accurate hit effects, without the bullet despawning too late or early.", -1899);
            }
            
            if (chan == -1899)
            {
                llSetLinkPrimitiveParamsFast(5, [PRIM_DESC, msg]);
                list bInfo = llParseString2List(msg,[",", " "],[]);
                gVelocity = llList2Float(bInfo,0);
                dist = llList2Integer(bInfo,1);
                llOwnerSay("Velocity set to: " + (string)gVelocity + " BulletPadding set to: " + (string)dist);
                llListenRemove(bulletSettings);
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
            if ( start & CONTROL_ML_LBUTTON)
            {
                rotation Rot = llGetCameraRot();
                CockFire(FALSE);
            }
            
            if (held & CONTROL_LBUTTON)
            {
                llStopAnimation("HipFire");
                llSleep(0.1);
                hipfire = 20;
                HipFire();
            }
        }
    }

    touch_start(integer num)
    {
        if (!holstered)
        {
            if (flipflop)
            {
                holdstyle = "GunArmDown";
                UpdateArm(holdstyle);
                flipflop = FALSE;
                
            }else
            {
                holdstyle = "GunArmRun";
                UpdateArm(holdstyle);
                flipflop = TRUE;
            }
        }
    }

    timer()
    {
        if (hipfire > 0 || (!hipfire && aA == "HipHold"))
        {
            savedAnim = holdstyle;
            if (hipfire > 0)hipfire--;
            if (!hipfire && !spinning && !aiming)UpdateArm(savedAnim);
            //llOwnerSay((string)hipfire);
        }
        
        if (!aiming && !spinning)
        {
            string anim = llGetAnimation(llGetOwner());
            if (anim == "Running" || anim == "Jumping")
            {
                if (aA != "GunArmRun")UpdateArm("GunArmRun");
            }else if (holdstyle != "GunArmRun")
            {
                if (aA == "GunArmRun")UpdateArm("GunArmDown");
            }
        }
        
        integer new_mouselook = llGetAgentInfo(llGetOwner())&AGENT_MOUSELOOK;
        if (new_mouselook != mouselook)
        {
            mouselook = new_mouselook;
            if(mouselook)
            {
                if (!spinning)
                {
                    aiming = TRUE;
                    UpdateArm("GunArmAim");
                }else
                {
                    savedAnim = "GunArmAim";
                }
            }
            else
            {
                if (!spinning)
                {
                    aiming = FALSE;
                    UpdateArm(holdstyle);
                }else
                {
                    savedAnim = holdstyle;
                } 
            } 
        }
        if (emit > 0)
        {
            emit--;
            if (emit == 0)
            {
                llSetLinkPrimitiveParamsFast(emitter,[PRIM_POINT_LIGHT, FALSE, <1.000, 0.500, 0.000>, 1, 0.4, 0]);
                llLinkParticleSystem(emitter,[]);
            }
        }
        
        if (cocked && spinning)
        {
            if (llFrand(40) > 39)Mishap();
        }
    }
}