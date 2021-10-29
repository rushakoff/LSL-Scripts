// initializing take control variables
integer gBooPermissions = FALSE;
integer gBooAccept = TRUE;
integer gBooPassOn = TRUE;

//this is the code for sending messages to the scouter display prims
integer DISPLAY_STRING      = 204000;
integer DISPLAY_EXTENDED    = 204001;
integer REMAP_INDICES       = 204002;
integer RESET_INDICES       = 204003;
integer SET_CELL_INFO       = 204004;
integer SET_TARGET_CHANNEL  = 100100;
integer SET_POWER_CHANNEL   = 200200;

//prim link numbers for the temporary white display prims
integer TgtDsp1 = 11;
integer TgtDsp2 = 10;
integer PwrDsp1 = 8;
integer PwrDsp2 = 9;

//link numbers for the health bar prims
integer HlthBr1 = 49;
integer HlthBr2 = 36;
integer HlthBr3 = 30;
integer HlthBr4 = 25;
integer HlthBr5 = 20;
integer HlthBr6 = 16;

//link numbers for stamina display prims
integer stmBr1 = 45;
integer stmBr2 = 48;
integer stmBr3 = 43;
integer stmBr4 = 42;
integer stmBr5 = 34;
integer stmBr6 = 35;
integer stmBr7 = 24;
integer stmBr8 = 22;
integer stmBr9 = 19;
integer stmBr10 = 18;

//link numbers for Ki display prims
integer kiBr1 = 37;
integer kiBr2 = 27;
integer kiBr3 = 17;
integer kiBr4 = 13;

//initial player stats
float pwrlvl;
integer rank;
integer exp ;
integer health;
integer stamina;
integer ki = 4;
integer damage = 0;
integer expMax;
integer dead = FALSE;

//base stats and percentage variables for health stam
//health
float hlthbs = 0;
float hlthBrPct1 = 0;
float hlthBrPct2 = 0;
float hlthBrPct3 = 0;
float hlthBrPct4 = 0;
float hlthBrPct5 = 0;
float hlthBrPct6 = 0;

//stamina
float stmbs = 0;
float stmBrPct1 = 0;
float stmBrPct2 = 0;
float stmBrPct3 = 0;
float stmBrPct4 = 0;
float stmBrPct5 = 0;
float stmBrPct6 = 0;
float stmBrPct7 = 0;
float stmBrPct8 = 0;
float stmBrPct9 = 0;
float stmBrPct10 = 0;

//initial target info
string tgtNm = "";
integer tgthp;
integer tgtdmg = 0;
float tgtPos;
//channels the script will eventually be sending messages to
integer FightChannel = 1;
integer TargetChannel = 1;
integer AbilityChannel = 1;
integer TeamChannel;
//let the script know whether its ready to target or not.
integer statsgathered = 0;
integer Targeting = FALSE;
integer TargetLocked = FALSE;
integer attacktimer = 0;
//position related variables
vector myPos;
key tgtID_1 = "";
key tgtID_2 = "";
key tgtKey = "";
integer pos1found = FALSE;
integer pos2found = FALSE;
integer pos3found = FALSE;
float dist1;
float dist2;
integer targetable = TRUE;
integer jumpsound = TRUE;
integer movespeed = -225;
float FForce = 0.0;
float SForce = 0.0;
float UForce = 0.0;
float FollowForce = 3;
integer still_attacking = FALSE;
integer still_blocking = TRUE;
//variable to help me pick between targets
integer scanning = 0;
integer launch_time = 0;
integer launched = FALSE;
integer LForce;
integer launchedup;
string launchanim;
string launchblockanim;
string launchhitanim;
//variables used for making per player channels
key uuid;
integer myChan;
integer tgtChan;
Find_Channel(key uuid, integer who)
{
        integer i;
        for (i = 0; i < 36; i++) //Loop through each of the UUID characters
        {
            string str = llGetSubString((string)uuid,i,i); //Take each character and if it is not an actual number, convert it to a number
            if (str == "a") str = "10";
            else if (str == "b") str = "11";
            else if (str == "c") str = "12";
            else if (str == "d") str = "13";
            else if (str == "e") str = "14";
            else if (str == "f") str = "15";
            integer num = (integer)str * i; //Multiply the number by its place in the UUID
            if (who == 1)
            {
                myChan += num; //Add them together
            }else if (who == 2)
            {
                tgtChan += num;
            }   
        }
    }
//WHAT A LONG LIST OF VARIABLES!\\

//USER DEFINED FUNCTIONS\\

