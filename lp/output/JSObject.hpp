class : CJSObject - 
Methods:
  CreateNewObject - CJSObject * - ( pContext - JSContext *, pszName - const char * ) - public - static
  CreateNewTemporaryObject - CJSObject * - ( pContext - JSContext * ) - public - static
  CJSObject -  - (  - void ) - private
  CJSObject -  - (  - const CJSObject & ) - private
  operator= - const CJSObject & - (  - const CJSObject & ) - private
  CJSObject -  - ( pContext - JSContext *, pObject - JSObject * ) - public
  ~CJSObject -  - (  - void ) - public
  GetContext - JSContext * - (  - void ) - public
  GetContext - JSContext * - (  - void ) - public
Variables:
  m_pContext - JSContext * - private
  m_pObject - JSObject * - private
  m_pParent - JSObject * - private
  m_sName - string - private
class : CJSRuntime - 
Methods:
  CJSRuntime -  - (  - const CJSRuntime & ) - private
  &operator= - const CJSRuntime - (  - const CJSRuntime & ) - private
  CJSRuntime -  - (  - void ) - public
  CJSRuntime -  - (  - void ) - public
  CJSRuntime -  - (  - void ) - public
  CJSRuntime -  - (  - void ) - public
  CJSRuntime -  - (  - void ) - public
Variables:
  m_pRunTime - JSRuntime * - private
  m_bCreated - bool - private
class : CJSContext - 
Methods:
  SetJavaScriptErrorWnd - void - ( hWnd - HWND ) - public - static
  SetJavaScriptErrorWnd - void - ( hWnd - HWND ) - public - static
Variables:
  s_hJavaScriptErrorWnd - HWND - private - static
class : MyObject - CJSObject
Methods:
  MyObject -  - (  - const MyObject & ) - private
  operator= - const MyObject & - (  - const MyObject & ) - private
  MyObject -  - (  - void ) - public
Variables:
