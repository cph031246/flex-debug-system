trace() is a good feature in AS3... but I wanted to add the possibility to send traces over HTTP, and to a graphic class.
So it allows you to send logs and bugs traces to a graphic text area.

You can either choose the level of trace like "verbose", "bug", "simple trace" or "warning".

Because "trace" is easy and quick to write, I have chosen to decrease number of letter to write a trace with my class.
so you will type :
d.bug()_trace("my trace",this)
("d" is a singleton class, "bug()" is the getInstance():d)_

In order to get the trace verbose warning and bug at the top of autocompletion, the methods are prefixed with an underscore.