All_Listens()
{
    llListen(0,"",llGetOwner(),"");
    llListen(1337,"",llGetOwner(),"");
    llListen(3334,"","","");
    llListen(434,"","","");
    //llListen(435,"","","");
    llListen(TargetChannel,"","","");
    llListen(myChan,"","","");
    llListen(5347,"","","");
    llListen(6430,"","","");
    llListen(AbilityChannel,"","","");

}
Display_Function()
{
    Camera_Control(launched);
    llStopAnimation("falldown");
    tgtPos = Vector2Avatar(llList2Vector(llGetObjectDetails(tgtKey, [OBJECT_POS]),0));
    llOwnerSay("@setrot:"+(string)tgtPos+"=force");
    //if you are dead this is how i show it.
        if (health < 1)
        {
            dead = TRUE;
         //otherwise just display your current HP   
        }else
        {
            llShout(5347, (string)health);
        }
        
        
        //all this is for controlling the HUD displays
        //display target stats
        llMessageLinked(LINK_SET,SET_POWER_CHANNEL, (string)tgthp, "");    
        llSetLinkPrimitiveParamsFast(2, [ PRIM_TEXT, (string)health, <1,1,1>,1.0 ]);
        llSetLinkPrimitiveParamsFast(7, [ PRIM_TEXT, (string)stamina, <1,1,1>,1.0 ]);
        
        //update display your health bar
        llSetLinkAlpha(HlthBr1, (health - hlthBrPct1)/100, ALL_SIDES);
        llSetLinkAlpha(HlthBr2, (health - hlthBrPct2)/100, ALL_SIDES);
        llSetLinkAlpha(HlthBr3, (health - hlthBrPct3)/100, ALL_SIDES);
        llSetLinkAlpha(HlthBr4, (health - hlthBrPct4)/100, ALL_SIDES);
        llSetLinkAlpha(HlthBr5, (health - hlthBrPct5)/100, ALL_SIDES);
        llSetLinkAlpha(HlthBr6, (health - hlthBrPct6)/100, ALL_SIDES);
        
        //update your stamina bar
        llSetLinkAlpha(stmBr1, (stamina - stmBrPct1)/100, ALL_SIDES);
        llSetLinkAlpha(stmBr2, (stamina - stmBrPct2)/100, ALL_SIDES);
        llSetLinkAlpha(stmBr3, (stamina - stmBrPct3)/100, ALL_SIDES);
        llSetLinkAlpha(stmBr4, (stamina - stmBrPct4)/100, ALL_SIDES);
        llSetLinkAlpha(stmBr5, (stamina - stmBrPct5)/100, ALL_SIDES);
        llSetLinkAlpha(stmBr6, (stamina - stmBrPct6)/100, ALL_SIDES);
        llSetLinkAlpha(stmBr7, (stamina - stmBrPct7)/100, ALL_SIDES);
        llSetLinkAlpha(stmBr8, (stamina - stmBrPct8)/100, ALL_SIDES);
        llSetLinkAlpha(stmBr9, (stamina - stmBrPct9)/100, ALL_SIDES);
        llSetLinkAlpha(stmBr10, (stamina - stmBrPct10)/100, ALL_SIDES);
}

Setup_State_Function()
{
       
    llSetLinkPrimitiveParamsFast(3, [ PRIM_TEXT, (string)damage, <1,1,1>,1.0 ]);
    llSetLinkPrimitiveParamsFast(5, [ PRIM_TEXT, (string)FightChannel, <1,1,1>,1.0 ]);
        
    llSetLinkPrimitiveParamsFast(4, [ PRIM_TEXT, (string)tgtdmg, <1,1,1>,1.0 ]);
    llSetLinkPrimitiveParamsFast(6, [ PRIM_TEXT, (string)TargetChannel, <1,1,1>,1.0 ]);
    llMessageLinked(LINK_SET,SET_TARGET_CHANNEL, tgtNm, "");
    
    llSetTimerEvent(0.15);
}

Scanning_Target(string msg, integer tgtNum)
{
    if (tgtNum == 1)
    {
        list tgtInfo = llParseString2List( msg, ["|"], [] );
        integer teamID = llList2Integer(tgtInfo,1);
         if (teamID == TeamChannel)
        {
            return;
        }else
        {
            tgtID_1 = llList2Key(tgtInfo,0);
            dist1 = llVecDist(llList2Vector(llGetObjectDetails(tgtID_1, [OBJECT_POS]),0), llGetPos());
            llOwnerSay( (string)dist1);
            llOwnerSay( "target 1 = " + (string)tgtID_1);
            pos1found = TRUE;
        }        
    }
    
    if (tgtNum == 2)
    {
        list tgtInfo = llParseString2List( msg, ["|"], [] );
        integer teamID = llList2Integer(tgtInfo,1);
        if (teamID == TeamChannel)
        {
            return;
        }else
        {
            tgtID_2 = llList2Key(tgtInfo,0);
            dist2 = llVecDist(llList2Vector(llGetObjectDetails(tgtID_2, [OBJECT_POS]),0), llGetPos());
            llOwnerSay( (string)dist2);
            llOwnerSay( "target 2 = " + (string)tgtID_2);
            pos2found = TRUE;
        }
    }
    
    if (tgtNum == 4)
    {
        Find_Channel(tgtID_1,2);
        llListen(tgtChan,"","","");
        llSetTimerEvent(0);
        llTriggerSound("acquired",1);
        tgtKey = tgtID_1;
        llShout(tgtChan, "targetme");
    }
    
    if (tgtNum == 5)
    {
        Find_Channel(tgtID_2,2);
        llListen(tgtChan,"","",""); 
        llSetTimerEvent(0);
        llTriggerSound("acquired",1);
        tgtKey = tgtID_2;
        llShout(tgtChan, "targetme");
    }    
}

