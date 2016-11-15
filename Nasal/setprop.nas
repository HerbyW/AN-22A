#
#  Copyright (C) Herbert Wagner Dec2014-2016
#  see Read-Me.txt for all copyrights in the base folder of this aircraft
###################################################################################
setprop("/sim/signals/fdm-ready", 0);


var fdmready = maketimer(3, func {
  
  if (getprop ("/sim/time/elapsed-sec") > 15 )  
  setprop("/sim/signals/fdm-ready", 1); 
    
});

fdmready.start();


###################################################################################
#UVID-15 Control for Pressure in mmhg and inhg
# create listener

setprop("/instrumentation/altimeter/setting-hapa", getprop("/instrumentation/altimeter/setting-hpa"));

setlistener("/instrumentation/altimeter/setting-inhg", func(v)
{
  if(v.getValue())
  
    setprop("/instrumentation/altimeter/mmhg", getprop("/instrumentation/altimeter/setting-inhg") * 25.4);
    setprop("/instrumentation/altimeter/setting-inhgN", getprop("/instrumentation/altimeter/setting-inhg") + 0.005);
    setprop("/instrumentation/altimeter/setting-hapa", getprop("/instrumentation/altimeter/setting-inhg") * 33.8682715);
});

#####################################################################################################################

#UVPD Control
# create timer with 0.5 second interval
var timerDiff = maketimer(0.5, func

{ 
    setprop("/controls/pressurization/diffdruck", (1 / getprop("/environment/atmosphere/density-tropo-avg") - 1.58));    
  }
);

# start the timer (with 0.5 second inverval)
timerDiff.start();

######################################################################################################################

#
#Paratroopers
#
setlistener("/controls/paratroopers/jump-signal", func(v) {
  if(v.getValue()){
    interpolate("/controls/paratroopers/jump-signal-pos", 1, 0.25);    
  }else{
    interpolate("/controls/paratroopers/jump-signal-pos", 0, 0.25);
  }
});

######################################################################################################################

#
#Bradle Tank roll out and jump
#
setlistener("/controls/bradle/jump-signal", func(v) {
 if(v.getValue()){
    interpolate("/controls/bradle/jump-signal-pos", 1, 0.25);
    
  }else{
    interpolate("/controls/bradle/jump-signal-pos", 0, 0.25);
  }
});

#
#Bradle Tank loading 3 tanks
#
setlistener("/controls/bradle/load-signal", func(v) {
  if(v.getValue()){
    interpolate("/sim/weight[3]/weight-lb", 182550, 25);
  }else{
    interpolate("/sim/weight[3]/weight-lb", 0, 25);
  }
});

######################################################################################################################

#
# Air and Groundspeed selector for USVP-Instrument
#
setlistener("/controls/switches/usvp-selector-trans", func 

  { if(getprop("/controls/switches/usvp-selector-trans") > 0.5)
      {
        setprop("/instrumentation/usvp/air_ground_speed_kt", getprop("/velocities/groundspeed-kt"));
      }
      else
      {
        setprop("/instrumentation/usvp/air_ground_speed_kt", getprop("/instrumentation/airspeed-indicator/indicated-speed-kt"));
      }
  
  }
  );
 
#####################################################################################################################

#Lights
setprop("/controls/switches/headlight-mode", 1);

######################################################################################################################

#
#Fuel and Condition Control
#
setprop("/consumables/fuel/tank[0]/selected", 0);
setprop("/consumables/fuel/tank[1]/selected", 0);
setprop("/consumables/fuel/tank[2]/selected", 0);
setprop("/consumables/fuel/tank[3]/selected", 0);
setprop("/controls/switches/fuel", 0);

