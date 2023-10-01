#include "tint.h"

napi_value init(napi_env env, napi_value exports) {
	napi_status status;

	napi_property_descriptor descriptors[] = {
	    {"setWindowLayout", 0, setWindowLayout, 0, 0, 0, napi_default, 0},
	    {"setWindowAnimationBehavior", 0, setWindowAnimationBehavior, 0, 0, 0, napi_default, 0}};

	status = napi_define_properties(env, exports, 2, descriptors);
	if (status != napi_ok) {
		napi_throw_error(env, NULL, "failed to define module properties");
		return NULL;
	}

	return exports;
}

NAPI_MODULE(NativeExtension, init)