#pragma once

#include "core/object/ref_counted.h"

class Example : public RefCounted
{

	GDCLASS(Example, RefCounted)

public:

	Example();
	void func();

protected:

	static void _bind_methods();

};
