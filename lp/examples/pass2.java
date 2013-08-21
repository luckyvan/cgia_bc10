public class pass2
{
	public class MyClass
	{
		private Integer _myInt;
		public MyClass( int newValue ) { _myInt = new Integer( newValue ); }
		public Integer getInt( ) { return _myInt; }
		public void setInt( int newValue ) { _myInt = new Integer( newValue ); }
		public String toString( ) { return _myInt.toString(); }
	}

	public pass2()
	{
		pass2.MyClass a = new pass2.MyClass( 10 );
		static_method1( a );
		static_method1( a );
	}

	public void static_method1( pass2.MyClass a )
	{
		System.out.println( a );
		a.setInt( 20 );
	}

	public static void main( String argv[] )
	{
		pass2 app = new pass2();
	}
}
