CC     := /opt/ps5-payload-sdk/bin/prospero-clang
STRIP  := /opt/ps5-payload-sdk/bin/prospero-strip
SDK    := /opt/ps5-payload-sdk
TARGET := $(SDK)/target
INCLUDES := -Iinclude -I$(TARGET)/include
LIBS := -L$(TARGET)/lib -lpthread \
        -lSceNetCtl -lSceUserService -lSceSystemService \
        -lSceAppInstUtil -lSceHttp2 -lSceSsl -lSceNet -lSceIpmi

DOTNET   := dotnet
STAGING  := /tmp/ps5-browser-pkg-staging
CACHE    := $(STAGING)/PackageFileCache
STAGE_SC := $(CACHE)/sce_sys

SRCS := src/main.c src/log.c src/notification.c src/app_installer.c
ASSETS := assets/param.json assets/icon0.png
ELF  := build/relapse.elf
CFLAGS := -Os -Wall -ffunction-sections -fdata-sections $(INCLUDES)
LDFLAGS := -Wl,--gc-sections

.PHONY: all elf pkg clean

all: elf pkg

elf: $(ELF)

$(ELF): $(SRCS) $(ASSETS)
	mkdir -p build
	$(CC) $(CFLAGS) $(LDFLAGS) -o $(ELF) $(SRCS) $(LIBS)
	$(STRIP) $(ELF)

pkg:
	rm -rf $(STAGING)
	mkdir -p $(STAGE_SC)
	cp assets/param.json $(STAGE_SC)/param.json
	cp assets/icon0.png $(STAGE_SC)/icon0.png
	touch $(CACHE)/eboot.bin
	$(DOTNET) run --project tools/pkg-builder -c Release -- $(CACHE) build
	rm -rf $(STAGING)

clean:
	rm -rf build