Combat_Listens_Function(integer chan, string msg, integer isHit)
{
    /*if(chan == 435)
    {
        if (msg == "LsnAttk")
        {
            llListen(TargetChannel,"","","");
        }else if (msg == "IgnrAttk")
            llListenRemove(llListen(TargetChannel,"","",""));
        }*/
        
        //this listens for the targets health so that it can be updated
        if (chan == 5347)
        {
            tgthp = (integer)msg;
            if (tgthp == 0)
            {
                state finalize_fight;
            }
        }
        
        if (chan == 6430)
        {
            if (msg == "END"){ state finalize_fight;}
        }
    
    float tgtDist = llVecDist(llList2Vector(llGetObjectDetails(tgtKey, [OBJECT_POS]),0), llGetPos());
     if (tgtDist < 2.2)
    {    
        //listens for damage notifications and plays a random hit reaction animation and updates your own health
        if (chan == TargetChannel)
        {
            if (msg=="hit" && health > 0)
            {
                if (isHit == 1)
                {
                    float hitanim = 12 + llFrand(-12);
                    if (hitanim > 6)
                    {
                        llStartAnimation("hitreact1");
                    }else 
                    {
                        llStartAnimation("hitreact2");
                    }
                    
                    if (hitanim < 4)
                    {
                        llTriggerSound("weakkick", 1);
                    }else if (hitanim > 3 && hitanim < 9)
                    {
                        llTriggerSound("mediumpunch",1);
                    }else if (hitanim > 8)
                    {
                        llTriggerSound("mediumkick",1);
                    }
                    llShout(myChan, "hiteffect");
                    health -= tgtdmg;
                }else if (isHit == 0)
                {
                    float hitanim = 12 + llFrand(-12);
                    if (hitanim < 4)
                    {
                        llTriggerSound("weakkick", 1);
                    }else if (hitanim > 3 && hitanim < 9)
                    {
                        llTriggerSound("mediumpunch",1);
                    }else if (hitanim > 8)
                    {
                        llTriggerSound("mediumkick",1);
                    }
                    stamina -= (tgtdmg*2);
                    llShout(myChan, "blockeffect"); 
                }else if (isHit == 2)
                {
                    if (stamina > 0)
                    {
                         float hitanim = 12 + llFrand(-12);
                        if (hitanim < 4)
                        {
                            llTriggerSound("meleemiss1",1);
                        }else if (hitanim > 3 && hitanim < 9)
                        {
                            llTriggerSound("meleemiss2",1);
                        }else if (hitanim > 8)
                        {
                            llTriggerSound("meleemiss3",1);
                        }
                        
                        stamina -= (tgtdmg*3);
                        llStartAnimation("dodging");
                    }
                }
            }
        
        
            if (msg=="LUp" && health > 0)
            {
                Camera_Control(1);
                LForce = 200;
                launchblockanim = "Launch_Up_Block";
                launchhitanim = "Launch_Up_Hit";
                state being_launched;
            }
            
            if (msg=="LDown" && health > 0)
            {
                Camera_Control(1);
                LForce = -200;
                launchblockanim = "Launch_Up_Block";
                launchhitanim = "Launch_Down_Hit";
                state being_launched;
            }
        }
    }
    
    if (chan == AbilityChannel)
    {
         list Specialinfo = llParseString2List( msg, ["|"], [] );
         
            string atkType = llList2String(Specialinfo, 0);
            integer atkDmg = llList2Integer(Specialinfo, 1);
            
         if (atkType== "kihit")
            {
                if (isHit = 2)
                {
                    float blockanim = 10 + llFrand(-10);
                    if (blockanim > 5){
                        llStartAnimation("blockhitleft");
                    }else 
                    {
                        llStartAnimation("blockhitright");
                    }
                }else
                {
                    health -= (tgtdmg*atkDmg);
                }
            }
    }
}

Target_Listens(integer chan, string msg, integer cantarget)
{
     //go to the target setup state
        if (chan == 0)
        {
            if (msg=="target" && cantarget)
            {
                llOwnerSay("Locating Target for " + (string)llKey2Name(llGetOwner()));
                //create a temporary unique channel to send to a target
                Targeting = TRUE;
                state searching;
            }
            
             if (msg=="untarget")
            {
                llResetScript();
            }
            
            if (msg == "off")
            {
                targetable = FALSE;
                cantarget = FALSE;
                llSetLinkPrimitiveParamsFast (53, [PRIM_COLOR, ALL_SIDES, <0.161, 0.373, 0.235>, 1.0]); 
            }
            
            if (msg == "on")
            {   
                targetable = TRUE;
                cantarget = TRUE;
                llSetLinkPrimitiveParamsFast (53, [PRIM_COLOR, ALL_SIDES, <1.000, 1.000, 1.000>, 1.0]); 
            }
        } 
        
        if(chan == 1337)
        {
            TeamChannel = (integer)msg; 
            llOwnerSay("You are now on Team " + (string)TeamChannel);
        }

        //listens for huds in the target setup state asking for this huds position and ID
        if (chan == 434)
        {
            if (msg=="targeting" && targetable)
            {
                //send this huds player specifc channel and his current position
                llShout(3334, (string)llGetOwner() + "|" + (string)TeamChannel);
            }
        }  
        
        //if this hud has been picked by the hud that is currently targeting players, give player information
        if (chan == myChan)
        {
            if (msg == "targetme") 
            {
                // if this hud is the chosen target, it gives the targeting player your health, name, damage output, and temporary fighting channel
                llOwnerSay( "sending info for " + (string)llKey2Name(llGetOwner()));
                llShout(myChan,(string)health + "|" + (string)damage +  "|" + (string)FightChannel + "|" + "1");
            }
        }
}

float Vector2Avatar(vector vec)
{
    vec = vec-llGetPos();
    vector fwd = vec * <0.0, 0.0, -llSin(PI_BY_TWO * 0.5), llCos(PI_BY_TWO * 0.5)>;
    fwd.z = 0.0;
    fwd = llVecNorm(fwd);
    vector left = fwd * <0.0, 0.0, llSin(PI_BY_TWO * 0.5), llCos(PI_BY_TWO * 0.5)>;
    rotation rot = llAxes2Rot(fwd, left, fwd % left);
    vector euler = -llRot2Euler(rot);
    return euler.z;
}

