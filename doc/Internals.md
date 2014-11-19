Internals    {#internals}
============

Top level overview of how the project is organized and structured.  Kickof into specific class documentation.

Attached dictionary for binding to values in interface builder
Lua for scripting computed values.
Dependencies tracked by evaluating computed while tracking is on. This means you can circumvent if you aren't careful.
Arrays are observables with additional support for collection tracking.  Try to abstract both arrays and dictionaries as
key -> value
Bindings are done by class and 'name'.
