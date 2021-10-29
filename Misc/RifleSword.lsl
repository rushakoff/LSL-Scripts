integer SwordDrawn = FALSE;
integer GunDrawn = FALSE;
integer hit;
integer updown;
integer handle;
integer CONTROLS;

string idle = "GunHold";
string aim = "GunAim";
integer mouselook;
integer crouched;
integer aiming;
integer inpressC;
integer inpressWASD;

string SwordHold = "SwordHold";

vector gunpos = <0.08253, -0.05238, -0.01660>;
vector swordpos = <0.04977, -0.02949, -0.01284>;

rotation gunrot = <-0.66267, 0.36278, -0.31052, 0.57691>;
rotation swordrot = <-0.58101, 0.09835, -0.15303, 0.79330>;

string  gBullet = "Bullet0.6";
float   gVelocity   = 75.0;

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
        llSleep(0.1);
        llStopAnimation(llGetInventoryName(INVENTORY_ANIMATION,x));
    }
    llOwnerSay("Done");
}

SetAlpha(integer draw)
{
    if (draw)
    {
        llSetLinkAlpha(LINK_SET,1,ALL_SIDES);
        llSetLinkAlpha(1,0,ALL_SIDES);
        llSetLinkAlpha(2,0,ALL_SIDES);
        llSetLinkAlpha(4,0,0);
        llSetLinkAlpha(8,0,0);
        llSetLinkAlpha(6,0,0);
        llSetLinkAlpha(5,0,0);
        llSetLinkAlpha(10,0,0);
        llSetLinkAlpha(7,0,0);
    }else
    {
        llSetLinkAlpha(LINK_SET,0,ALL_SIDES);
    }
    
}

handmode(integer mode)
{
    llStopAnimation("handrelax");
    llStopAnimation("handhold");
    llStopAnimation("handpoint");
    if (mode == 1)llStartAnimation("handrelax");
    if (mode == 2)llStartAnimation("handhold");
    if (mode == 3)llStartAnimation("handpoint");
}

holdanim()
{
    if((SwordDrawn)&&(!GunDrawn))
    {
        if (SwordHold == "SwordHold")
        {
            llStopAnimation(SwordHold);
            SwordHold = "2HandHold";
            llStartAnimation(SwordHold);
            //llOwnerSay("SwordAnim changed to Hands");
        }else
        {
            llStopAnimation(SwordHold);
            SwordHold = "SwordHold";
            llStartAnimation(SwordHold);
            //llOwnerSay("SwordAnim changed to Shoulder");
        }
    }
}