Movement_Function(integer held, integer change )
{
    integer pressed = held & change;
        integer down = held & ~change;
        integer released = ~held & change;
        integer inactive = ~held & ~change;
        
        integer FWD_LT = CONTROL_ROT_LEFT & CONTROL_FWD;
        integer BCK_LT = CONTROL_ROT_LEFT & CONTROL_BACK;
        integer FWD_RT = CONTROL_ROT_RIGHT & CONTROL_FWD;
        integer BCK_RT = CONTROL_ROT_RIGHT & CONTROL_BACK;
        
        // Level 1   = W
        // Level 2   = S
        // Level 16  = E
        // Level 17  = W + E
        // Level 32  = C
        // Level 33  = W + C
        // Level 256 = A
        // Level 257 = W + A
        // Level 512 = D
        // Level 513 = W + D
        
        //PRESSED\\
        
    
    if(still_blocking)
    {
        float tgtDist = llVecDist(llList2Vector(llGetObjectDetails(tgtKey, [OBJECT_POS]),0), llGetPos());
        if (tgtDist > 1.5)
        {    
            if (down & CONTROL_FWD) 
            {
                if (tgtDist < 65)
                {
                    llStartAnimation("FlyForward");
                    FollowForce = 1.0;
                    llStopMoveToTarget();
                    llMoveToTarget(llList2Vector(llGetObjectDetails(tgtKey, [OBJECT_POS]),0), FollowForce);
                }else
                {
                    llStartAnimation("FlyForward");
                    FForce = movespeed;
                    llSetForce(llGetMass()*<FForce,SForce,UForce>,TRUE);
                }
            }
        }else{ llStopMoveToTarget();}
    
        if (down & CONTROL_BACK) 
        {
            FollowForce = 10.0;
            llStopMoveToTarget();
            llMoveToTarget(llList2Vector(llGetObjectDetails(tgtKey, [OBJECT_POS]),0), FollowForce);
            llStartAnimation("strafeBack");
            FForce = movespeed;
            llSetForce(llGetMass()*<FForce,SForce,UForce>,TRUE);
        }
    }
        
        if (down & CONTROL_ROT_LEFT) 
        {
            SForce = llAbs(movespeed);
            llStopMoveToTarget();
            llMoveToTarget(llList2Vector(llGetObjectDetails(tgtKey, [OBJECT_POS]),0), FollowForce);
            llSetForce(llGetMass()*<FForce,SForce,UForce>,TRUE);
            llStartAnimation("strafeLeft");
        }
        
        if (down & CONTROL_ROT_RIGHT) 
        {
            SForce = movespeed;
            llStopMoveToTarget();
            llMoveToTarget(llList2Vector(llGetObjectDetails(tgtKey, [OBJECT_POS]),0), FollowForce);
            llSetForce(llGetMass()*<FForce,SForce,UForce>,TRUE);
            llStartAnimation("strafeRight");
        }

        
        //RELEASED\\
        
         if (released & CONTROL_ROT_LEFT) 
        {
            stop_move();
        }
        
        if (released & CONTROL_ROT_RIGHT) 
        {
            stop_move();
        }
        
        if(still_blocking)
        {
            if (released & CONTROL_FWD) 
            {
                stop_move();
            }
        
            if (released & CONTROL_BACK) 
            {
                stop_move();
            }
        }

}

Camera_Control(integer launchcam)
{
    if (launchcam)
    {
        llSetCameraParams([
                    CAMERA_ACTIVE, TRUE,
                    CAMERA_BEHINDNESS_LAG, 0.0, // (0 to 3) seconds
                    CAMERA_DISTANCE, 10.0, // ( 0.5 to 10) meters
                    CAMERA_FOCUS, llGetPos()
                ]);
    }else
    {
        llSetCameraParams([
                CAMERA_ACTIVE, TRUE,
                CAMERA_BEHINDNESS_LAG, 0.0, // (0 to 3) seconds
                CAMERA_DISTANCE, 5.0, // ( 0.5 to 10) meters
                CAMERA_FOCUS, llList2Vector(llGetObjectDetails(tgtKey, [OBJECT_POS]),0)
            ]);
    }
}

stop_move()
{
    llOwnerSay("@setrot:"+(string)tgtPos+"=force");
    llStopAnimation("FlyForward");
    llStopAnimation("strafeBack");
    llStopAnimation("strafeLeft");
    llStopAnimation("strafeRight");
    llStopAnimation("FlyUp");
    llStopAnimation("FlyDown");
    llStopAnimation("Combo1");
    FollowForce = 3.0;
    FForce = 0.0;
    SForce = 0.0;
    UForce = 0.0;
    llSetForce(llGetMass()*<FForce,SForce,UForce>,TRUE);
    llMoveToTarget(llGetPos(), .1);
}

//Finally the script begins doing things!\\

