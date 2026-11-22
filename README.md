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












# DC Motor-ийн хурд ба эргэлтийн чиглэлийн удирдлагын систем (PLC + FPGA)

**Автомат удирдлагын системийн бие даалтын төсөл**  
МУИС — Мэдээллийн технологи, электроникийн сургууль

Энэхүү төсөл нь **Schneider Modicon TM218LDA60RDN PLC** болон **Sipeed Tang Nano 4K FPGA** хавтанг **RS-485 (Modbus RTU)** протокол ашиглан холбож, DC Motor-ийн эргэлтийн хурд болон чиглэлийг **Feedback Control (PID)** зарчмаар удирдах систем боловсруулахад чиглэнэ.

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

### 1. Setpoint тохируулах (PLC)

Сургалтын хавтан дээрх 7 ширхэг унтраалга (`%IX0.2`–`%IX0.8`)-аар моторын зорилтот хурд буюу **Setpoint (0–127 RPM)**-ийг тохируулна. Харин нэг унтраалга (`%IX0.9`)-аар моторын эргэлтийн чиглэлийг сонгоно.

### 2. Хурд хэмжих ба PID Control (PLC)

Моторын голд суурилуулсан **10-Slot Encoder Disk**-ийн эргэлтийг хоёр Optical Sensor (`XD-51`) ашиглан мэдэрнэ. Мэдрэгчүүдээс ирэх импульсийг `PC817` Optocoupler-оор дамжуулан PLC-ийн `I0`, `I1` өндөр хурдны тоолуур (HSC)-т оруулна.

PLC нь 500 ms тутамд импульсийн тоог ашиглан моторын бодит эргэлтийн хурд (RPM)-ийг тооцоолно. Дараа нь PID алгоритмаар Setpoint болон бодит RPM-ийн зөрүүг боловсруулж, PWM command-ийн утгыг (0–255) тооцоолон `%MW0` регистрт хадгална.

### 3. Харилцаа холбоо ба PWM Generation (FPGA)

`Tang Nano 4K` FPGA нь **Modbus RTU Master** горимд ажиллаж, `MAX13487E` RS-485 модулиар дамжуулан PLC-ийн `%MW0` регистрээс PWM command-ийн утгыг уншина.

FPGA нь хүлээн авсан утгад үндэслэн 21 kHz давтамжтай PWM дохио үүсгэнэ.

### 4. Motor Driver ба чиглэл удирдлага

FPGA-ийн 3.3 V PWM дохиог `2N2222` транзисторын хэлхээгээр инверс хийж, 12 V түвшний удирдлагын дохио болгон хувиргана. `IRF540` N-Channel MOSFET нь моторын хурдыг PWM дохиогоор удирдах бол хоёр ширхэг 24 V реле нь моторын эргэлтийн чиглэлийг өөрчилнө.

---

## 🛠️ Ашигласан техник хангамж ба программ хангамж

### Техник хангамж (Hardware)

| Төхөөрөмж | Загвар / Төрөл | Үүрэг |
|---|---|---|
| PLC | Schneider Electric Modicon `TM218LDA60RDN` | Setpoint унших, RPM тооцоолох, PID Control |
| FPGA | Sipeed `Tang Nano 4K` (Gowin GW1NSR-LV4C, 27 MHz Clock) | Modbus RTU Master, PWM Generation |
| RS-485 Transceiver | `MAX13487E` | RS-485 харилцаа холбоо, Auto-direction Control |
| DC Motor | `JGB37-520` (6 V, 200 RPM) | Удирдагдах хөдөлгүүр |
| MOSFET | `IRF540` N-Channel | Motor Speed Control |
| BJT | `2N2222` | PWM дохионы инверс болон түвшин хувиргалт |
| Relay | 2 ширхэг, 24 V | Моторын эргэлтийн чиглэл өөрчлөх |
| Flyback Diode | `1N5408` | Хэлхээг индукцийн хүчдэлээс хамгаалах |
| Optical Sensor | 2 ширхэг `XD-51` | Encoder Disk-ийн импульс мэдрэх |
| Optocoupler | `PC817` | Мэдрэгчийн дохиог PLC-ээс тусгаарлах |

### Программ хангамж (Software)

- **SoMachine:** PLC-ийн Structured Text программчлал, HSC болон Modbus Slave тохиргоо.
- **Gowin EDA:** FPGA-ийн VHDL логик дизайн болон Pinout тохиргоо.
- **Proteus:** Электрон хэлхээний симуляци.

---

## 📌 Tang Nano 4K Pinout (`pinout.cst`)

| Дохионы нэр | FPGA Pin | I/O Standard | Үүрэг |
|---|:---:|---|---|
| `clk_27m` | **45** | LVCMOS33 | Үндсэн 27 MHz Clock |
| `reset_n` | **15** | LVCMOS18 | Системийн Reset (Active Low) |
| `rs485_rxd` | **40** | LVCMOS33 | MAX13487E модулиас өгөгдөл хүлээн авах (RX) |
| `rs485_txd` | **44** | LVCMOS33 | MAX13487E модуль руу өгөгдөл дамжуулах (TX) |
| `pwm_out` | **41** | LVCMOS33 | 21 kHz давтамжтай PWM гаралт |
| `comm_error` | **43** | LVCMOS33 | Modbus харилцааны алдааг заах LED |

---

## 📂 Файлын бүтэц

```text
├── FPGA/
│   ├── top.vhd             # Үндсэн нэгтгэгч модуль (Top-level entity)
│   ├── modbus_master.vhd   # Modbus RTU Master төлөвийн машин (FSM)
│   ├── modbus_crc.vhd      # CRC-16 алдаа шалгах модуль
│   ├── uart_rx.vhd         # UART хүлээн авагч (9600 baud)
│   ├── uart_tx.vhd         # UART дамжуулагч (9600 baud)
│   ├── pwm_generator.vhd   # 21 kHz давтамжтай 8-bit PWM үүсгэгч
│   └── pinout.cst          # Tang Nano 4K Pin Assignment
│
├── PLC/
│   ├── GVL_MODBUS.st       # Modbus регистрийн хаягууд (%MW0, %MW1, %MW2)
│   ├── MODBUS.st           # Унтраалгуудаас Setpoint болон Direction унших
│   ├── PRG_HSC.st          # HSC тоолуурын удирдлага (I0, I1)
│   ├── PRG_RPM.st          # 500 ms тутамд RPM тооцоолох
│   └── PRG_PID.st          # Хурд тогтворжуулах PID Control
│
└── README.md               # Төслийн танилцуулга
```

---

**Холбоо барих:**  
munjigaaerdene@gmail.com
