PROGRAM PRG_RPM 
VAR 
    tmSample : TON; 
    xSampleTick : BOOL := FALSE; 
 
    udiPPR0 : UDINT := 10; 
    udiPPR1 : UDINT := 10; 
 
    udiCount0 : UDINT := 0; 
    udiCount1 : UDINT := 0; 
    udiPrev0 : UDINT := 0; 
    udiPrev1 : UDINT := 0; 
    udiDelta0 : UDINT := 0; 
    udiDelta1 : UDINT := 0; 
 
    rRPM0 : REAL := 0.0; 
    rRPM1 : REAL := 0.0; 
END_VAR 
 
tmSample( 
    IN := NOT tmSample.Q, 
    PT := T#500ms 
); 
 
xSampleTick := tmSample.Q; 
 
IF xSampleTick THEN 
    udiCount0 := PRG_HSC.udiCount0; 
    udiCount1 := PRG_HSC.udiCount1; 
 
    IF udiCount0 >= udiPrev0 THEN 
        udiDelta0 := udiCount0 - udiPrev0; 
    ELSE 
        udiDelta0 := 0; 
    END_IF; 
 
    IF udiCount1 >= udiPrev1 THEN 
        udiDelta1 := udiCount1 - udiPrev1; 
    ELSE 
        udiDelta1 := 0; 
    END_IF; 
 
    udiPrev0 := udiCount0; 
    udiPrev1 := udiCount1; 
 
    IF udiPPR0 > 0 THEN 
        rRPM0 := UDINT_TO_REAL(udiDelta0) * 120.0 / UDINT_TO_REAL(udiPPR0); 
    ELSE 
        rRPM0 := 0.0; 
    END_IF; 
 
    IF udiPPR1 > 0 THEN 
        rRPM1 := UDINT_TO_REAL(udiDelta1) * 120.0 / UDINT_TO_REAL(udiPPR1); 
    ELSE 
        rRPM1 := 0.0; 
    END_IF; 
END_IF; 
