# Compiler and tools
CC = arm-none-eabi-gcc
OBJCOPY = arm-none-eabi-objcopy
GDB = arm-none-eabi-gdb
SIZE = arm-none-eabi-size

# MCU and flags
MCU = cortex-m4
FPU_FLAGS = -mfloat-abi=hard -mfpu=fpv4-sp-d16
CFLAGS = -mcpu=$(MCU) -mthumb $(FPU_FLAGS) -O3 -Wall -g

# Linker script
LDSCRIPT = STM32F303C6TX_FLASH.ld

# Project files
TARGET = test
SRC = test.c syscalls.c

# Object files
OBJ = $(SRC:.c=.o)

# Build rules
all: $(TARGET).elf $(TARGET).hex

$(TARGET).elf: $(OBJ)
	$(CC) $(CFLAGS) -T$(LDSCRIPT) -o $@ $(OBJ)
	$(SIZE) $@

$(TARGET).hex: $(TARGET).elf
	$(OBJCOPY) -O ihex $(TARGET).elf $(TARGET).hex

# Compile source files
%.o: %.c
	$(CC) $(CFLAGS) -c $< -o $@

# Clean up the build files
clean:
	rm -f $(OBJ) $(TARGET).elf $(TARGET).hex

# Flash the program using OpenOCD
flash: $(TARGET).hex
	openocd -f interface/stlink.cfg -f target/stm32f3x.cfg -c "program $(TARGET).hex verify reset exit 0x08000000"

# Debug with GDB
debug: $(TARGET).elf
	$(GDB) $(TARGET).elf

.PHONY: all clean flash debug
