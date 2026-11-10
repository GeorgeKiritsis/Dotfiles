HIDAPI := $(shell brew --prefix hidapi)

bin/logi_battery: logi_battery.c | bin
	clang -std=c99 -O2 $< -o $@ -I$(HIDAPI)/include/hidapi -L$(HIDAPI)/lib -lhidapi

bin:
	mkdir bin