setlistener("/controls/switches/fuel", func 

  { if(getprop("/controls/switches/fuel") > 0.5)
      {
        setprop("/consumables/fuel/tank[0]/selected", 1);
        setprop("/consumables/fuel/tank[1]/selected", 1);
        setprop("/consumables/fuel/tank[2]/selected", 1);
        setprop("/consumables/fuel/tank[3]/selected", 1);
      }
      else
      {
        setprop("/consumables/fuel/tank[0]/selected", 0);
        setprop("/consumables/fuel/tank[1]/selected", 0);
        setprop("/consumables/fuel/tank[2]/selected", 0);
        setprop("/consumables/fuel/tank[3]/selected", 0);
	setprop("/controls/engines/engine[0]/condition", 0);
	setprop("/controls/engines/engine[1]/condition", 0);
	setprop("/controls/engines/engine[2]/condition", 0);
	setprop("/controls/engines/engine[3]/condition", 0);
      }
  
  }
  );
 
##########################################################
#      ALS Control by HerbyW 03/2015
##########################################################

setlistener("/controls/ALS/setting", func(v) {
  if(v.getValue()){
    interpolate("/controls/ALS/setting-pos", 1, 0.25);
  }else{
    interpolate("/controls/ALS/setting-pos", 0, 0.25);
  }
});


setlistener("/controls/ALS/setting", func

 { 
   if(getprop("/sim/rendering/rembrandt/enabled") == 1)
    {
      setprop("/sim/messages/copilot", "ALS is not working with Rembrandt");
    }
    else
    { 
      if(getprop("/controls/ALS/setting") == 1)
      {
      setprop("/sim/rendering/shaders/skydome", 1);
      setprop("/sim/rendering/als-secondary-lights/landing-light1-offset-deg", -12);
      setprop("/sim/rendering/als-secondary-lights/landing-light2-offset-deg", 12);
      setprop("/sim/rendering/als-secondary-lights/use-alt-landing-light", 1);
      setprop("/sim/rendering/als-secondary-lights/use-landing-light", 1);
      setprop("/sim/rendering/als-secondary-lights/use-searchlight", 1);
      }
      else
      {
      setprop("/sim/rendering/als-secondary-lights/use-alt-landing-light", 0);
      setprop("/sim/rendering/als-secondary-lights/use-landing-light", 0);
      setprop("/sim/rendering/als-secondary-lights/use-searchlight", 0);
      }
    }   

 }
);

#######################################################################################################

# SKAWK support

setlistener("/instrumentation/transponder/inputs/mode", func

{
  
  var mode_handle = getprop("/instrumentation/transponder/inputs/mode" );
  var mode = 1;

  if( mode_handle == 0 ) mode = 4;
  if( mode_handle == 2 ) mode = 5;
  if( mode_handle == 1 ) mode = 1;
  if( mode_handle == 3 ) mode = 3;

  setprop("/instrumentation/transponder/inputs/knob-mode", mode );
  
});

setprop("/instrumentation/transponder/serviceable", 0);
########################################################################################################

# Parking Chokes and Brake Control

setlistener("/controls/gear/brake-parking", func

{ if (getprop("/sim/replay/replay-state") == 0)

{
   if (getprop("/controls/gear/brake-parking") == 0)
    {
      if (getprop("/controls/chokes/activ") == 1)
        {
	  setprop("/sim/messages/copilot", "Parking Chokes are at the wheels! Parking Brake can not be lift");
          setprop("/controls/gear/brake-parking", 1);
        }
      else
        {
	  setprop("/sim/messages/copilot", "Parking Brake off, aircraft is moving!");
	  setprop("/controls/gear/brake-parking", 0);  
	}
     }
    else
     {
       if (getprop("/position/gear-agl-m") > 2)
        {
	 setprop("/sim/messages/copilot", "We are in the air, Brakes have no sense...");
	 setprop("/controls/gear/brake-parking", 0);
        }
       else
        {
	  setprop("/sim/messages/copilot", "Parking Brake on, check if chokes are needed!");
	}
     } 
}});  

