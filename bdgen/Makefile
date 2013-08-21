all: examples/Test1.class examples/Test2.class examples/Test3.class examples/Test4.class

clean:
	-find . -name "*~" | xargs rm
	-find . -name "*.bak" | xargs rm
	-find . -name "*.class" | xargs rm

examples/Test1.class: examples/Test1.java
	javac examples/Test1.java

examples/Test2.class: examples/Test2.java
	javac examples/Test2.java

examples/Test3.class: examples/Test3.java
	javac examples/Test3.java

examples/Test4.class: examples/Test4.java
	javac examples/Test4.java