default
{
    state_entry()
    {
        llRequestPermissions( llGetOwner(), PERMISSION_TAKE_CONTROLS | PERMISSION_TRIGGER_ANIMATION |  PERMISSION_CONTROL_CAMERA );
        llSetLinkPrimitiveParamsFast (53, [PRIM_COLOR, ALL_SIDES, <1.000, 1.000, 1.000>, 1.0]); 
        llSetCameraParams([CAMERA_ACTIVE, FALSE]);   
        //this is how i create user specific channels
        Find_Channel(llGetOwner(),1);
        //give resulting number, this channel is always the same for this player
        
        //create a temporary ever changing channel to each fight.
        FightChannel = myChan * 2;
        AbilityChannel = myChan*3;
        TeamChannel = myChan;

        //establish the listens
        All_Listens();
        llListen(0346,"",llGetOwner(),"");
        //intial player and hud setup
        //stam bar setup
        dead = FALSE;
        scanning = 0;
        string primdesc = llList2String(llGetLinkPrimitiveParams(53, [ PRIM_DESC ]),0);
        llOwnerSay(primdesc);
        list descinfo = llParseString2List(primdesc, [","], [] );
        
        pwrlvl = llList2Float(descinfo, 0);
        rank = llList2Integer(descinfo, 1);
        exp = llList2Integer(descinfo, 2);
        expMax = llList2Integer(descinfo, 3);
        
        stamina = 1000*rank;
        stmbs = 1000*rank;
        stmBrPct1 = ((stmbs*90)/100);
        stmBrPct2 = ((stmbs*80)/100);
        stmBrPct3 = ((stmbs*70)/100);
        stmBrPct4 = ((stmbs*60)/100);
        stmBrPct5 = ((stmbs*50)/100);
        stmBrPct6 = ((stmbs*40)/100);
        stmBrPct7 = ((stmbs*30)/100);
        stmBrPct8 = ((stmbs*20)/100);
        stmBrPct9 = ((stmbs*10)/100);
        stmBrPct10 = ((stmbs*00)/100);
        
        //healthbar setup
        health = llRound(llPow(1000,pwrlvl));
        hlthbs = llRound(llPow(1000,pwrlvl));
        hlthBrPct1 = ((hlthbs*90)/100);
        hlthBrPct2 = ((hlthbs*78)/100);
        hlthBrPct3 = ((hlthbs*58)/100);
        hlthBrPct4 = ((hlthbs*38)/100);
        hlthBrPct5 = ((hlthbs*18)/100);
        hlthBrPct6 = ((hlthbs*0)/100);
        
        //how much damage a player does
        damage = llRound((llPow(10,pwrlvl))*rank);
        //how much experience a player needs to level up
        integer expfull = 1000*rank;
        
        //targets name
        tgtNm = "";
        
        //make everything that might be set invisible on the hud to visible again
        llSetLinkAlpha(LINK_SET, 1.0, ALL_SIDES);
        
        //set the displays for name and powerlevel
        llMessageLinked(TgtDsp1 , SET_CELL_INFO, llList2CSV([SET_TARGET_CHANNEL, 0]), "");
        llMessageLinked(TgtDsp2, SET_CELL_INFO, llList2CSV([SET_TARGET_CHANNEL, 5]), "");
        llMessageLinked(PwrDsp1, SET_CELL_INFO, llList2CSV([SET_POWER_CHANNEL, 0]), "");
        llMessageLinked(PwrDsp2, SET_CELL_INFO, llList2CSV([SET_POWER_CHANNEL, 5]), "");
        llMessageLinked(LINK_SET,SET_TARGET_CHANNEL, "", "");
        llMessageLinked(LINK_SET,SET_POWER_CHANNEL, "", "");

        //stop all the possible animations that might be still playing
        llStopAnimation("readystance");
        llStopAnimation("readystance2");
        llStopAnimation("Combo1");
        llStopAnimation("blocking");
        llStopAnimation("death");
        llStopAnimation("Onground");
        llSetBuoyancy(0.0);

        //set the text on my temp white displays
        llSetLinkPrimitiveParamsFast(2, [ PRIM_TEXT, (string)health, <1,1,1>,1.0 ]);
        llSetLinkPrimitiveParamsFast(3, [ PRIM_TEXT, (string)damage, <1,1,1>,1.0 ]);
        llSetLinkPrimitiveParamsFast(4, [ PRIM_TEXT, (string)tgtdmg, <1,1,1>,1.0 ]);
        llSetLinkPrimitiveParamsFast(5, [ PRIM_TEXT, (string)FightChannel, <1,1,1>,1.0 ]);
        llSetLinkPrimitiveParamsFast(6, [ PRIM_TEXT, (string)TargetChannel, <1,1,1>,1.0 ]);
        llSetLinkPrimitiveParamsFast(7, [ PRIM_TEXT, (string)stamina, <1,1,1>,1.0 ]);
        
        //so i can keep track of how big this script is getting
        llOwnerSay( (string)llGetUsedMemory() + " used out of " + (string)llGetMemoryLimit() );
    }

    attach( key attached )
    {
        // When object containing script is detached
        if (NULL_KEY == attached)
        {
            // Set permissions variable to FALSE
            gBooPermissions = FALSE;
            // Release controls
            llReleaseControls();
            return;
        }

        // When object containing script is attached,
        if (NULL_KEY != attached)
        {
            llResetScript();
            return;
        }
    }
    
    run_time_permissions( integer perms )
    {
        if (PERMISSION_TAKE_CONTROLS & perms)
        {
            // Set permission variable to TRUE
            gBooPermissions = TRUE;
            // llTakeControls( integer control, integer accept, integer pass_on );
            llTakeControls(
                CONTROL_FWD |        // W / Up Arrow
                CONTROL_BACK |       // S / Down Arrow
                CONTROL_LEFT |       // Shift + A / Left Arrow or A / Left Arrow in Mouse Look
                CONTROL_RIGHT |      // Shift + D / Right Arrow or D / Right Arrow in Mouse Look
                CONTROL_UP |         // E / Page Up
                CONTROL_DOWN |       // C / Page Down
                CONTROL_ROT_LEFT |   // A / Left Arrow
                CONTROL_ROT_RIGHT |  // D / Right Arrow
                0, gBooAccept, gBooPassOn );
        }
    }

    listen(integer chan, string name, key id, string msg)
    {
       Target_Listens(chan,msg,TRUE);
       
       if (chan == 0346)
       {
           if (msg == "reset")
           {
              llSetLinkPrimitiveParamsFast(53, [ PRIM_DESC, "1.0,1,0,1000"]); 
              llResetScript();
            }
        }
    }

    changed( integer vChg )
    {
        if (CHANGED_OWNER & vChg)
        {
            llResetScript();
        }
    }
}


