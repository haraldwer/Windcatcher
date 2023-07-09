#include "register_types.h"

#include "core/object/class_db.h"
#include "example.h"

void initialize_windcatcher_module(ModuleInitializationLevel p_level)
{
	if (p_level != MODULE_INITIALIZATION_LEVEL_SCENE)
		return;
	ClassDB::register_class<Example>();
}

void uninitialize_windcatcher_module(ModuleInitializationLevel p_level)
{
	if (p_level != MODULE_INITIALIZATION_LEVEL_SCENE)
		return;
	// Nothing to do here in this example.
}