setlistener("/controls/chokes/activ", func

{ if (getprop("/sim/replay/replay-state") == 0)
{
   if (getprop("/controls/chokes/activ") == 1)
   if (getprop("/controls/gear/brake-parking") == 0)
        {
	  setprop("/sim/messages/copilot", "Parking Brake off, Chokes can not be set!");
	  setprop("/controls/chokes/activ", 0);  
	}
    if (getprop("/controls/chokes/activ") == 1)
    if (getprop("/controls/gear/brake-parking") == 1)
        {
	  setprop("/sim/messages/copilot", "Parking Brake and Chokes are set, enjoy your day!");
	}
}});

########################################################################################################

# Landing Gears Control with help from: 707 Hangar of Constance

# prevent retraction of the landing gear when any of the wheels are compressed
setlistener("/controls/gear/gear-down", func
 {
 var down = props.globals.getNode("/controls/gear/gear-down").getBoolValue();
 var crashed = getprop("/sim/crashed") or 0;
 if (!down and (getprop("/gear/gear[0]/wow") or getprop("/gear/gear[1]/wow") or getprop("/gear/gear[6]/wow")))
  {
    if(!crashed){
  		props.globals.getNode("/controls/gear/gear-down").setBoolValue(1);
    }else{
  		props.globals.getNode("/controls/gear/gear-down").setBoolValue(0);
    }
  }
 });

var gearstate = 0;
setlistener("/gear/gear/position-norm", func
  { if (getprop("/gear/gear/position-norm") == 1)
    { gearstate = 0 ;}
    if (getprop("/gear/gear/position-norm") < 1)
    { gearstate = 1 ;}
    if (getprop("/gear/gear/position-norm") == 0)
    { gearstate = 0 ;}
    setprop("/gear/state", gearstate)
  }
);

setlistener("/position/gear-agl-m", func
  {
    if ((getprop("/gear/gear/position-norm") == 0) and (getprop("/position/gear-agl-m") < 100))
    {setprop("/gear/warning", 1);}
      else setprop("/gear/warning", 0)
  });


#############################################################################################################
#
# wind drift angle calculations, with help from: D-LEON
#
# wind direction:  environment/metar/base wind-dir-deg
# wind speed:      environment/metar/base wind-speed-kt
# heading:         orientation/heading-deg
# speed:           instrumentation/airspeed-indicator/indicated-speed-kt

#
#Calculate Ground Speed, Course & Wind Correction Angle
# create timer with 0.7 second interval
setprop("/autopilot/settings/heading-bug-deg", 0.001);

var TODEG = 180/math.pi;
var TORAD = math.pi/180;
var deg = func(rad){ return rad*TODEG; }
var rad = func(deg){ return deg*TORAD; }

var calc = maketimer(0.7, func

{ 
 
  var TWD 	= rad(getprop("/environment/wind-from-heading-deg"));
  var WS 	= getprop("/environment/wind-speed-kt");
  var TC 	= rad(getprop("/autopilot/settings/heading-bug-deg"));

  var TAS	= getprop("/instrumentation/airspeed-indicator/true-speed-kt");
  var MD 	= rad(getprop("/environment/magnetic-variation-deg"));  
  
  var x = WS * math.sin((TC-TWD));
  var y = TAS - (WS * math.cos((TC-TWD))); 
  
  DA = math.atan2(x,y);  
    
  if  
    (getprop("/instrumentation/airspeed-indicator/true-speed-kt") < 25 )
    { setprop("/instrumentation/drift",0 );}
  else
  { setprop("/instrumentation/drift",deg(DA)); }
  
}
);

# start the timer (with 0.7 second inverval)
calc.start();

