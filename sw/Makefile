# TOOLCHAIN_PREFIX ?= riscv64-unknown-elf-
TOOLCHAIN_PREFIX ?= riscv64-zephyr-elf-
RESET_VECTOR ?= 0
FLASH_ADDR ?= 0x0

BUILD_DIR ?= build
include $(CURDIR)/common/common.mk

BOOTLOADER_SRC = $(wildcard $(CURDIR)/bootloader/*.S)

CFLAGS += -march=rv32im_zicsr -mabi=ilp32
LDFLAGS += -T$(EL2_LINKER_SCRIPT)


$(BUILD_DIR):
	mkdir -p $(BUILD_DIR)

bootloader: $(BUILD_DIR) $(BUILD_DIR)/bootloader.elf $(BUILD_DIR)/bootloader.vh

$(BUILD_DIR)/bootloader.elf: $(BOOTLOADER_SRC)
	$(GCC) -nostartfiles $(CFLAGS) $(LDFLAGS) -o$@ $^

$(BUILD_DIR)/%.elf: %.S
	$(GCC) -nostartfiles $(CFLAGS) $(LDFLAGS) -o$@ $<

$(BUILD_DIR)/%.vh: $(BUILD_DIR)/%.bin
	echo "Creating hex-rom for: $< at $@"
	# $(MAKEHEX) $< > $@

$(BUILD_DIR)/%.bin: $(BUILD_DIR)/%.elf
	echo "Creating binary for: $< at $@"
	$(OBJCOPY) -O binary $< $@

# %.ihex: %.elf
# 	$(TOOLCHAIN_PREFIX)objcopy -O ihex $< $@
# %.ub: %.bin
# 	mkimage \
# 	-A riscv \
# 	-C none \
# 	-T standalone \
# 	-a 0x0 \
# 	-e $(RESET_VECTOR) \
# 	-n '$@' \
# 	-d $< \
# 	$@
#
# %.ubvh: %.ub
# 	objcopy --change-addresses $(FLASH_ADDR) -I binary -O verilog $< $@

clean:
	rm -f *.elf *.bin *.vh
