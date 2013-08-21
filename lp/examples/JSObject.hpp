//-----------------------------------------------------------------------------------
// FILE:       JSObject.h
// PURPOSE:    Simple wrapper class for the objects in a JavaScript space.
// DATE:       5/11/99
// AUTHOR:     Jack Herrington
// COPYRIGHT:  1999-2002 All Rights Reserved.
//

// <EXAMPLE C++,C++ Embedded JavaScript,C++ Wrapper Class header>

#pragma once

#include "..\js\jsapi.h"
#include <windows.h>
#include <string>

using namespace std;

class CJSObject;
class CJSObject
{
public:
   static CJSObject *CreateNewObject( JSContext *pContext, const char *pszName );
   static CJSObject *CreateNewTemporaryObject( JSContext *pContext );

private:
   JSContext *       m_pContext;
   JSObject *        m_pObject;
   JSObject *        m_pParent;
   string            m_sName;

private:
                     CJSObject( void );
                     CJSObject( const CJSObject & );
   const CJSObject & operator=( const CJSObject & );
public:
                     CJSObject( JSContext *pContext,
                                JSObject *pObject );
                     ~CJSObject( void );

   JSContext *       GetContext( void ) const { return m_pContext; }
   JSObject *        GetObject( void ) const { return m_pObject; }

   bool              GetObjectAttribute( const char *pszName, JSObject **pObject );
   bool              SetObjectAttribute( const char *pszName, JSObject *pObject );

   bool              GetString( const char *pszName, string &sValue );
   bool              SetString( const char *pszName, string sValue );

   bool              GetDouble( const char *pszName, double &dValue );
   bool              SetDouble( const char *pszName, double dValue );

   bool              GetLong( const char *pszName, long &lValue );
   bool              SetLong( const char *pszName, long lValue );

   bool              GetBoolean( const char *pszName, bool &bValue );
   bool              SetBoolean( const char *pszName, bool bValue );

   JSObject *        GetObjectAttribute( const char *pszName );

   void              RunCode( const char *pszProperty, jsval *prValue = NULL );
   void              RunHandler( const char *pszProperty, jsval *prValue = NULL );
   void              RunJavaScript( const char *pszScript, jsval *prValue = NULL );

   void              SetObjectInfo( JSObject *pParent, const char *pszName );
};


class CJSRuntime
{
private:
   JSRuntime *       m_pRunTime;
   bool              m_bCreated;

private:
                     CJSRuntime( const CJSRuntime & );
   const CJSRuntime &operator=( const CJSRuntime & );

public:
                     CJSRuntime( void )
                     {
                        m_pRunTime = JS_NewRuntime( 8L * 1024L * 1024L );
                        m_bCreated = true;
                     }
                     CJSRuntime( JSRuntime *pRunTime )
                     {
                        m_pRunTime = pRunTime;
                        m_bCreated = false;
                     }
                     ~CJSRuntime( void )
                     {
                        if ( m_bCreated )
                        {
                           if ( m_pRunTime )
                              JS_DestroyRuntime( m_pRunTime );
                           JS_ShutDown();
                        }
                     }

   JSRuntime *       GetRuntime( void ) const { return m_pRunTime; }
};

class CJSContext
{
private:
   static HWND       s_hJavaScriptErrorWnd;

public:
   static void       SetJavaScriptErrorWnd( HWND hWnd ) { s_hJavaScriptErrorWnd = hWnd; }
   static HWND       GetJavaScriptErrorWnd( void ) { return s_hJavaScriptErrorWnd; }

private:
   CJSRuntime *      m_pRunTime;
   JSContext *       m_pContext;
   bool              m_bCreated;

private:
                     CJSContext( const CJSContext & );
   const CJSContext & operator=( const CJSContext & );

public:
                     CJSContext( bool bCreateRunTime = true,
                                 JSRuntime *pRunTime = NULL );
                     CJSContext( JSContext *pJSContext );
                     ~CJSContext( void );

   JSContext *       GetContext( void ) const { return m_pContext; }
   JSObject *        GetGlobalObject( void ) { return JS_GetGlobalObject( m_pContext ); }

   void              DefineFunction( const char *pszName,
                                     JSNative call,
                                     uintN nargs );
   void              DefineFunction( CJSObject *pObject,
                                     const char *pszName,
                                     JSNative call,
                                     uintN nargs );

   bool              Run( const char *pszCode, jsval *prVal = NULL, JSObject *pInputObject = NULL );
   string            GetLastError( void );
};

class MyObject : public CJSObject
{
private:
                     MyObject( const MyObject & );
   const MyObject & operator=( const MyObject & );

public:
                     MyObject( void );
};