burst(integer onoff)
{
    if (onoff)
    {
         llLinkParticleSystem(2,[
            PSYS_PART_FLAGS,
                PSYS_PART_INTERP_COLOR_MASK|
                PSYS_PART_INTERP_SCALE_MASK|
                PSYS_PART_FOLLOW_VELOCITY_MASK|
                PSYS_PART_EMISSIVE_MASK,
            PSYS_PART_START_ALPHA,.76,
            PSYS_PART_END_ALPHA,.0,
            PSYS_PART_START_SCALE,<.2,.3,0>,
            PSYS_PART_END_SCALE,<.5,.2,0>,
            PSYS_PART_MAX_AGE,.9,
            PSYS_SRC_PATTERN,
                PSYS_SRC_PATTERN_ANGLE,
            PSYS_SRC_TEXTURE,(key)"fc4b9f0b-d008-45c6-96a4-01dd947ac621",
            PSYS_SRC_BURST_RATE,1.0,
            PSYS_SRC_BURST_PART_COUNT,128,
            PSYS_SRC_BURST_RADIUS,.1,
            PSYS_SRC_BURST_SPEED_MIN,.2,
            PSYS_SRC_BURST_SPEED_MAX,.8,
            PSYS_SRC_ANGLE_END,6.0
        ]);
    }else
    {
         llLinkParticleSystem(2,[]);
    }
    
}
default
{
    changed(integer change)
    {
        if(change & CHANGED_OWNER)
        { // Either of the changes will return true.
            llResetScript();
        }
    }
    attach(key id)
    {
        if(id)llResetScript();
    }
    state_entry()
    {
        llResetOtherScript("Claymore_Trigger");
        llRequestPermissions(llGetOwner(), PERMISSION_TAKE_CONTROLS | PERMISSION_TRIGGER_ANIMATION | PERMISSION_TRACK_CAMERA);
        CONTROLS = CONTROL_FWD | CONTROL_BACK | CONTROL_LEFT | CONTROL_RIGHT | CONTROL_DOWN | CONTROL_LBUTTON | CONTROL_ML_LBUTTON;
        llSetLinkAlpha(LINK_SET,0,ALL_SIDES);
        handle = llListen(1,"",llGetOwner(),"");
    }
    
    run_time_permissions(integer perm)
    {
        if( PERMISSION_TRIGGER_ANIMATION & perm)
        {
            Preload();
            llStopAnimation("GunHold");
            llStopAnimation(SwordHold);
            handmode(1);
            //llOwnerSay("Animations Ready");
            llSensorRepeat("", NULL_KEY, AGENT_BY_LEGACY_NAME, 2, 0.7,.5);
        }
        
    }
    
    touch_start(integer id)
    {
        /*vector pos = llGetLocalPos();
        rotation rot = llGetLocalRot();
        llOwnerSay((string)pos + " | " + (string)rot);*/
        
        if (llDetectedKey(0) == llGetOwner())
        {
            holdanim();
        }
    }
    
    sensor( integer id )
    {
        string message = "Detected " + (string)id+ " avatar(s): " + llDetectedName(0);
        //llOwnerSay(message);
        hit = TRUE;
    }
    
    no_sensor()
    {
        hit = FALSE;
    }
    
    control(key id, integer held, integer change)
    {
        if ((held & ~change) & CONTROL_DOWN)
        {
            if (!inpressC)
            {
                inpressC = TRUE;
                if (aiming)
                {
                    llStopAnimation(aim);
                    llStartAnimation("CrouchAim");
                }
                crouched = TRUE;
            }
        }
        
         if ((held & ~change) & (CONTROL_FWD| CONTROL_BACK | CONTROL_LEFT | CONTROL_RIGHT))
        {
            if (crouched & GunDrawn)
            {
                if (!inpressWASD)
                {
                    inpressWASD = TRUE;
                    llSleep(.8);
                    llStopAnimation(idle);
                    llSleep(.1);
                    llStartAnimation(idle);
                    //lOwnerSay("Crouchhold");
                }
            }
        }
        
        if ((~held & change) & (CONTROL_FWD | CONTROL_BACK | CONTROL_LEFT | CONTROL_RIGHT))
        {
            if (!((held & ~change) & (CONTROL_FWD| CONTROL_BACK | CONTROL_LEFT | CONTROL_RIGHT)))
            {
                inpressWASD = FALSE;
            }  
        }
        
        if ((~held & change) & CONTROL_DOWN)
        {
            crouched = FALSE;
            inpressC = FALSE;
            inpressWASD = FALSE;
            if (aiming)
            {
                llStopAnimation("CrouchAim");
                llStartAnimation(aim);
            }else
            {
                llStopAnimation("CrouchAim");
            }
        }
        
        
        if ((SwordDrawn) && (!GunDrawn))
        {
            if ((held & change) & CONTROL_LBUTTON)
            {
                    float rnd = llFrand(2.0);
                    while (updown == llRound(rnd))
                    {
                        rnd = llFrand(2.0);
                    }
                    updown = llRound(rnd);
                    integer sndnum = llRound(llFrand(2));
                    llTriggerSound("swing" + (string)sndnum, .8);
                    if (hit)
                    {
                        llStartAnimation("SwordHit"+(string)updown);
                        llTriggerSound("swipe", .8);
                    }else
                    {
                        llStartAnimation("SwordSwing"+(string)updown);   
                    }
            }
        }
        
        if ((SwordDrawn) && (GunDrawn))
        {
             if ((held & change) & CONTROL_ML_LBUTTON)
            {
                llTriggerSound("Gunshot",1);
                if (crouched)llStartAnimation("CrouchFire");
                if (!crouched)llStartAnimation("GunFire");
                if ((llGetParcelFlags(llGetPos()) & PARCEL_FLAG_ALLOW_CREATE_OBJECTS))
                {
                    rotation Rot = llGetCameraRot();
                    llRezAtRoot(gBullet, llGetCameraPos() + <2.0, 0.0, 0.0>*Rot, gVelocity*llRot2Fwd(Rot), Rot, 10);
                }
                burst(1);
                llSleep(.5);
                burst(0);
            }
        }
    }
    
    listen(integer chan, string name, key id, string msg)
    {
        if (msg == "draw")
        {
            if ((SwordDrawn)||(GunDrawn))
            {
                if (GunDrawn)
                {
                    llSetTimerEvent(0);
                    llStopAnimation(idle);
                    llStopAnimation(aim);
                    llStartAnimation("SwordMode");
                    llSleep(.5);
                    llSetPos(swordpos);
                    llSetLocalRot(swordrot);
                    llStartAnimation(SwordHold);
                    handmode(2);
                    llSleep(.3);
                }
                llStopAnimation(SwordHold);
                llStartAnimation("SwordSheath");
                llSleep(.3);
                llTriggerSound("Holster",1);
                llSleep(.4);
                llSay(-666, "SwordSheath"); 
                SetAlpha(0);
                handmode(1);
                SwordDrawn = FALSE;
                GunDrawn = FALSE;
                aiming = FALSE;
                
            }else
            {
                llTakeControls(CONTROLS, TRUE, TRUE);
                llSetPos(swordpos);
                llSetLocalRot(swordrot);
                llStartAnimation("SwordDraw");
                llSleep(.4);
                handmode(2);
                llSay(-666, "SwordDraw");
                SetAlpha(1);
                llTriggerSound("Unholster",1);
                SwordDrawn = TRUE;
                llSleep(.3);
                llStartAnimation(SwordHold);
            }
        }
        
        if (msg == "change")
        {
            llListenRemove(handle);
            if (SwordDrawn)
            {
                if (GunDrawn)
                { 
                    llSetTimerEvent(0);
                    llStopAnimation(idle);
                    llStopAnimation(aim);
                    llStartAnimation("SwordMode");
                    llSleep(.5);
                    handmode(2);
                    llSetPos(swordpos);
                    llSetLocalRot(swordrot);
                    llStartAnimation(SwordHold);
                    GunDrawn = FALSE;
                    //llSleep(.3);
                    handle = llListen(1,"",llGetOwner(),"");
                }else
                {
                    llStopAnimation(SwordHold);
                    llStartAnimation("GunMode");
                    llSleep(.3);
                    llSetPos(gunpos);
                    llSetLocalRot(gunrot);
                    llSetTimerEvent(.1);
                    handmode(3);
                    llStartAnimation(idle);
                    GunDrawn = TRUE;
                    //llSleep(1.6);
                    handle = llListen(1,"",llGetOwner(),"");
                }
            }else
            {
                llTakeControls(CONTROLS, TRUE, TRUE);
                llStartAnimation("SwordDraw");
                llSleep(.4);
                //llPlaySound("Sword unsheath",1);
                handmode(2);
                llSay(-666, "SwordDraw");
                SetAlpha(1);
                SwordDrawn = TRUE;
                llStopAnimation(SwordHold);
                llStartAnimation("GunMode");
                llSleep(.3);
                llSetPos(gunpos);
                llSetLocalRot(gunrot);
                llSetTimerEvent(.1);
                handmode(3);
                llStartAnimation(idle);
                GunDrawn = TRUE;
                handle = llListen(1,"",llGetOwner(),"");
            }
        }
        
        if (msg == "hold")
        {
            holdanim();
        }
    }
    
     timer()
    {
        integer new_mouselook = llGetAgentInfo(llGetOwner())&AGENT_MOUSELOOK;
        if (new_mouselook != mouselook)
        {
            mouselook = new_mouselook;
            if(mouselook)
            {
                aiming = TRUE;
                if (crouched)
                {
                    llStopAnimation(idle);
                    llStartAnimation("CrouchAim");
                }else
                {
                    llStopAnimation(idle);
                    llStartAnimation(aim);
                }
            }
            else
            {
                aiming = FALSE;
                if (crouched)
                {
                    llStopAnimation("CrouchAim");
                    llStartAnimation(idle);   
                }else
                {
                    llStopAnimation(aim);
                    llStartAnimation(idle);
                }
            }  
        }
    }
}
