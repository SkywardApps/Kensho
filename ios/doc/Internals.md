Internals    {#internals}
============

Top level overview of how the project is organized and structured.  Kickof into specific class documentation.

Attached dictionary for binding to values in interface builder
Lua for scripting computed values.
Dependencies tracked by evaluating computed while tracking is on. This means you can circumvent if you aren't careful.
Arrays are observables with additional support for collection tracking.  Try to abstract both arrays and dictionaries as
key -> value
Bindings are done by class and 'name'.


Topics to cover in architecture, in order of descent into madness
- Kensho object & context
- Lua Wrapper
- Bindings & Ken category method
- Use in Interface Builder
- Tracker & observe: category method
 - Internal attribute tracking
  - Only tracks KVC compliant attributes
 - Swizzleing per class
  - Swizzles for everyone! Performance issue!
  - Swizzles all parents! Except NSObject
  - Block created per method for 'type safety'
 - Dependency Tracking via ken
 - Change propogation
- Computed
- ObservableValue for Parity
- KenModel for convenience