#############################################################################################################
 var oilPressTimer = maketimer(15.0, func { 
var factor = 0.0051;

if (getprop("/controls/switches/fuel") > 0.5)
{
interpolate("/instrumentation/fuel_press/A0/press1", getprop("/engines/engine[0]/fuel-flow-gph")*factor + 0.1  , 5.0);
interpolate("/instrumentation/fuel_press/A0/press2", getprop("/engines/engine[0]/fuel-flow-gph")*factor + 0.1  , 5.0);
interpolate("/instrumentation/fuel_press/A1/press1", getprop("/engines/engine[1]/fuel-flow-gph")*factor + 0.1  , 5.0);
interpolate("/instrumentation/fuel_press/A1/press2", getprop("/engines/engine[1]/fuel-flow-gph")*factor + 0.1  , 5.0);
interpolate("/instrumentation/fuel_press/A2/press1", getprop("/engines/engine[2]/fuel-flow-gph")*factor + 0.1  , 5.0);
interpolate("/instrumentation/fuel_press/A2/press2", getprop("/engines/engine[2]/fuel-flow-gph")*factor + 0.1  , 5.0);
interpolate("/instrumentation/fuel_press/A3/press1", getprop("/engines/engine[3]/fuel-flow-gph")*factor + 0.1  , 5.0);
interpolate("/instrumentation/fuel_press/A3/press2", getprop("/engines/engine[3]/fuel-flow-gph")*factor + 0.1  , 5.0);
}
}
);

oilPressTimer.start(); 

#################################################################################################################


setprop("/sim/messages/copilot", "Hello");
setprop("/sim/messages/copilot", getprop("sim/multiplay/generic/string[0]"));
setprop("/sim/messages/copilot", "Have fun with the heavy cargo airplane Antonov-22A");
setprop("/sim/messages/copilot", "For Autostart hit the s key!");


####################################################################################################################

#
# Reverser and throttle control
#

setlistener("/controls/engines/engine[0]/throttle", func
 {
  if ((getprop("/controls/engines/engine[0]/throttle") < 0.015) and (getprop("/controls/autostart-time") == 1)) 
  setprop("/controls/engines/engine[0]/throttle", 0.015);
 }
);

setlistener("/controls/engines/engine[1]/throttle", func
 {
  if (getprop("/controls/engines/engine[1]/throttle") < 0.015 and getprop("/controls/autostart-time") == 1) 
  setprop("/controls/engines/engine[1]/throttle", 0.015);
 }
);

setlistener("/controls/engines/engine[2]/throttle", func
 {
  if (getprop("/controls/engines/engine[2]/throttle") < 0.015 and getprop("/controls/autostart-time") == 1) 
  setprop("/controls/engines/engine[2]/throttle", 0.015);
 }
);

setlistener("/controls/engines/engine[3]/throttle", func
 {
  if (getprop("/controls/engines/engine[3]/throttle") < 0.015 and getprop("/controls/autostart-time") == 1) 
  setprop("/controls/engines/engine[3]/throttle", 0.015);
 }
);


setlistener("/controls/engines/engine[0]/throttle", func
{   
 if ((getprop("/controls/reverser") == 0) and (getprop("/controls/autostart-time") == 1)) 
 {
  setprop("/controls/engines/engine[0]/throttle-v", getprop("/controls/engines/engine[0]/throttle"));
  setprop("/controls/engines/engine[1]/throttle-v", getprop("/controls/engines/engine[0]/throttle"));
  setprop("/controls/engines/engine[2]/throttle-v", getprop("/controls/engines/engine[0]/throttle"));
  setprop("/controls/engines/engine[3]/throttle-v", getprop("/controls/engines/engine[0]/throttle"));

  setprop("/controls/engines/engine[0]/throttle-r", 0);
  setprop("/controls/engines/engine[1]/throttle-r", 0);
  setprop("/controls/engines/engine[2]/throttle-r", 0);
  setprop("/controls/engines/engine[3]/throttle-r", 0);
 }
 if ((getprop("/controls/reverser") == 1) and (getprop("/controls/autostart-time") == 1))
 {  
  setprop("/controls/engines/engine[0]/throttle-r", getprop("/controls/engines/engine[0]/throttle"));
  setprop("/controls/engines/engine[1]/throttle-r", getprop("/controls/engines/engine[0]/throttle"));
  setprop("/controls/engines/engine[2]/throttle-r", getprop("/controls/engines/engine[0]/throttle"));
  setprop("/controls/engines/engine[3]/throttle-r", getprop("/controls/engines/engine[0]/throttle"));

  setprop("/controls/engines/engine[0]/throttle-v", 0);
  setprop("/controls/engines/engine[1]/throttle-v", 0);
  setprop("/controls/engines/engine[2]/throttle-v", 0);
  setprop("/controls/engines/engine[3]/throttle-v", 0);
 }
}
);

