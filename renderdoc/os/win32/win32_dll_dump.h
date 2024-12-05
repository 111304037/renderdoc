#pragma once
#if DUMP_DLL
#define WIN32_LEAN_AND_MEAN             // 从 Windows 头文件中排除极少使用的内容
// Windows 头文件
#include <windows.h>
#include <Windows.h>
#include <imagehlp.h>
#include <locale.h>
#include <string>
#include <stdio.h>
#include <iostream>
#include <Windows.h>
#include <map>
#include <tchar.h>
using namespace std;


#include "common/common.h"


// 在此处引用程序需要的其他标头
#include <stdio.h>

#define UTF8_2_WIDE(src,dst) MultiByteToWideChar( CP_UTF8, 0, src, -1, dst, MAX_PATH )
#define WIDE_2_UTF8(src,dst,size) wcstombs(dst, src, size);//WideCharToMultiByte( CP_UTF8, 0, src, -1, dst, MAX_PATH )
#define GetWideLength(utf8_src) MultiByteToWideChar(CP_UTF8,0,utf8_src,-1,NULL,0)


struct Function_Data {
	ULONG64     Address;          // Address of symbol including base address of module
};

class PdbParse {
protected:

	BOOL CALLBACK CallBackProc(PSYMBOL_INFO pSymInfo, ULONG SymbolSize, PVOID UserContext);

	BOOL GetSymbol(HMODULE hmoudle, FILE* pFile);

public:

	map<string, Function_Data*> s_func_address_map;
	map<string, void*> s_origin_func_map;

	int LoadSymbol(HMODULE hmoudle, string name);

	Function_Data* GetFuncData(string funcname);

	template <typename T>
	T GetFunc(string funcname);


	int DoFuncHook(const char* name, void* InHookProc);
};


typedef struct _SYMBOL_INFO *PSYMBOL_INFO;

#define PyMethod_Check(op) ((op)->ob_type == &PyMethod_Type)
#define PyMethod_GET_FUNCTION(meth) \
        (((PyMethodObject *)meth) -> im_func)

#define PyFunction_Check(op) (Py_TYPE(op) == &PyFunction_Type)
#define PyClass_Check(op) ((op)->ob_type == &PyClass_Type)
#define PyInstance_Check(op) ((op)->ob_type == &PyInstance_Type)
#define PyMethod_Check(op) ((op)->ob_type == &PyMethod_Type)

//typedef void*(*call_function)(void ***pp_stack, int oparg);
//call_function g_call_function;

void* getAttr(void* o, const char* attr_name);
typedef void(__fastcall *Action)();
extern Action onBeginFrame;
extern PDWORD nexoRenderInst;

//extern PdbParse* py27Pdb, *neoxRenderPdb;
//map<const char*, PSYMBOL_INFO, ptrCmp> s_func_address_map;
//extern HMODULE hm_python, hm_main;


#define LOG RDCLOG


#define Py_TYPE(ob)             (((PyObject*)(ob))->ob_type)
extern void* PyCFunction_Type;
#define PyCFunction_Check(op) (Py_TYPE(op) == PyCFunction_Type)


#endif