//THIS IS WHERE SCANNING AVATARS HAPPENS\\
state searching
{
    state_entry()
    {
        All_Listens();
        llShout(434, "targeting");
        llSetTimerEvent(0.5);
        llTriggerSound("scanning",1);
        tgtChan = 0;
        pos1found = FALSE;
        pos2found = FALSE;
    }

    //timer so that the script has a limited amount of time to sort through targets, unstead of sorting forever
    timer()
    {
        if (scanning < 1)
        {
            //ask nearby huds for position
            scanning += 1;
        }else
        {
            if (tgtID_1 != "")
            {
                if (dist1 < dist2 || dist1 == dist2 )
                {
                    if (tgtID_1 != tgtKey)
                    {
                        Scanning_Target("",4);
                        return;
                    }else if (tgtID_1 != "")
                    {
                        Scanning_Target("",5);
                        return;
                    }else
                    {
                        Scanning_Target("",4);
                        return;
                    }
                }else if (dist2 < dist1)
                {
                    if (tgtID_2 != tgtKey && tgtID_2 != "")
                    {
                        Scanning_Target("",5);
                        return;
                    }else
                    {
                        Scanning_Target("",4);
                        return;
                    }
                }else
                {
                    llTriggerSound("Notarget",1);
                    llSay(0, "target1 = " + (string)tgtID_1 + " at a distance of " + (string)dist1 + ". " + "target2 = " + (string)tgtID_2 + " at a distance of " + (string)dist2 + ".");
                    llResetScript();
                } 
            }else
            {
                llOwnerSay( "no targets in range");
                llTriggerSound("Notarget",1);
                llResetScript();
            } 
        }
        
    }
    

    listen(integer chan, string name, key id, string msg)
    {
        
        // The script sorts incoming messages for 2 seconds
        if (chan == 3334)
        {
            //the script takes the messages it is given and sorts the current one into slot 1
            if (pos1found == FALSE)
            {
                Scanning_Target(msg,1);
                return;
            }else if (pos2found == FALSE)
            {
                Scanning_Target(msg,2);
                return;
            // if both slots are filled the new message overwrites the slot of the target which is farther.    
            }else if (pos1found == TRUE && pos2found == TRUE)
            {
                //if the first target is closer then the new message is saved over target 2
                if (dist1 < dist2)
                {
                    Scanning_Target(msg,2);
                    return;    
            //if the second target is closer the new message is saved over target 1   
                }else if (dist2 < dist1 || dist2 == dist1)
                {
                    Scanning_Target(msg,1);
                    return;    
                } 
            }
        }
                 
        Target_Listens(chan,msg,FALSE);
        
        //this is where i sort the info that the chosen hud has sent me
         if (chan == tgtChan)
        {
            //makes the red light turn green
            llSetLinkAlpha(53, 0.0, ALL_SIDES);

            list tgtInfo = llParseString2List( msg, ["|"], [] );
         
            tgthp = llList2Integer(tgtInfo, 0);
            tgtdmg = llList2Integer(tgtInfo, 1);
            tgtNm = llKey2Name(tgtKey);
            TargetChannel = llList2Integer(tgtInfo, 2);
            TargetLocked = llList2Integer(tgtInfo, 3);
            if (Targeting && TargetLocked)
            {
                //release the controlls so that i can change control PassOn 
                //llReleaseControls();
                state fight;
            }
        }              
    }
}

//THIS IS THE DEFAULT FIGHT STATE\\

state fight
{
    state_entry()
    {
        stop_move();
        All_Listens();
        Setup_State_Function();
        //llSay(435,"IgnrAttk");   
        scanning = 0;
        attacktimer = 0;
        still_blocking = TRUE;
        llSetCameraParams([
            CAMERA_BEHINDNESS_LAG, 0.0, // (0 to 3) seconds
            CAMERA_DISTANCE, 3.0 // ( 0.5 to 10) meters
        ]);        Setup_State_Function();
        llSetBuoyancy(1.0);
        //retake controls with no PassOn so that the script will eventually move you
        gBooPassOn = FALSE;
        llTakeControls(
                CONTROL_FWD |        // W / Up Arrow
                CONTROL_BACK |       // S / Down Arrow
                CONTROL_LEFT |       // Shift + A / Left Arrow or A / Left Arrow in Mouse Look
                CONTROL_RIGHT |      // Shift + D / Right Arrow or D / Right Arrow in Mouse Look
                CONTROL_UP |         // E / Page Up
                CONTROL_DOWN |       // C / Page Down
                CONTROL_ROT_LEFT |   // A / Left Arrow
                CONTROL_ROT_RIGHT |  // D / Right Arrow
                0, gBooAccept, gBooPassOn ); 
       
        
        //starts a random stance animation
         float stanceanim = 10 + llFrand(-10);
                if (stanceanim > 5){
                llStartAnimation("readystance");
                } else {
                    llStartAnimation("readystance2");
                }
        //stop any animations that might be playing when coming back to this state        
        llStopAnimation("Combo1");
        llStopAnimation("blocking");
    
    }
    
    timer()
    {  
        //recharge stamina while idle
        if (stamina < stmbs)
        {
            stamina += llRound(3 * damage);
        }
        
        if (dead)
        {
            state finalize_fight;
        }
        
        Display_Function();
    }

    listen(integer chan, string name, key id, string msg)
    {
        
       Target_Listens(chan,msg,TRUE);
        
       Combat_Listens_Function(chan, msg, 1);
    }
        
     control( key name, integer held, integer change )
     { 
        integer pressed = held & change;
        integer down = held & ~change;
        integer released = ~held & change;
        integer inactive = ~held & ~change;
        
        Movement_Function(held, change);
        
        //pressing C puts you into the attacking state
        if (down & CONTROL_DOWN) 
        {
            if (stamina > stmBrPct9)
            {
                state attacking;
            }
        }
        
        //Pressing E puts you into the defensive state
        if (down & CONTROL_UP) 
        {  
            if (stamina > stmBrPct9)state blocking;
        }
    }
      
    changed( integer vChg )
    {
        if (CHANGED_OWNER & vChg)
        {
            llResetScript();
        }
    }
}

