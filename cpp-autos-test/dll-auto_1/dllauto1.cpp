#include <Windows.h>
extern "C" {
#include "lua.h"
#include "lualib.h"
#include "lauxlib.h"
}

#define dllauto1
#define LITERAL_TO_STR(lit) #lit
#define EXPORT_FUNCNAME(libname) luaopen_ ## libname
#define FUNC_FULLNAME(funcname) dllauto1 ## _ ## funcname
#define FUNC_SIGNATURE(funcname) static int FUNC_FULLNAME(funcname)(lua_State* L)
#define REG_FUNCNAME(funcname) { LITERAL_TO_STR(funcname), FUNC_FULLNAME(funcname) }

FUNC_SIGNATURE(HelloWorld)
{
	MessageBox(NULL, L"БъЬт", L"Hello World!", MB_OK);
	return 0;
}

FUNC_SIGNATURE(average)
{
	int n = lua_gettop(L);
	double sum = 0;
	int i;
	for (i = 1; i <= n; i++)
		sum += lua_tonumber(L, i);

	lua_pushnumber(L, sum / n);
	lua_pushnumber(L, sum);
	return 2;
}

static const luaL_reg Functions[] =
{
	REG_FUNCNAME(HelloWorld),
	REG_FUNCNAME(average)
};

extern "C"  __declspec(dllexport) int EXPORT_FUNCNAME(dllauto1)(lua_State* L)
{
	luaL_register(L, "dllauto1", Functions);
	return 1;
}