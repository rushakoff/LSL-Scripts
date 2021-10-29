integer typing;
integer mto = 0;
integer teamanim = FALSE;
Start()
{
    llLoopSound("TeamSkullSound",1);
    if (teamanim)
    {
        float offset = llFrand(1) + llFrand(1);
        llSleep(offset);
    }
    llStartAnimation("TeamSkullAnim");
    llSetTimerEvent(.2);
}

Stop()
{
    llStopAnimation("TeamSkullAnim");
    llStopSound();
    typing = FALSE;
    llSetTimerEvent(.2);
}
default
{
    attach(key id)
    {
        llResetScript();
    }
    state_entry()
    {
        llRequestPermissions(llGetOwner(), PERMISSION_TRIGGER_ANIMATION);
        llListen(-27411,"","","");
    }
    
    run_time_permissions(integer perm) 
    {
        if (PERMISSION_TRIGGER_ANIMATION) 
        {
            Stop();
            llSetTimerEvent(0.2); // start polling
        }
    }

    timer()
    {
        integer buf = llGetAgentInfo(llGetOwner());
        if (buf & AGENT_TYPING) 
        {
            if ((!teamanim) && (!typing))
            {
                typing = TRUE;
                llSay(-27411,"GO!");
                Start();
            }
        }else
        {
            if ((!teamanim) && (typing))
            {
                llSay(-27411,"STOP!");
                Stop();
            }
        }
    }
    
    listen(integer chan, string name, key id, string msg)
    {
        if (msg == "GO!")
        {
            mto++;
            if ((!teamanim)&& (!typing))
            {
                teamanim = TRUE;
                Start();
            }
            //llSay(0,"talker started = " + (string)mto);
        }else if (msg == "STOP!")
        {
            if (mto > 0)mto--;
            //llSay(0,"talker Stopped = " + (string)mto);
            if (mto == 0)
            {
                teamanim = FALSE;
                if(!typing)
                {
                    Stop();
                }
            }
        }
    }
}
