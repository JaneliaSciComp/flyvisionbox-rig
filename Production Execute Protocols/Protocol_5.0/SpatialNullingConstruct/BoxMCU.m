classdef BoxMCU < handle
% BoxMCU
%
% For now BoxMCU contains minor shared utility functions used to interact
% with the MCU through its serial port interface.

% AL 9 July 2012. Support 16-bit frame periods for box.
%
% Current Video command/response (5 bytes): 
% send: 3,framePeriod,0,0,0. If framePeriod>0, then start video. If
% framePeriod==0, then stop video.
% receive: 3,framePeriod,frameCountHi,frameCountMed,frameCountLow.
%
% New Video command/response:
% send: 3,framePeriodLo,framePeriodHi,0,0. If framePeriod>0, then start
% video. If framePeriod==0 (both bytes are 0), then stop video.
% receive: 
% * In response to 3,framePeriodLo,0,0,0, receive
%   3,framePeriodLo,frameCountHi,frameCountMed,frameCountLow. This includes
%   video-stop.
% * In response to 3,framePeriodLo,framePeriodHi,0,0, receive
%   3,framePeriodLo,framePeriodHi,0,0.
%
% Magnus and I discussed adding a new/distinct MCU command for VIDEOSTOP,
% rather than overloading VIDEOSTART-with-frame-period-0 to mean VIDEOSTOP.
% This was always the more proper solution, but we decided to try the above
% ad-hoc solution for expediency. In retrospect, the more proper solution
% looks preferable due to complexities introduced by the ad-hoc solution in
% the MATLAB code. For now we went ahead with the ad-hoc fix, but if/when
% issues crop up again revisiting may make sense.

    methods (Static)
        
        function validateVideoCmd(cmd)
            assert(isequal(size(cmd),[1 5]),'Expected command to be a [1 5] row vector');
            assert(cmd(1)==3,'Command is not a video start/stop command.');            
        end
        
        function tf = videoCmdIsStop(cmd)
            fp = BoxMCU.decodeVideoFramePeriodCmd(cmd);
            tf = (fp==0);
        end
        
        function fp = decodeVideoFramePeriodCmd(cmd)
            BoxMCU.validateVideoCmd(cmd);            
            fpLo = cmd(2);
            fpHi = cmd(3);
            fp = BoxMCU.decodeVideoFramePeriod(fpLo,fpHi);
        end
            
        function fp = decodeVideoFramePeriod(fpLo,fpHi)
            fp = bitshift(fpHi,8)+fpLo;
        end
        
        function [fpLo fpHi] = encodeVideoFramePeriod(fp)
            validateattributes(fp,{'numeric'},{'scalar' 'integer' '>=' 0 '<=' 2^16-1});
            fpLo = mod(fp,256);
            fpHi = bitshift(fp,-8);
        end
        
    end
    
end