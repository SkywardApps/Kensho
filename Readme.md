Kensho Documentation    {#mainpage}
============

# Kensho
> To see into one's own nature. The experience of enlightenment, satori.

## Key Concepts
<table>
<tr>
<td>
<h3>Declarative Bindings</h3>
Easily associate DOM elements with model data using a concise, readable syntax
</td>
<td>
<h3>Automatic UI Refresh</h3>
When your data model's state changes, your UI updates automatically
</td>
<td>
<h3>Dependency Tracking</h3>
Implicitly set up chains of relationships between model data, to transform and combine it
</td>
</tr>
</table>

We want - a quick overview on Kensho, the origin of the term, the project purpose, related projects.
Talk about the coverage (ios, android) and how it will be documented

[Introduction](doc/Introduction.md)

[QuickStart](doc/QuickStart.md)

[Tutorials](doc/Tutorials.md)

[Frequently Asked Questions](doc/FAQ.md)

[Roadmap](doc/Roadmap.md)

[Internals](doc/Internals.md)




## Introduction
Knockout is a JavaScript library that helps you to create rich, responsive display and editor user interfaces with a clean underlying data model. Any time you have sections of UI that update dynamically (e.g., changing depending on the user’s actions or when an external data source changes), KO can help you implement it more simply and maintainably. 

### Headline features:
- Elegant dependency tracking - automatically updates the right parts of your UI whenever your data model changes.
- Declarative bindings - a simple and obvious way to connect parts of your UI to your data model. You can construct a complex dynamic UIs easily using arbitrarily nested binding contexts.
- Trivially extensible - implement custom behaviors as new declarative bindings for easy reuse in just a few lines of code.

### Additional benefits:

- Pure JavaScript library - works with any server or client-side technology
- Can be added on top of your existing web application without requiring major architectural changes
- Compact - around 13kb after gzipping
- Works on any mainstream browser (IE 6+, Firefox 2+, Chrome, Safari, others)
- Comprehensive suite of specifications (developed BDD-style) means its correct functioning can easily be verified on new browsers and platforms


-----

 Observable = data
 ObservableArray = array
 ObservableMap = dictionary

CalculatedObservable = data
ProxyArray = array
ProxyMap = dictionary

LuaObservable = CalculatedObservable -> mapped parameters from lua script
ParameterObservable = CalculatedObservable from mapped parameter -> data


\todo Simplify Observable (No need for number, string, etc?)    [Done]
\todo Create a KenshoContext to track __parent and __root       [Done]
\todo Make LuaWrapper basically independant, and processing bindings should create a Calculated. [Mostly Done]
\todo Rename CalculatedObservable to Computed   [Done]
\todo LuaWrapper must handle tables -> dictionaries [Done]
\todo Bindings should take a simple variable to bind to, or a complex config object [Mostly Done]
\todo LuaWrapper should handle __parent and __root in bindings [Done]
\todo Remove unneeded tests
\todo Update and add test coverage
\todo Events? Particularly post-render events for 'foreach', or the like?
\todo Clean up ObservableArray, ProxyObservableArray, and Map variations.  Maybe just rename ComputedArray too.
\todo Bindings need to get a computed (the luawrapper) and then handle the result as either a 
    value or an observable in and of itself

\todo Figure out how arrays are handled when they could be in an observablearray, an array in an observable, 
    a result of a computed, or a ComputedArray.  For example, tableview foreach binding is a good use case.  It needs
    to track the events of the array, so it expects an observablearray.  However, coming from the LuaWrapper evaluation,
    it is just a regular Computed, so it doesn't expose the same events.  How can we pass through those events?  We could assign
    attached data to each object, like 'observableowner', and then for any value see if we can get an obserbableowner and bind to
    that instead.  However, that's still only true in the case of a real pass-through.  To get a generalized solution, we may need 
    to have Observables / Computed values check the prior array value vs the new array value and generate add / remove / move 
    events.  In this scenario, we wouldn't necessarly need ObservableArrays?  Maybe see how knockout does it... because they do have
    observable arrays and their pattern generally matches our own.  Although they may not worry about it with a foreach??
    May need a way to specify a key identifier situation...

