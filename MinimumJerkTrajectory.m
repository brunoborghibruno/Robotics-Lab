function [mj_position,mj_velocity]=MinimumJerkTrajectory(desiredTime, desiredDistance, timeVector)
if ~exist("timeVector"), sampleTime=0.01; timeSpan=[0:sampleTime:desiredTime]'; else, timeSpan=timeVector; end
 for counter=1:numel(timeSpan)
     if timeSpan(counter) <= desiredTime
         mj_position(counter,:)=desiredDistance*(10*((timeSpan(counter))/desiredTime)^3-15*((timeSpan(counter))/desiredTime)^4+6*((timeSpan(counter))/desiredTime)^5);  
         mj_velocity(counter,:)=(desiredDistance/desiredTime)*(30*((timeSpan(counter))/desiredTime)^2-60*((timeSpan(counter))/desiredTime)^3+30*((timeSpan(counter))/desiredTime)^4);
     else
         mj_position(counter,:)=desiredDistance;
         mj_velocity(counter,:)=0;
     end
 end
end