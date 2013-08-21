import java.io.*;
import MyReader;

public class test {
  static public void main( String args[] )
  {
      FileInputStream in;
      MyReader reader;

      try
      {
        in = new FileInputStream( "data.csv" );

        reader = new MyReader( in );
        reader.read();

        in.close();

        for( int index = 0; index < reader.size(); index++ )
        {
          System.out.println( reader.get( index ).first_name );
        }

      } catch( Exception except ) {

      }
  }
}
