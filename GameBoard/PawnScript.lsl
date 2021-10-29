integer moving = FALSE;
default
{
    state_entry()
    {
        llListen(-554419,"","","");
    }
    
    touch_start(integer id)
    {
        if (moving)
        {
            llSetLinkPrimitiveParams(LINK_SET, [PRIM_GLOW, ALL_SIDES, 0.0]);
            string name = llGetObjectName();
            moving = FALSE;
            llSay(0, "/me has stopped.");
        }else
        {
            llSetLinkPrimitiveParams(LINK_SET, [PRIM_GLOW, ALL_SIDES, 0.1]);
            string name = llGetObjectName();
            moving = TRUE;
            llSay(0, "/me is moving.");
        }
    }
    
    listen(integer chan, string name, key id, string msg)
    {
        if (moving)
        {
            vector pos = (vector)msg;
            vector hgt = llGetScale();
            pos.z += (hgt.z/2);
            llSetPos(pos);
        }
    }

}
