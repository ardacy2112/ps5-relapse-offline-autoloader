#include <stdio.h>
#include <unistd.h>
#include "browser.h"
#include "app_installer.h"

extern int sceNetCtlInit();
extern int sceUserServiceInitialize(void *);

int main(int argc, char *argv[]) {
  log_msg("[BROWSER] Starting Internet Browser installer\n");

  sceNetCtlInit();

  int prio = 256;
  sceUserServiceInitialize(&prio);

  install_app_if_needed();

  log_msg("[BROWSER] Done\n");
  return 0;
}
