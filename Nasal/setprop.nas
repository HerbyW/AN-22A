setprop("/instrumentation/altimeter/mmhg", getprop("/environment/config/interpolated/pressure-inhg") * 25.39999);

setprop("/instrumentation/altimeter/inhg100", getprop("/environment/config/interpolated/pressure-inhg") * 100);



#
# Air and Groundspeed selector for USVP-Instrument
#
setlistener("/tu154/switches/usvp-selector-trans", func 

  { if(getprop("/tu154/switches/usvp-selector-trans") > 0.5)
      {
        setprop("/tu154/instrumentation/usvp/air_ground_speed_kt", getprop("/velocities/groundspeed-kt"));
      }
      else
      {
        setprop("/tu154/instrumentation/usvp/air_ground_speed_kt", getprop("/velocities/airspeed-kt"));
      }
  
  }
  );