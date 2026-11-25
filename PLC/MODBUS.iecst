PROGRAM MODBUS 
VAR 
    xSW1 : BOOL AT %IX0.2; 
    xSW2 : BOOL AT %IX0.3; 
    xSW3 : BOOL AT %IX0.4; 
    xSW4 : BOOL AT %IX0.5; 
    xSW5 : BOOL AT %IX0.6; 
    xSW6 : BOOL AT %IX0.7; 
    xSW7 : BOOL AT %IX0.8; 
 
    xDirectionSwitch : BOOL AT %IX0.9; 
    iSetpointTemp : INT := 0; 
END_VAR 
 
iSetpointTemp := 0; 
 
IF xSW1 THEN iSetpointTemp := iSetpointTemp + 1; END_IF; 
IF xSW2 THEN iSetpointTemp := iSetpointTemp + 2; END_IF; 
IF xSW3 THEN iSetpointTemp := iSetpointTemp + 4; END_IF; 
IF xSW4 THEN iSetpointTemp := iSetpointTemp + 8; END_IF; 
IF xSW5 THEN iSetpointTemp := iSetpointTemp + 16; END_IF; 
IF xSW6 THEN iSetpointTemp := iSetpointTemp + 32; END_IF; 
IF xSW7 THEN iSetpointTemp := iSetpointTemp + 64; END_IF; 
 
GVL_MODBUS.g_iSetpoint := iSetpointTemp; 
 
IF xDirectionSwitch THEN 
    GVL_MODBUS.g_iDirection := 1; 
ELSE 
    GVL_MODBUS.g_iDirection := 0; 
END_IF; 
