% EventData_timestep

classdef (ConstructOnLoad) EventData_timestep < event.EventData
   properties
      TimeCurrent
   end

   methods
      function data = EventData_timestep(x)
         data.TimeCurrent = x;
      end
   end
end
