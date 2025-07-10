// base32 module for ucode
// Quick and dirty, but i do not want to reimplement the wheel on ucode.

#include <inttypes.h>

#include "ucode/module.h"

// inline original library
#include "base32.c"

static uc_value_t* uc_b32enc(uc_vm_t* vm, size_t nargs) {
  uc_value_t* str = uc_fn_arg(0);
  uc_value_t* ret = NULL;
  const uint8_t *src, *buf;
  uint8_t stack_buf[128] = {0};
  size_t len, buflen;
  int reslen;

  if (ucv_type(str) != UC_STRING) return NULL;

  src = ucv_string_get(str);
  len = ucv_string_length(str);

  // base32 takes 160% more data, but easier to reserve 200%
  if (len * 2 < sizeof(stack_buf)) {
    buflen = sizeof(stack_buf);
    buf = stack_buf;
  } else {
    buflen = len * 2;
    buf = xcalloc(1, buflen);
  }

  reslen = base32_encode(src, len, buf, buflen);
  if (reslen < 0) {
    if (buf != stack_buf) free(buf);
    return NULL;
  }

  ret = ucv_string_new_length(buf, reslen);
  if (buf != stack_buf) free(buf);

  return ret;
}

static uc_value_t* uc_b32dec(uc_vm_t* vm, size_t nargs) {
  uc_value_t* str = uc_fn_arg(0);
  uc_value_t* ret = NULL;
  const uint8_t *src, *buf;
  uint8_t stack_buf[128] = {0};
  size_t len, buflen;
  int reslen;

  if (ucv_type(str) != UC_STRING) return NULL;

  src = ucv_string_get(str);
  len = ucv_string_length(str);

  // base32 decoded data shorter than encoded
  if (len < sizeof(stack_buf)) {
    buflen = sizeof(stack_buf);
    buf = stack_buf;
  } else {
    buflen = len;
    buf = xcalloc(1, buflen);
  }

  reslen = base32_decode(src, buf, buflen);
  if (reslen < 0) {
    if (buf != stack_buf) free(buf);
    return NULL;
  }

  ret = ucv_string_new_length(buf, reslen);
  if (buf != stack_buf) free(buf);

  return ret;
}

static const uc_function_list_t global_fns[] = {
    {"b32enc", uc_b32enc},
    {"b32dec", uc_b32dec},
};

void uc_module_init(uc_vm_t* vm, uc_value_t* scope) {
  uc_function_list_register(scope, global_fns);
}
