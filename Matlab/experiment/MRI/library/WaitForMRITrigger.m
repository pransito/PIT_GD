function Result = WaitForMRITrigger(MRITriggerCode, NumberOfTriggers, Display)

if(nargin < 3)
    Display = [];
end

Result                = nan(1, NumberOfTriggers);
CountTriggerInput     = 0;
TrigerCodeConverted   = KbName(MRITriggerCode);

while (CountTriggerInput < NumberOfTriggers)
    [touch, secs, keyCode] = KbCheck;
    if ((touch) && sum((keyCode(TrigerCodeConverted))))
        CountTriggerInput = CountTriggerInput + 1;
        
        if ((~isempty(Display)) && (CountTriggerInput == 1))
            drawfixationcross(Display.wd, 2, Display.fixationdotsize,0);
            Screen('Flip',Display.wd); 

            disp('First Trigger Received!');
        end
            
        Result(CountTriggerInput) = secs;
        
        while ((touch) && sum(keyCode(TrigerCodeConverted)))
            [touch, secs, keyCode] = KbCheck;
        end
    end
end