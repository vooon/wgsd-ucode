// base32 module for ucode

#include "ucode/module.h"

// inline original library
#include "base32.c"

static uc_value_t* uc_b32enc(uc_vm_t *vm, size_t nargs){
	uc_value_t *str = uc_fn_arg(0);
	uc_value_t *ret = NULL;
	const uint8_t *src, *buf;
	size_t len;
	int reslen;

	if (ucv_type(str) != UC_STRING)
		return NULL;

	src = uc_string_get(str);
	len = uc_string_length(str);

	// encoded string should be smaller
	buf = xcalloc(1, len);

	reslen = base32_encode(src, len, buf, len);
	if (reslen < 0) {
		free(buf);
		return NULL;
	}

	ret = ucv_string_new_length(buf, reslen);
	free(buf);

	return ret;
}

static const uc_function_list_t global_fns[] = {
	{"b32enc", uc_b32enc},
};

void uc_module_init(uc_vm_t *vm, uc_value_t *scope)
{
	uc_function_list_register(scope, global_fns);
}
