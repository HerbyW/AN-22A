## Learjet 35-A, stall and overspeed warning
## PH-JBO 20120130p
# modified by Herbert Wagner for TU-160-Blackjack 12/2015

var aoaStall = 16;
setprop("/instrumentation/alerts/aoaStall",16);
setprop("/instrumentation/alerts/stall",0);

var warning = func {
  
  ## get variables
  var aoa = getprop("/orientation/alpha-deg");
  var flaps = getprop("/controls/flight/flaps") * -6;
  var gear = getprop("/controls/gear/gear-down") * -2.5;
  var stalling = "false";
  var gearalt = getprop("/position/gear-agl-ft");
  var aoaStall = (16 + flaps + gear);
## compare and set warning
  if ((aoa!=nil) and (flaps!=nil))
    {
        if (aoa>aoaStall)
	{var stalling="true";}
     }
	if ((gearalt!=nil) and ((getprop("/gear/gear[0]/wow")!=1) or (getprop("/gear/gear[1]/wow")!=1) or (getprop("/gear/gear[2]/wow")!=1)))
	{
	setprop("/instrumentation/alerts/stall",stalling);
	setprop("/instrumentation/alerts/aoaStall",aoaStall);
	}
	else setprop("/instrumentation/alerts/stall",0);
	setprop("/instrumentation/alerts/aoaStall",aoaStall);
	settimer (warning,0.5);
}

warning();