#############################################################################################################
# Lake of Constance Hangar :: M.Kraus
# April 2013
# This file is licenced under the terms of the GNU General Public Licence V2 or later
# ============================================
# The analog watch for the flightgear - rallye 
# ============================================
var sw = "/instrumentation/stopwatch/";


#============================== only stopwatch actions ================================
var sw_start_stop = func {
  var running = props.globals.getNode(sw~"running");

  if(!running.getBoolValue()){
    # start
    setprop(sw~"flight-time/start-time", getprop("/sim/time/elapsed-sec"));
    running.setBoolValue(1);
    sw_loop();
  }else{
    # stop
    var accu = getprop(sw~"flight-time/accu");
    accu += getprop("/sim/time/elapsed-sec") - getprop(sw~"flight-time/start-time");
    setprop(sw~"running",0);
    setprop(sw~"flight-time/accu", accu);
    sw_show(accu);
  }
}

var sw_reset = func {
  var running = props.globals.getNode(sw~"running");
  setprop(sw~"flight-time/accu", 0);

  if(running.getBoolValue()){
    setprop(sw~"flight-time/start-time", getprop("/sim/time/elapsed-sec"));
  }else{
    sw_show(0);
  }
}

var sw_loop = func {
  var running = props.globals.getNode(sw~"running");
  if(running.getBoolValue()){
    sw_show(getprop("/sim/time/elapsed-sec") - getprop(sw~"flight-time/start-time") + getprop(sw~"flight-time/accu"));
    settimer(sw_loop, 0.04);
  }
}

var sw_show = func(s) {
  var hours = s / 3600;
  var minutes = int(math.mod(s / 60, 60));
  var seconds = int(math.mod(s, 60));

  setprop(sw~"flight-time/total",s);
  setprop(sw~"flight-time/hours",hours);
  setprop(sw~"flight-time/minutes",minutes);
  setprop(sw~"flight-time/seconds",seconds);
}

#############################################################################################################
setprop("/autopilot/settings/target-altitude-ft", 0);

var adjustStep = func(value,amount,step=10){

if (math.abs(amount) >= step){
if (math.mod(value,step) != 0){
if (amount > 0){
value = math.ceil(value/step)*step;
}else{
value = math.floor(value/step)*step;
}
}else{
value += amount;
}
}else{
value += amount;
}
return value;
};


var adjustAlt = func(amount,step=100){

var value = getprop("/autopilot/settings/target-altitude-ft");
value = adjustStep(value,amount,100);
setprop("/autopilot/settings/target-altitude-ft",value);


};


var adjustPitch = func(amount,step=100){

var value = getprop("/autopilot/settings/vertical-speed-fpm");
value = adjustStep(value,amount,100);
setprop("/autopilot/settings/vertical-speed-fpm",value);


};

##############################################################################################################


setlistener("/sim/airport/closest-airport-id", func
{
  setprop("/controls/switches/metar",1);  
}
);

########################################################################################################

# Flaps Control with speed limits
# prevent demage of flaps due to speed

setlistener("/controls/flight/flaps", func
 { 
 if ((getprop("/controls/flight/flaps") > 0  ) and (getprop("/instrumentation/airspeed-indicator/indicated-speed-kt") > 250  ))
  {
    setprop("/controls/flight/flaps", 0);
    setprop("/sim/flaps/current-setting", 0);
    setprop("/sim/messages/copilot", "Do you want to destroy the flaps due to overspeed (max 250)????");    
  }
});
 
##############################################################################################################
# runway effect


setprop("/controls/gear/runway", 0);

setlistener("/gear/gear[3]/wow", func
{
  if (getprop("/gear/gear[3]/wow") == 0)
    interpolate("/controls/gear/runway", 0 , 0.1);
  else
  {
  if ( ( getprop("/gear/gear[3]/compression-norm") > 0.20 ) and ( getprop("/gear/gear[3]/rollspeed-ms") > 60)  and ( getprop("/velocities/speed-down-fps") > 2))
    interpolate("/controls/gear/runway", 1 , 0.3, 0 , 0.3);
  }
}
);

setlistener("/controls/gear/brake-parking", func
{
  if (getprop("/controls/gear/brake-parking") == 0)
    interpolate("/controls/gear/runway", 0 , 0.1);
  else
  {
  if ( ( getprop("/controls/gear/brake-parking") == 1 ) and ( getprop("/gear/gear[2]/rollspeed-ms") > 30) )
    interpolate("/controls/gear/runway", 1 , 1.2, 0 , 1.2);
  }
}
);

######################################################################################################################

# ice system

#  environment/temperature-degc
#  /sim/model/anti-ice-alpha
#  /sim/model/iceing                = float 19
#  /controls/switches/glass-heating
#  /controls/switches/rotor-heating

var ice = maketimer(15, func

  {
   if(getprop("/controls/switches/glass-heating") == 0) 
   {
     if(getprop("/environment/temperature-degc") > 1)
     {
     interpolate("/sim/model/anti-ice-alpha", 1, 14);
     }
    else
    {
      interpolate("/sim/model/anti-ice-alpha", getprop("/environment/temperature-degc") * 0.03846 + 0.90 , 14 );
      setprop("/sim/messages/copilot", "Window Ice Warning System has detected low temperature");
    }
   }
   else 
   {
     interpolate("/sim/model/anti-ice-alpha", 1, 14);
   }
   
   if(getprop("/controls/switches/rotor-heating") == 0) 
   { 
     if(getprop("/environment/temperature-degc") > 1)
     {
     interpolate("/sim/model/anti-ice-rotor", 1, 14);
     }
    else
    {
      interpolate("/sim/model/anti-ice-rotor", getprop("/environment/temperature-degc") * 0.03846 , 14 );
      setprop("/sim/messages/copilot", "Propeller Ice Warning System has detected low temperature");
    }
   }
   else 
   {
     interpolate("/sim/model/anti-ice-rotor", 1, 14);     
   }
   
  }); 
    
ice.start();

var glassice = maketimer(15, func {
  
  if(getprop("/controls/switches/glass-heating") == 0)
  
    interpolate("/sim/model/iceing", getprop("/sim/model/anti-ice-alpha"), 14);
  
  if(getprop("/controls/switches/glass-heating") == 1)
    
    interpolate("/sim/model/iceing", 1, 14);

});

glassice.start();

var rotorice = maketimer(15, func {
  
  if(getprop("/controls/switches/rotor-heating") == 0)
    
    interpolate("/controls/flight/spoilers", -1 * getprop("/sim/model/anti-ice-rotor"), 14);
  
  if(getprop("/controls/switches/rotor-heating") == 1)
    
    interpolate("/controls/flight/spoilers", 0, 14);
});

rotorice.start();
######################################################################################################################
# smoke shooter definition
#  /sim/model/smokeshooterspeed  == float n="17"

#<speed-mps>
#<value>80</value>
#<spread>15</spread>
#</speed-mps>

setlistener("/gear/gear[2]/wow", func
{
  if (getprop("/gear/gear[2]/wow") == 0)
    setprop("/sim/model/smokeshooterspeed", 80 );
  else
  {
   setprop("/sim/model/smokeshooterspeed", 35 + getprop("/gear/gear[2]/rollspeed-ms") * 0.5);
  }
}
);