//THIS STATE IS FOR ATTACKING MODE\\

state attacking
{
    state_entry()
    {
        stop_move();
        All_Listens();
         float tgtDist = llVecDist(llList2Vector(llGetObjectDetails(tgtKey, [OBJECT_POS]),0), llGetPos());
        if (tgtDist > 1.5)
        {    
            llMoveToTarget(llList2Vector(llGetObjectDetails(tgtKey, [OBJECT_POS]),0), 2);
        }
        still_attacking = TRUE;
        Setup_State_Function();
        llStartAnimation("Combo1");
        llStopAnimation("readystance");
        llStopAnimation("blocking");
    }
    
     timer()
    {  
        //llSay(435,"LsnAttk");
        //instead of charging stamina you are actually eating stamina in this state
        if (stamina > 0)
        {
            attacktimer += 1;
            stamina -= 2*damage;
            //tell the opponent you are hitting them
            if (attacktimer == 2)
            {
                llSay(FightChannel, "hit");
                attacktimer = 0;
            }
        }else
        {
            state fight;
        }
        
        Display_Function();
    }
    
    listen(integer chan, string name, key id, string msg)
    {
        Target_Listens(chan,msg,TRUE);
        Combat_Listens_Function(chan, msg, 0);
    }
    
 control( key name, integer held, integer change )
     {
        integer pressed = held & change;
        integer down = held & ~change;
        integer released = ~held & change;
        integer inactive = ~held & ~change;
        
        //Movement_Function(held, change);
        
        if (down & CONTROL_UP)
        {
            if (stamina - (30*damage) > 0)
            {
                stamina -= (30*damage);
                launchanim = "Launch_Up";
                llShout(FightChannel, "LUp");
                state launch_attack;
            }
        }
        
        if (released & CONTROL_DOWN) 
        {
            if (dead == FALSE)
            {
                state fight;
            }
        } 
    }
}

// THIS STATE IS FOR BLOCKING MODE \\
//it is almost the exact same as the attack state
state blocking
{
    state_entry()
    {
        stop_move();
        still_blocking = FALSE;
        All_Listens();
        Setup_State_Function();
        llStartAnimation("blocking");
        llStopAnimation("Combo1");
        llStopAnimation("readystance");
          
    }
    
     land_collision_start( vector pos )
    {
       llTriggerSound("groundhit",1);
    }
    
    collision_start( integer num )
    {
       llTriggerSound("groundhit",1);
    }
    
     timer()
    {  
        
        if (stamina < 10)state fight;
        
         /*if (stamina < stmbs)
        {
            stamina += 15;
        }*/
        
      Display_Function(); 
    }
    
    listen(integer chan, string name, key id, string msg)
    {
        Target_Listens(chan,msg,TRUE);   
        Combat_Listens_Function(chan, msg, 2);
        
    }
       
 control( key name, integer held, integer change )
     {
        integer pressed = held & change;
        integer down = held & ~change;
        integer released = ~held & change;
        integer inactive = ~held & ~change;
        
        Movement_Function(held, change);
        
        if (down & CONTROL_FWD) 
        {
            if (jumpsound)
            {
                llTriggerSound("walljumps",1);
                jumpsound = FALSE;
            }
            llStopAnimation("blocking");
            llStartAnimation("FlyUp");
            llStopMoveToTarget();
            UForce = 20;
            SForce = 0;
            FForce = 0;
            llSetForce(llGetMass()*<FForce,SForce,UForce>,TRUE);
        }
        
        if (released & CONTROL_FWD) 
        {
            stop_move();
            jumpsound = TRUE;
            llStartAnimation("blocking");
        }
        
         if (down & CONTROL_BACK) 
        {
            llStopAnimation("blocking");
            llStartAnimation("FlyDown");
            llStopMoveToTarget();
            UForce = -20;
            SForce = 0;
            FForce = 0;
            llSetForce(llGetMass()*<FForce,SForce,UForce>,TRUE);
        }
        
        if (released & CONTROL_BACK) 
        {
            stop_move();
            llStartAnimation("blocking");
        }
        
         if (down & CONTROL_DOWN)
        {
            if (stamina - (30*damage) > 0)
            {
                stamina -= (30*damage);
                launchanim = "Launch_Down";
                llSay(FightChannel, "LDown");
                state launch_attack;
            }
        }
        
        if (released & CONTROL_UP) 
        {
            if (dead == FALSE)
            {    
                still_blocking = TRUE;
                state fight;
            }
        } 
    }
}

