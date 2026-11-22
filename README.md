# Closed-Loop DC Motor Speed & Direction Control System (PLC + FPGA)

Coursework Project for **Automatic Control Systems**  
*Department of Electronics and Communication Engineering, School of Information Technology and Electronics, National University of Mongolia (NUM).*

This project implements a closed-loop PID speed and direction control system for a DC gear motor by interfacing a **Schneider Modicon TM218LDA60RDN** PLC with a **Sipeed Tang Nano 4K** FPGA via **RS-485 (Modbus RTU)**.

---

## ⚙️ System Architecture & Working Principle

```text
[7x Switches (Setpoint)] ──┐
                           ▼
[1x Switch (Direction)] ─► [Schneider TM218 PLC] ──(Modbus RTU / RS-485)──► [Tang Nano 4K FPGA]
                                   ▲                                               │
                                   │ (HSC I0 / I1)                                 │ (21 kHz PWM)
                                   │                                               ▼
                         [2x Opto-Sensors + PC817] ◄── [10-Slot Encoder Disk] ◄── [Motor Driver (2N2222 + IRF540 + 2x Relays)]
```

1. **User Input (PLC):** Seven digital switches (`%IX0.2`–`%IX0.8`) set the target speed setpoint (`0..127 RPM`), while one switch (`%IX0.9`) selects the motor rotation direction.
2. **Speed Measurement & PID Control (PLC):** Optical slot sensors detect pulses from a slotted encoder disk mounted on the motor shaft. Signals are isolated via `PC817` optocouplers and fed into the PLC's High-Speed Counters (`I0` and `I1`). Every `500 ms`, the PLC calculates the actual RPM, runs a PID algorithm with anti-windup, and updates the 8-bit PWM command (`0..255`) in holding register `%MW0`.
3. **Modbus RTU & PWM Generation (FPGA):** Acting as a Modbus RTU Master over `MAX13487E` RS-485 (`9600 bps, 8-N-1`), the `Tang Nano 4K` FPGA polls `%MW0` from the PLC and generates a `21 kHz` PWM signal.
4. **Power Driver Stage:** Since the FPGA outputs `3.3V` logic, a `2N2222` BJT inverts and shifts the PWM signal to `12V` to drive an `IRF540` N-channel MOSFET. Two `24V` relays with `1N5408` flyback diodes control the polarity across the motor to reverse direction.

---

## 🛠️ Hardware & Software Stack

### Hardware
* **PLC:** Schneider Electric Modicon `TM218LDA60RDN` (Modbus RTU Slave, ID = 1)
* **FPGA:** Sipeed `Tang Nano 4K` (Gowin GW1NSR-LV4C, 27 MHz System Clock)
* **RS-485 Transceiver:** `MAX13487E` Module (Auto-Direction Control)
* **Motor:** `JGB37-520` DC Gear Motor (6V, 200 RPM)
* **Driver & Protection:** `IRF540` MOSFET, `2N2222` NPN Transistor, 2x `24V` Relays, `1N5408` Flyback Diodes
* **Feedback Sensors:** 2x Optical Slot Sensors (`XD-51`) + `PC817` Optocouplers

### Software
* **SoMachine:** PLC programming in Structured Text (`.st`), HSC & Modbus configuration
* **Gowin EDA:** FPGA RTL design in VHDL (`.vhd`) and physical pin constraints (`.cst`)
* **Proteus:** Circuit design and simulation

---

## 📌 Tang Nano 4K Pinout (`.cst`)

| Signal Name | FPGA Pin | I/O Standard | Description |
| :--- | :---: | :---: | :--- |
| `clk_27m` | **45** | LVCMOS33 | 27 MHz on-board crystal clock |
| `reset_n` | **15** | LVCMOS18 | Active-low system reset |
| `rs485_rxd` | **40** | LVCMOS33 | UART RX from MAX13487E |
| `rs485_txd` | **44** | LVCMOS33 | UART TX to MAX13487E |
| `pwm_out` | **41** | LVCMOS33 | 21 kHz PWM output to gate driver |
| `comm_error`| **43** | LVCMOS33 | Modbus communication error indicator |

---

## 📂 Repository Structure

```text
├── FPGA/
│   ├── top.vhd             # Top-level entity connecting UART, Modbus Master, and PWM
│   ├── modbus_master.vhd   # Modbus RTU Master finite state machine (FSM)
│   ├── modbus_crc.vhd      # CRC-16 checksum generator/checker
│   ├── uart_rx.vhd         # UART receiver (9600 baud)
│   ├── uart_tx.vhd         # UART transmitter (9600 baud)
│   ├── pwm_generator.vhd   # 21 kHz, 8-bit resolution PWM generator
│   └── pinout.cst          # Tang Nano 4K pin assignments
│
├── PLC/
│   ├── GVL_MODBUS.st       # Global variables mapped to Modbus registers (%MW0..%MW2)
│   ├── MODBUS.st           # Reads 7 setpoint switches and direction switch
│   ├── PRG_HSC.st          # High-Speed Counter initialization and reading (I0, I1)
│   ├── PRG_RPM.st          # Calculates motor RPM every 500 ms
│   └── PRG_PID.st          # Closed-loop PID controller with anti-windup
│
└── README.md               # Project documentation
```

---

e-mail:
munjigaaerdene@gmail.com







--------------------------------------------------------------------------












# Closed-Loop DC Motor Speed & Direction Control System (PLC + FPGA)

Автомат удирдлагын системийн бие даалтын төсөл (МУИС — Мэдээллийн технологи, Электроникийн сургууль).

