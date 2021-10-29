integer chan = -1900;

integer beltstrap = 2;
integer loops = 3;
integer pouch = 1;
integer flap = 0;
integer spine = 2;
integer main = 6;
integer straps = 5;

integer hammer = 5;
integer body = 4;
integer grip = 6;
integer gripframe = 0;
integer cylinder = 3;
integer trigger = 2;

integer BmetalG = 90;
integer FmetalG = 150;
key spectex = "7fb4c333-5d3f-d905-9db0-9ad17b8422c8";
 
default
{
    attach(key id)
    {
        llResetScript();
    }
    
    state_entry()
    {
        llListen(chan,"","","");
    }

    listen(integer chan, string name, key id, string msg)
    {
        if (llGetOwnerKey(id) == llGetOwner())
        {
            if (msg == "delete"){llOwnerSay("Holster Script deleted"); llRemoveInventory(llGetScriptName());}
            list texlist = llParseString2List(msg,[","],[]);
            string item = llList2String(texlist,0);
            string face = llList2String(texlist,1);
            key texture = llList2Key(texlist,2);
            string metal = llList2String(texlist,3);
            //llOwnerSay ("Applying " + (string)texture + " to " + (string)face + " on " + item);
            if (item == "holster")
            {
                if (face == "beltstrap") llSetLinkTexture(beltstrap, texture, ALL_SIDES);
                if (face == "main") llSetLinkTexture(1, texture, main);
                if (face == "spine") llSetLinkTexture(1, texture, spine);
                if (face == "straps") llSetLinkTexture(1, texture, straps);
                if (face == "pouch") llSetLinkTexture(1, texture, pouch);
                if (face == "flap") llSetLinkTexture(1, texture, flap);
                if (face == "loops") llSetLinkTexture(1, texture, loops);
            }else
            {
                integer BmetalE = 10;
                integer FmetalE = 50;
                if (metal == "special")
                {
                    //llOwnerSay(metal);
                    BmetalE = 80;
                    FmetalE = 80;
                } 
                if (face == "hammer"){ 
                    llSetLinkTexture(3, texture, hammer); 
                    llSetLinkPrimitiveParamsFast(3, [PRIM_SPECULAR, hammer, spectex, <1.0, 1.0, 0.0>, <0.0, 0.0, 0.0>, 0.0, <1,1,1>, BmetalG, BmetalE]);}
                if (face == "body"){
                    llSetLinkTexture(3, texture, body);
                    llSetLinkPrimitiveParamsFast(3, [PRIM_SPECULAR, body, spectex, <1.0, 1.0, 0.0>, <0.0, 0.0, 0.0>, 0.0, <1,1,1>, BmetalG, BmetalE]);}
                if (face == "grip") llSetLinkTexture(3, texture, grip);
                if (face == "trigger"){
                    llSetLinkTexture(3, texture, trigger);
                    llSetLinkPrimitiveParamsFast(3, [PRIM_SPECULAR, trigger, spectex, <1.0, 1.0, 0.0>, <0.0, 0.0, 0.0>, 0.0, <1,1,1>, BmetalG, BmetalE]);}
                if (face == "gripframe"){ 
                    llSetLinkTexture(3, texture, gripframe);
                    llSetLinkPrimitiveParamsFast(3, [PRIM_SPECULAR, gripframe, spectex, <1.0, 1.0, 0.0>, <0.0, 0.0, 0.0>, 0.0, <1,1,1>, FmetalG, FmetalE]);}
                if (face == "cylinder"){ 
                    llSetLinkTexture(3, texture, cylinder);
                    llSetLinkPrimitiveParamsFast(3, [PRIM_SPECULAR, cylinder, spectex, <1.0, 1.0, 0.0>, <0.0, 0.0, 0.0>, 0.0, <1,1,1>, BmetalG, BmetalE]);}
            }
        }
    }
}
