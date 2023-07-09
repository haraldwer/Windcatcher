#include "example.h"

Example::Example()
{
}

void Example::_bind_methods()
{
	ClassDB::bind_method(D_METHOD("func"), &Example::func);
}

void Example::func()
{
	WARN_PRINT("Testing the print method");
}


