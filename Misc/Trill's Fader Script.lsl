float min_time = 10.0; // minimum time between fades
float max_time = 40.0; // maximum time between fades;
float fade_time = 3.0; // how many seconds it takes to fade.

string side1name = "a"; // The name of the first side1
string side2name = "b"; // The name of the second stage

/////////////////////////////////////////
//////MAGIC WIZARD STUFF DOWN HERE!//////
//////          CAREFUL!!          //////
/////////////////////////////////////////
list primsA;
list primsB;
float alpha1 = 1.0;
float alpha2 = 1.0;
setSide1(float a)
{
    llSetLinkAlpha(llList2Integer(primsA,0),a,ALL_SIDES);
    llSetLinkAlpha(llList2Integer(primsA,1),1 - a,ALL_SIDES);
}
setSide2(float a)
{
    llSetLinkAlpha(llList2Integer(primsB,0),a,ALL_SIDES);
    llSetLinkAlpha(llList2Integer(primsB,1),1 - a,ALL_SIDES);
}

get_prims()
{
    integer i = llGetNumberOfPrims();
    string name;
    do
    {
        name = llGetLinkName(i);
        if(name == side1name)primsA += [i];
        else if(name == side2name)primsB += [i];
    }
    while(--i > 0);
}

default
{
    state_entry()
    {
        get_prims();
        alpha1 = 1.0;
        if(llFrand(1.0) >= 0.5)alpha1 = 0.0;
        
        alpha2 = 1.0;
        if(llFrand(1.0) >= 0.5)alpha2 = 0.0;
        
        setSide1(alpha1);
        setSide2(alpha2);
        llSetTimerEvent(min_time);
    }

    timer()
    {
        llResetTime();
        if(llFrand(1) >= 0.5)
        {
            float dif = 1;
            if(alpha1 > 0)dif = -1;
            integer working = TRUE;
            while(working)
            {
                alpha1 += (llGetAndResetTime() / fade_time) * dif;
                if(dif > 0 && alpha1 >= 1)
                {
                    working = FALSE;
                    alpha1 = 1;
                }
                else if(dif < 0 && alpha1 <= 0)
                {
                    working = FALSE;
                    alpha1 = 0;
                }
                setSide1(alpha1);
            }
        }
        else
        {
            float dif = 1;
            if(alpha2 > 0)dif = -1;
            integer working = TRUE;
            while(working)
            {
                alpha2 += (llGetAndResetTime() / fade_time) * dif;
                if(dif > 0 && alpha2 >= 1)
                {
                    working = FALSE;
                    alpha2 = 1;
                }
                else if(dif < 0 && alpha2 <= 0)
                {
                    working = FALSE;
                    alpha2 = 0;
                }
                setSide2(alpha2);
            }
        }
        llSetTimerEvent(min_time + llFrand(max_time - min_time));
    }
    
    changed(integer c)
    {
        if(c & CHANGED_LINK)
        {
            llResetScript();
        }
    }
}
