#include <stdarg.h>
#include <stdio.h>
#include "log.h"

void log_msg(const char *fmt, ...) {
  va_list args;
  va_start(args, fmt);
  vprintf(fmt, args);
  va_end(args);
}
