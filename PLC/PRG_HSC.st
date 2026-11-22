PROGRAM PRG_HSC 
VAR 
    xHSCInitDone : BOOL := FALSE; 
    xSyncPulse : BOOL := FALSE; 
 
    udiCount0 : UDINT := 0; 
    udiCount1 : UDINT := 0; 
 
    xValid0 : BOOL := FALSE; 
    xValid1 : BOOL := FALSE; 
    xError0 : BOOL := FALSE; 
    xError1 : BOOL := FALSE; 
END_VAR 

 
IF NOT xHSCInitDone THEN 
    xSyncPulse := TRUE; 
    xHSCInitDone := TRUE; 
ELSE 
    xSyncPulse := FALSE; 
END_IF; 
 
HSC_Forward( 
    Enable := TRUE, 
    Sync := xSyncPulse, 
    ACK_Modulo := FALSE 
); 
 
HSC_Reverse( 
    Enable := TRUE, 
    Sync := xSyncPulse, 
    ACK_Modulo := FALSE 
); 
 
xValid0 := HSC_Forward.Validity; 
xError0 := HSC_Forward.Error; 
IF xValid0 THEN 
    udiCount0 := DWORD_TO_UDINT(HSC_Forward.CurrentValue); 
END_IF; 
 
xValid1 := HSC_Reverse.Validity; 
xError1 := HSC_Reverse.Error; 
IF xValid1 THEN 
    udiCount1 := DWORD_TO_UDINT(HSC_Reverse.CurrentValue); 
END_IF; 