Энэхүү систем нь **Schneider Modicon TM218LDA60RDN** PLC болон **Sipeed Tang Nano 4K** FPGA хавтанг **RS-485 (Modbus RTU)** протоколоор холбож, тогтмол гүйдлийн хөдөлгүүрийн (DC Motor) эргэлтийн хурд болон чиглэлийг битүү гогцооны (Closed-Loop PID) зарчмаар тогтворжуулан удирдах зориулалттай.

---

## ⚙️ Системийн ажиллах зарчим (System Architecture)

```text
[7x Switches (Setpoint)] ──┐
                           ▼
[1x Switch (Direction)] ─► [Schneider TM218 PLC] ──(Modbus RTU / RS-485)──► [Tang Nano 4K FPGA]
                                   ▲                                               │
                                   │ (HSC I0 / I1)                                 │ (21 kHz PWM)
                                   │                                               ▼
                         [2x Opto-Sensors + PC817] ◄── [10-Slot Encoder Disk] ◄── [Motor Driver (2N2222 + IRF540 + 2x Relays)]
```

1. **Удирдлагын өгөгдөл (PLC):** Сургалтын хавтангийн 7 ширхэг унтраалгаар (`%IX0.2`–`%IX0.8`) зорилтот хурд буюу Setpoint (`0..127 RPM`), 1 унтраалгаар (`%IX0.9`) эргэлтийн чиглэлийг өгнө.
2. **Хурд хэмжилт ба PID (PLC):** Моторын голд суурилуулсан нүхтэй диск болон 2 оптик мэдрэгчээс ирэх импульсийг `PC817` optocoupler-аар тусгаарлан PLC-ийн `I0`, `I1` өндөр хурдны тоолуурт (HSC) өгнө. PLC нь `500 ms` тутамд бодит RPM-ийг тооцоолж, PID алгоритмаар PWM командыг (`0..255`) боловсруулан `%MW0` регистрт хадгална.
3. **Харилцаа холбоо ба PWM (FPGA):** `Tang Nano 4K` FPGA нь Modbus RTU Master горимоор `MAX13487E` RS-485 модулиар дамжуулан PLC-ийн `%MW0` регистрийн утгыг уншиж, `21 kHz` давтамжтай PWM дохио үүсгэнэ.
4. **Хүчний драйвер:** FPGA-ийн `3.3V` PWM дохиог `2N2222` транзистороор инверс хийж `12V` болгон өсгөж, `IRF540` MOSFET-ээр моторын хурдыг, 2 ширхэг `24V` релегээр эргэлтийн чиглэлийг удирдана.

---

## 🛠️ Ашигласан техник ба Програм хангамж

### Техник хангамж (Hardware)
* **PLC:** Schneider Electric Modicon `TM218LDA60RDN`
* **FPGA:** Sipeed `Tang Nano 4K` (Gowin GW1NSR-LV4C, 27 MHz Clock)
* **RS-485 Transceiver:** `MAX13487E` (Auto-direction control, 9600 bps, 8-N-1)
* **Хөдөлгүүр:** `JGB37-520` DC Gear Motor (6V, 200 RPM)
* **Драйвер ба Хамгаалалт:** `IRF540` N-Channel MOSFET, `2N2222` BJT, 2x `24V` Relay, `1N5408` Flyback Diodes
* **Мэдрэгч:** 2x Optical Slot Sensor (`XD-51`) + `PC817` Optocoupler

### Програм хангамж (Software)
* **SoMachine:** PLC програмчлал (Structured Text), HSC болон Modbus Slave тохиргоо
* **Gowin EDA:** FPGA логик дизайн (VHDL) болон Pinout тохиргоо
* **Proteus:** Электрон хэлхээний симуляци

---

## 📌 Tang Nano 4K Pinout (`.cst`)

| Дохионы нэр | FPGA Pin | I/O Төрөл | Үүрэг |
| :--- | :---: | :---: | :--- |
| `clk_27m` | **45** | LVCMOS33 | Үндсэн 27 MHz тактын давтамж |
| `reset_n` | **15** | LVCMOS18 | Системийг дахин эхлүүлэх (Active Low) |
| `rs485_rxd` | **40** | LVCMOS33 | MAX13487E модулиас өгөгдөл хүлээн авах (RX) |
| `rs485_txd` | **44** | LVCMOS33 | MAX13487E модуль руу хүсэлт илгээх (TX) |
| `pwm_out` | **41** | LVCMOS33 | 21 kHz давтамжтай PWM гаралт |
| `comm_error`| **43** | LVCMOS33 | Modbus холболтын алдаа заагч LED |

---

## 📂 Файлын бүтэц

```text
├── FPGA/
│   ├── top.vhd             # Үндсэн нэгтгэгч модуль (Top-level entity)
│   ├── modbus_master.vhd   # Modbus RTU Master төлөвийн машин (FSM)
│   ├── modbus_crc.vhd      # CRC-16 алдаа шалгах модуль
│   ├── uart_rx.vhd         # UART хүлээн авагч (9600 baud)
│   ├── uart_tx.vhd         # UART дамжуулагч (9600 baud)
│   ├── pwm_generator.vhd   # 21 kHz давтамжтай 8-бит PWM үүсгэгч
│   └── pinout.cst          # Tang Nano 4K хөлний оноолт
│
├── PLC/
│   ├── GVL_MODBUS.st       # Modbus санах ойн хаягууд (%MW0, %MW1, %MW2)
│   ├── MODBUS.st           # Унтраалгуудаас Setpoint болон чиглэл унших
│   ├── PRG_HSC.st          # Өндөр хурдны тоолуур (I0, I1)
│   ├── PRG_RPM.st          # 500 ms тутамд эргэлтийн хурд (RPM) тооцоолох
│   └── PRG_PID.st          # Хурд тогтворжуулах PID удирдлага
│
└── README.md               # Төслийн танилцуулга
```

---

e-mail:
munjigaaerdene@gmail.com
