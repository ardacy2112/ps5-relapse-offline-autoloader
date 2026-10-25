#include "notification.h"
#include "browser.h"
#include <stdarg.h>
#include <stdio.h>
#include <string.h>

int sceKernelSendNotificationRequest(int device, notify_request_t *request,
                                     size_t size, int unused);

void notify(const char *fmt, ...) {
  notify_request_t req;
  va_list args;

  memset(&req, 0, sizeof(req));
  va_start(args, fmt);
  vsnprintf(req.message, sizeof(req.message), fmt, args);
  va_end(args);

  sceKernelSendNotificationRequest(0, &req, sizeof(req), 0);
  log_msg("[BROWSER] %s\n", req.message);
}
