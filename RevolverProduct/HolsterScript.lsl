integer gun;

default
{
    state_entry()
    {
        llListen(-1899,"","","");
    }

    listen(integer chan, string name, key id, string msg)
    {
        if (llGetOwnerKey(id) == llGetOwner())
        {
            if (msg == "holster")
            {
                integer i;
                while (i <= llGetNumberOfPrims())
                {
                    string name = llList2String(llGetLinkPrimitiveParams(i, [PRIM_NAME]),0);
                    if (name == "gun") llSetLinkAlpha(i, 1.0, ALL_SIDES);
                    i++;
                }
                
            }else if (msg == "unholster")
            {
                integer i;
                while (i <= llGetNumberOfPrims())
                {
                    string name = llList2String(llGetLinkPrimitiveParams(i, [PRIM_NAME]),0);
                    if (name == "gun") llSetLinkAlpha(i, 0.0, ALL_SIDES);
                    i++;
                }
            }
        }
    }
}
