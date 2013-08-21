class CJSObject;
class CJSObject : public MyObject, private anotherObject
{
public:
   static CJSObject *CreateNewObject( JSContext *pContext, const char *pszName );
   static CJSObject *CreateNewTemporaryObject( JSContext *pContext );

private:
   const int m_someValue = 2;
   static JSContext *       m_pContext;
   JSObject *        m_pObject;
   JSObject *        m_pParent;
   string            m_sName;

private:
                     CJSObject( void );
                     CJSObject( const CJSObject & );
   const CJSObject & operator=( const CJSObject & );
};
