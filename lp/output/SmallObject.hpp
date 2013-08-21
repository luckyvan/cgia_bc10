class : CJSObject - MyObject, anotherObject
Methods:
  CreateNewObject - CJSObject * - ( pContext - JSContext *, pszName - const char * ) - public - static
  CreateNewTemporaryObject - CJSObject * - ( pContext - JSContext * ) - public - static
  CJSObject -  - (  - void ) - private
  CJSObject -  - (  - const CJSObject & ) - private
  operator= - const CJSObject & - (  - const CJSObject & ) - private
Variables:
  m_someValue - int - private - const = 2
  m_pContext - JSContext * - private - static
  m_pObject - JSObject * - private
  m_pParent - JSObject * - private
  m_sName - string - private
