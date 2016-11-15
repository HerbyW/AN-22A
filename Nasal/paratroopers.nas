#
#  DE L'HAMAIDE Clément for Douglas DC-3 C47
#  modified by HerbyW 01/2015 and D-LEON
#
#  Copyright (C) Herbert Wagner Dec2014-2016
#  see Read-Me.txt for all copyrights in the base folder of this aircraft
###################################################################################

var jumper = aircraft.light.new("/controls/paratroopers/trigger", [0.5,0.5], "/controls/paratroopers/jump-signal");

var listener_id = setlistener("/sim/weight[2]/weight-lb" , func {setprop("/controls/paratroopers/paratroopers", getprop("/sim/weight[2]/weight-lb") / 120)},  0, 0);

setlistener("/controls/paratroopers/trigger/state", func(state){
  if(state.getValue()){
    if(getprop("/sim/model/door-positions/cargo/position-norm") < 0.75){
      jumper.switch(0);
      setprop("/controls/paratroopers/trigger/state", 0);
      setprop("/sim/messages/copilot", "Paratroopers door is closed ! Paratroopers can't jump");
    }else{
      var nb_para = getprop("/controls/paratroopers/paratroopers") - 2;
      setprop("/controls/paratroopers/paratroopers", nb_para);
      var weight = getprop("/sim/weight[2]/weight-lb") - 240;
      setprop("/sim/weight[2]/weight-lb", weight);
      if(getprop("/controls/paratroopers/paratroopers") > 0){
        setprop("/sim/messages/copilot", getprop("/controls/paratroopers/paratroopers")~" Paratroopers remaining");
      }else{
        jumper.switch(0);
        setprop("/sim/messages/copilot", "There are no Paratroopers inside");
      }
    }
  }
});

var bradleWeight = 60850;

var listener_id2 = setlistener("/sim/weight[3]/weight-lb" , func {setprop("/controls/bradle/bradle", getprop("/sim/weight[3]/weight-lb") / bradleWeight)}, 0, 0);

var bradleTimerRunning = 0;
var bradleTimer = func(){
bradleTimerRunning = 1;
var count = getprop("/controls/bradle/bradle");
var state = getprop("/controls/bradle/trigger/state");
if (count > 0){
var weight = getprop("/sim/weight[3]/weight-lb") - bradleWeight;

# roll
interpolate("/sim/weight[3]/weight-lb", weight, 9);
setprop("/sim/messages/copilot","Bradle Tank rolling");

# jump
settimer(func{
setprop("/controls/bradle/trigger/state",1);
setprop("/sim/messages/copilot","Bradle Tank out");
},9);

# prepair next
settimer(func{
setprop("/controls/bradle/trigger/state",0);
bradleTimer();
},10.1);

}else{
setprop("/controls/bradle/trigger/state",0);
setprop("/sim/messages/copilot", "There is no Bradle Tank inside");
bradleTimerRunning = 0;
}
};

setlistener("/controls/bradle/jump-signal", func(state){

if (state.getValue()){
 if (state.getValue() == 1){
bradleTimer();
}
}

});
