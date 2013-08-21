/**
 * This class stores a name and value pair.
 */
public class NameValuePair {
    /**
     * The name
     */
    public String _name;

    /**
     * The value
     */
    public Object _value;

    /**
     * This constructor takes a name and value pair to build
     * the object.
     * @param name The name.
     * @param value The value.
     */
    public NameValuePair( String name, Object value )
    {
      _name = name;
      _value = value;
    }
}
