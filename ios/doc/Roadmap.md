Roadmap    {#Roadmap}
============

### iOS Progress
<TABLE>
<TR>
<TH>Status</TH>
<TH>Item</TH>
</TR>
<TR>
<TD>Completed</TD>
<TD>Lua Integration</TD>
</TR>
<TR>
<TD>Completed</TD>
<TD>Observable Values</TD>
</TR>
<TR>
<TD>Completed</TD>
<TD>Computed Values</TD>
</TR>
<TR>
<TD>In Progress</TD>
<TD>ObservableArray</TD>
</TR>
<TR>
<TD>Todo</TD>
<TD>ObservableMap</TD>
</TR>
<TR>
<TD>Todo</TD>
<TD>Bi-directional binding</TD>
</TR>
</TABLE>


- @todo thoughts
 - if-then-else or case method in lua, since we can't use the 'if' logic or looping at all in the current declaration code.
 - version of 'observe' that takes a whitelist of attributes to track, so we don't wrap methods we don't care about (performance)
 - version of KenModel that can use internal dispatch rather than just using the tracker.  This may be a faster method than constantly
   getting the attached object.  Could still use KVO, or even just a system where the object itself notifies the dispatcher
 - two-way bindings
 - method or selector bindings.  Ie, what happens when you click a button? Could even inline lua to execute?
 - integrate lua more directly. Maybe a static executor? Then we have a scripting engine available anywhere.
 - How do we do templating? Do we even want to?
 - How to we bind to collections better, and get add/remove/move events? KVO supports this, and foreach could use it pretty effectively.
 - Do we need other layout bindings, like 'grid'? Or are things like 'space before' 'space after' space between' sufficient?
 - Tests
 - Documentation
 - Auto-doxygen