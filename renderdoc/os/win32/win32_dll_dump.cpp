#include "win32_dll_dump.h"
#if DUMP_DLL
#include "common/common.h"
#include "common/formatting.h"
#include "core/core.h"
#include <string>
#include <stdio.h>
#include <iostream>
#include <Windows.h>
#include <map>
#include <tchar.h>
using namespace std;

//#include "dbghelp.h"
#pragma comment(lib,"dbghelp.lib")


/*
获取dll所有函数地址，包括非导出函数
https://bbs.pediy.com/thread-174671.htm
*/
#include <Windows.h>
#include <imagehlp.h>
#include <locale.h>
#pragma comment(lib,"DbgHelp.lib")
#pragma comment(lib,"Imagehlp.lib")


BOOL CALLBACK PdbParse::CallBackProc(PSYMBOL_INFO pSymInfo, ULONG SymbolSize, PVOID UserContext)
{
	FILE* pFile = (FILE*)UserContext;
	fprintf(pFile, "函数名: %s\n地址: %08X\r\n", pSymInfo->Name, pSymInfo->Address);
	const char* name = pSymInfo->Name;
	//auto kv = map<string, _SYMBOL_INFO>::value_type("", pSymInfo);
	Function_Data* data = new Function_Data();
	data->Address = pSymInfo->Address;
	s_func_address_map[pSymInfo->Name] = data;
	/*if (strcmp(pSymInfo->Name, "PyCFunction_Type") == 0) {
		ULONG64 offset = pSymInfo->Address - py_SymModule;
		LOG("hm_python:%d, py_SymModule:%d", hm_python, py_SymModule);
		LOG("PyCFunction_Type:%d,%d,%ld", PyCFunction_Type, pSymInfo->Address, offset);
	}*/
	return TRUE;
}

BOOL PdbParse::GetSymbol(HMODULE hmoudle, FILE* pFile)
{
	DWORD pid = GetCurrentProcessId();
	//HANDLE hProcess = GetCurrentProcess();
	HANDLE hProcess = OpenProcess(PROCESS_ALL_ACCESS, FALSE, pid);
	CloseHandle(hProcess);


	DWORD dwOpt = SymGetOptions();
	dwOpt = dwOpt | SYMOPT_DEBUG | SYMOPT_DEFERRED_LOADS | SYMOPT_UNDNAME | SYMOPT_CASE_INSENSITIVE;
	SymSetOptions(dwOpt);

	if (!SymInitialize(hProcess, NULL, FALSE))
	{
		LOG("SymInitialize error\n");
		return FALSE;
	}
#if 0
	char sFileName[MAX_PATH] = { 0 };
	WIDE_2_UTF8(FileName, sFileName, MAX_PATH);
	LOG(sFileName);
	PLOADED_IMAGE ploadImage = ImageLoad(sFileName, NULL);
	HANDLE hSystemFile = CreateFileA(sFileName, GENERIC_READ, FILE_SHARE_READ | FILE_SHARE_WRITE,
		NULL, OPEN_EXISTING, 0, NULL);
	DWORD dwFileSize = GetFileSize(hSystemFile, NULL);
	DWORD64 dwSymModule = SymLoadModule64(hProcess, ploadImage->hFile, NULL, ploadImage->ModuleName, (DWORD64)ploadImage->MappedAddress, dwFileSize);
	//DWORD64 dwSymModule = SymLoadModuleEx(hProcess, NULL, sFileName, NULL, 0, 0,0,0);
#elif 1
	char dll_path[1024];
	WCHAR sDllPath[1024];
	GetModuleFileName(hmoudle, sDllPath, 1024);
	WIDE_2_UTF8(sDllPath, dll_path, 1024);

	HANDLE hSystemFile = CreateFileA(dll_path, GENERIC_READ, FILE_SHARE_READ | FILE_SHARE_WRITE,
		NULL, OPEN_EXISTING, 0, NULL);
	DWORD dwFileSize = GetFileSize(hSystemFile, NULL);


	DWORD64 dwSymModule = SymLoadModule64(hProcess, NULL, dll_path, NULL, (DWORD64)hmoudle, dwFileSize);
#else
	DWORD64 dwSymModule = SymLoadModuleEx(hProcess,
		NULL,
		sFileName,
		NULL,
		0,
		0,
		NULL,
		0);
#endif
	if (0 == dwSymModule)
	{
		LOG("SymLoadModuleEx error:%d", GetLastError());
		SymCleanup(hProcess);
		return -1;
	}
	/*
	[]        //未定义变量.试图在Lambda内使用任何外部变量都是错误的.
	[x, &y]   //x 按值捕获, y 按引用捕获.
	[&]       //用到的任何外部变量都隐式按引用捕获
	[=]       //用到的任何外部变量都隐式按值捕获
	[&, x]    //x显式地按值捕获. 其它变量按引用捕获
	[=, &z]   //z按引用捕获. 其它变量按值捕获
*/
	auto cb = [](PSYMBOL_INFO pSymInfo, ULONG SymbolSize, PVOID UserContext) {
		void** c = (void**)UserContext;
		auto o = (PdbParse*)c[0];
		return o->CallBackProc(pSymInfo, SymbolSize, c[1]);
	};
	void* UserContext[] = { this, pFile };
	if (!SymEnumSymbols(hProcess, (DWORD64)hmoudle, 0, (PSYM_ENUMERATESYMBOLS_CALLBACK)cb, UserContext))
	{
		LOG("SymEnumSymbols error\n");
		SymCleanup(hProcess);
		return -1;
	}
	SymUnloadModule64(hProcess, dwSymModule);
	return SymCleanup(hProcess);
}



int PdbParse::LoadSymbol(HMODULE hmoudle, string name)
{
	if (hmoudle == NULL) {

		LOG("GetSymbol error,No HMoudle %s\n", name.c_str());
		return -1;
	}
	//UTF8_2_WIDE("C:\\Windows\\System32\\WS2_32.DLL", sDllPath);
	// char logfile[256];
	// sprintf(logfile, "d://%s_symbol.txt", name.c_str());
	rdcstr logfile = StringFormat::Fmt("d://symbols/%s_symbol.txt", name.c_str());
	for(int i=0;FileIO::exists(logfile);i++)
	{
		logfile = StringFormat::Fmt("d://symbols/%s_symbol_%d.txt", name.c_str(), i);
	}
	FileIO::CreateParentDirectory(logfile);
	FILE* pFile = fopen(logfile.c_str(), "w+");
	bool isOK = GetSymbol(hmoudle, pFile);
	fclose(pFile);
	pFile = NULL;

	WCHAR sDllPath[1024];
	GetModuleFileName(hmoudle, sDllPath, 1024);
	//UTF8_2_WIDE(py_dll, sDllPath);
	LOG("%ls GetSymbol code:%d\n", sDllPath, isOK);

	if (!isOK)
	{
		LOG("GetSymbol error\n");
		return -1;
	}
	LOG("GetSymbol ok\n");
	return 0;
}

Function_Data* PdbParse::GetFuncData(string funcname) {
	//map<const char*, PSYMBOL_INFO>::iterator 
	auto iter = s_func_address_map.find(funcname);
	if (iter == s_func_address_map.end()) {
		LOG("GetFunc Error:%s", funcname.c_str());
		return NULL;
	}
	return iter->second;
}

template <typename T>
T PdbParse::GetFunc(string funcname)
{
	//先找hook的function
	auto iter = s_origin_func_map.find(funcname);
	if (iter != s_origin_func_map.end()) {
		T pfunc = (T)iter->second;
		return pfunc;
	}

	//再找原始的function
	auto data = this->GetFuncData(funcname);
	if (data != NULL) {
		T pfunc = (T)(data->Address);
		return pfunc;
	}
	return NULL;
}


int PdbParse::DoFuncHook(const char* name, void* InHookProc) {
	//auto data = this->GetFuncData(name);
	//if (data == NULL) {
	//	LOG("DoFuncHook Error:%s", name);
	//	return -1;
	//}
	//void* origin_func = NULL;
	////FARPROC proc = (FARPROC)(hModule + iter->second->Address);
	//FARPROC proc = (FARPROC)(data->Address);
	////FARPROC proc2 = (FARPROC)(hm_python - hm_main + data->Address);
	////PyFile_WriteObject pFunc = (PyFile_WriteObject)proc;
	////pFunc();
	////printf_s("%s hModule = %d, pFunc = %d\n", name, hModule, proc);


	//// Create a hook for MessageBoxW, in disabled state.
	//if (MH_CreateHook(proc, InHookProc, reinterpret_cast<LPVOID*>(&origin_func)) != MH_OK)
	//{
	//	LOG("minhook hook funcation error\n");
	//	return 1;
	//}
	//if (origin_func == NULL) {

	//	LOG("minhook origin_func is null\n");
	//	return 1;
	//}

	//// Enable the hook for MessageBoxW.
	//if (MH_EnableHook(proc) != MH_OK)
	//{
	//	LOG("minhook enable error\n");
	//	return 1;
	//}
	//s_origin_func_map[name] = origin_func;
	return 0;

}
#endif


