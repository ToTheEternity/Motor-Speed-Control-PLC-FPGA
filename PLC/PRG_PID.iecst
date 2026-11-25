PROGRAM PRG_PID

VAR

     (* FALSE хэвээр эхэлнэ. Онлайн monitor-оор TRUE болгож PID-ийг идэвхжүүлнэ. *)
    xPID_Enable : BOOL :=TRUE;

    rSetpointRPM : REAL := 0.0;
    rActualRPM : REAL := 0.0;
    rError : REAL := 0.0;
    rPreviousError : REAL := 0.0;

    (* Эхний туршилтын коэффициентууд. Бодит мотор дээр тохируулна. *)
    rKp : REAL := 0.50;
    rKi : REAL := 0.05;
    rKd : REAL := 0.0;

    rP : REAL := 0.0;
    rI : REAL := 0.0;
    rD : REAL := 0.0;
    rIntegral : REAL := 0.0;

    rRawOutput : REAL := 0.0;
    rPWM : REAL := 0.0;
    rTs : REAL := 0.5;

    uiPWM_Command : UINT := 0;
    xFirstPIDSample : BOOL := TRUE;

END_VAR






xPID_Enable := TRUE;

(* RPM шинэ sample гарсан үед л PID тооцно *)
IF PRG_RPM.xSampleTick THEN

    IF xPID_Enable THEN
        (* Setpoint нь MW1-ээс уншигдана *)
        rSetpointRPM := INT_TO_REAL(GVL_MODBUS.g_iSetpoint);

        (* Direction=0 бол sensor 0, Direction=1 бол sensor 1-ийн RPM *)
        IF GVL_MODBUS.g_iDirection = 0 THEN
            rActualRPM := PRG_RPM.rRPM0;
        ELSE
            rActualRPM := PRG_RPM.rRPM1;
        END_IF;

        IF rSetpointRPM <= 0.0 THEN
            rPWM := 0.0;
            uiPWM_Command := 0;
            rIntegral := 0.0;
            rPreviousError := 0.0;
            rP := 0.0;
            rI := 0.0;
            rD := 0.0;
            xFirstPIDSample := TRUE;

        ELSE
            (* Алдаа: зорилтот хурд - бодит хурд *)
            rError := rSetpointRPM - rActualRPM;

            (* Proportional *)
            rP := rKp * rError;

            (* Derivative. Эхний sample дээр 0 *)
            IF xFirstPIDSample THEN
                rD := 0.0;
                xFirstPIDSample := FALSE;
            ELSE
                rD := rKd * (rError - rPreviousError) / rTs;
            END_IF;

            (* Өмнөх integral-тай түр гаралт бодож anti-windup шийдэх *)
            rI := rKi * rIntegral;
            rRawOutput := rP + rI + rD;

            (* Гаралт saturation-д хүрээгүй, эсвэл saturation-аас буцах
               чиглэлийн алдаа гарсан үед л integral-ийг нэмнэ *)
            IF ((rRawOutput < 255.0) AND (rRawOutput > 0.0)) OR
               ((rRawOutput >= 255.0) AND (rError < 0.0)) OR
               ((rRawOutput <= 0.0) AND (rError > 0.0)) THEN
                rIntegral := rIntegral + (rError * rTs);
            END_IF;

            (* Integral хуримтлалыг хязгаарлах *)
            IF rIntegral > 1000.0 THEN
                rIntegral := 1000.0;
            ELSIF rIntegral < -1000.0 THEN
                rIntegral := -1000.0;
            END_IF;

            (* PID-ийн нийлбэр гаралт *)
            rI := rKi * rIntegral;
            rRawOutput := rP + rI + rD;

            (* PWM команд 0..255 хүрээнд хязгаарлах *)
            IF rRawOutput > 255.0 THEN
                rPWM := 255.0;
            ELSIF rRawOutput < 0.0 THEN
                rPWM := 0.0;
            ELSE
                rPWM := rRawOutput;
            END_IF;

            uiPWM_Command := REAL_TO_UINT(rPWM);
            rPreviousError := rError;
        END_IF;

    ELSE
        (* PID disabled үед PWM=0 *)
        rPWM := 0.0;
        uiPWM_Command := 0;
        rIntegral := 0.0;
        rPreviousError := 0.0;
        rP := 0.0;
        rI := 0.0;
        rD := 0.0;
        xFirstPIDSample := TRUE;
    END_IF;
  (* PWM үр дүнг MW0-д бичнэ. FPGA зөвхөн энэ регистрийг уншина. *)
    GVL_MODBUS.g_iPWM := UINT_TO_INT(uiPWM_Command);
END_IF;
