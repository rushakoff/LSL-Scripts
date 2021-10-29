default
{
    state_entry()
    {
    }

    touch_start(integer id)
    {
        vector pos = llDetectedTouchPos(0);
        llSay(-554419,(string)pos);
    }
}
