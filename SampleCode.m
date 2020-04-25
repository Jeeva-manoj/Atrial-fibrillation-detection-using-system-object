a=arduino;
afib=atrfib;
scope = dsp.TimeScope('SampleRate',250);
while(true)
    s=readVoltage(a,'A0');
    s=int16(s);
    scope(s);
    y=afib.step(s);
    end