state launch_attack
{
    state_entry()
    {
        stop_move();
        llStopAnimation("Combo1");
        All_Listens();
        Setup_State_Function();
        llSleep(.05);
        llStartAnimation("readystance");
        llStartAnimation(launchanim);
    }
    
     timer()
    {  
        Display_Function(); 
        if (launch_time < 6)
        {
            launch_time += 1;
        }else if (still_attacking)
        {
            launch_time = 0;
            state attacking;
        }else
        {
            launch_time = 0;
            state fight;
        }   
    }
    
     listen(integer chan, string name, key id, string msg)
    {
        Target_Listens(chan,msg,TRUE);    
    }
    
     control( key name, integer held, integer change )
     {
        integer pressed = held & change;
        integer down = held & ~change;
        integer released = ~held & change;
        integer inactive = ~held & ~change;
        
        if (down & CONTROL_DOWN)
        {
            still_attacking = TRUE;
        }
        
        if (released & CONTROL_DOWN) 
        {
            still_attacking = FALSE;
        } 
    }
}
    
state being_launched
{
    state_entry()
    {
        stop_move();
        llSetBuoyancy(0.3);
        llStopAnimation("falldown");
        llStopAnimation("Combo1");
        llStopAnimation("blocking");
        All_Listens();
        Setup_State_Function();
        launch_time = 0;
        
            if (stamina - (50*tgtdmg) > 0 && still_blocking == FALSE)
            {
                llStartAnimation(launchblockanim);
                llTriggerSound("meleemiss2",1);
                stamina -= (20*tgtdmg);
                llSleep(1.2);
                llTriggerSound("weakkick",1);
                llSetBuoyancy(0.0);
                launched = FALSE;
                state fight;
            }else
            {
                llStartAnimation(launchhitanim);
                llTriggerSound("strongkick",1);
                //stamina = 0;
                health -= (5*tgtdmg);
                llSleep(1.2);
                llTriggerSound("strongpunch",1);
                llStopMoveToTarget();
                if (llGetAgentInfo(llGetOwner()) & AGENT_IN_AIR)
                {
                    llApplyImpulse(<-50,0,(LForce/20)>,TRUE);
                }else{llApplyImpulse(<-1000,0,LForce>,TRUE);}
            }
    }
    
    land_collision( vector pos )
    {
        if (launched)
        {
            llTriggerSound("groundhit2",1);
            llStopAnimation(launchhitanim);
            launchhitanim = "Onground";
            llStartAnimation(launchhitanim);
            launched = FALSE;
        }
    }
    
     collision( integer num )
    {
        if (launched)
        {
            llTriggerSound("groundhit2",1);
            llStopAnimation(launchhitanim);
            launchhitanim = "Onground";
            llStartAnimation(launchhitanim);
            launched = FALSE;
        }
    }
    
     timer()
    {  
        Display_Function(); 
        
         /*if (stamina < stmbs)
        {
            stamina += llRound(stmbs/20);
        }*/
        
        if (launch_time == 5)
        {
            (launched = TRUE);
        }
                
        if (launch_time < 20)
        {
            launch_time += 1;
        }else 
        {
            stop_move();
            launch_time = 0;
            llStopAnimation(launchhitanim);
            Camera_Control(0);
            launched = FALSE;
            llSetBuoyancy(0.0);
            state fight;
        } 
    }
    
     listen(integer chan, string name, key id, string msg)
    {
        Target_Listens(chan,msg,TRUE);
        Combat_Listens_Function(chan, msg, 1);    
    }
    
     control( key name, integer held, integer change )
     {
        integer pressed = held & change;
        integer down = held & ~change;
        integer released = ~held & change;
        integer inactive = ~held & ~change;
        
        
        if (pressed & CONTROL_UP && launched)
        {
            if (stamina >= (stmbs/2) && launched);
            {
                llStopAnimation(launchhitanim);
                llStartAnimation("AirBrake");
                launch_time = 0;
                Camera_Control(0);
                launched = FALSE;
                llSetBuoyancy(0.0);
                llSleep(0.2);
                llTriggerSound("AirBreak",1);
                stop_move();
                stamina = -100;
                state fight;
            }
        }
    }
}

state finalize_fight
{
    state_entry()
    {
        stop_move();
        llStopMoveToTarget();
        llSetBuoyancy(0.0);
        Display_Function();
        
        if (dead)
        {
            exp += (10*tgtdmg);
            llShout(5347, "0"); //tell the target your health is 0
            llShout(6430, "END");
            llStopAnimation("Launch_Up_Hit");
            llStartAnimation("death");
            llShout(0,(string)llKey2Name(llGetOwner()) + "has been defeated!");
            llOwnerSay("You have earned " + (string)(10*tgtdmg) + " experience, you have " + (string)exp + " out of " + (string)expMax + ". You are level " + (string)rank + ".");
        }else
        {
            if (20*tgtdmg != 0)
            {
                llMessageLinked(LINK_SET,SET_POWER_CHANNEL, "0", "");    
                stop_move();
                exp += (20*tgtdmg);
                llOwnerSay("You have earned " + (string)(20*tgtdmg) + " experience, you have " + (string)exp + " out of " + (string)expMax + ". You are level " + (string)rank + ".");
            }
        }
        
        if (exp >= expMax)
        {
            rank+=1;
            pwrlvl += 0.1;
            exp -= expMax;
            llSay(0, llKey2Name(llGetOwner()) + " has leveled up!");
        }
        expMax = 1000 * rank;
        llSetLinkPrimitiveParamsFast(53, [ PRIM_DESC, (string)pwrlvl + "," + (string)rank + "," + (string)exp + "," + (string)expMax ]);
        if (dead)
        {
            llSleep(5.0);
            llResetScript();
        }else
        {
            if (tgtdmg != 0)
            {
                tgtID_1="";
                tgtID_2="";
                state searching;
             }
        }
    }
}