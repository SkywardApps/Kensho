    #if false   //(!doxygen)
<!--  
    Markdown testing usage:
    
    In order to mix markdown (GitHub documentation), doxygen, AND still use this file as a unit test repository,
    things are going to get a bit tricky.
 
    ANY lines that you don't want the Objective-C compiler to see must be wrapped in an '#if false ... #endif' 
    block.  Otherwise, they will be compiled, and likely fail.
 
    Within any block not compiled, the text will be treated as Markdown.  This will result in documentation on
    both github as well as doxygen.
 
    However, if you want to use comments to describe your markdown (that will not be displayed anywhere) you must
    use an html comment block, like this one.
 
    Now, in order to segue into actual code snippets, before you end the #if block, use ```(languagename) to mark it
    as code for markdown.  This will be translated for doxygen as well.  Languagename in this case is 'objc'.  After the
    code snippet ends, and the code fence with another ```
 
    We've also added a keywork (!doxygen) which, if added at the end of the line, will exclude it from the doxygen
    generated code.  Sadly, there's no real way to do that with the markdown - we can edit the doxygen version to our
    heart's content, but at the end of the day both the Markdown on github and the compiler will see this file as-is.
        
 -->
Usage {#Usage}
=======

## Our Model

Blurb about our model and the properties

```objc
#endif   //(!doxygen)

@interface Person : NSObject

    @property (readonly) ObservableValue* firstName;
    @property (readonly) ObservableValue* lastName;
    @property (readonly) KenComputed* fullName;

@end

@implementation Person

- (id)initWithKensho:(Kensho *)ken
{
    if((self = [super init]))
    {
        _firstName = [[ObservableValue alloc] initWithKensho:ken];
        _lastName = [[ObservableValue alloc] initWithKensho:ken];
        _fullName = [[KenComputed alloc] initWithKensho:ken
            calculator:^NSString *(KenComputed* computed) {
                return [NSString stringWithFormat:@"%@ %@", _firstName.value, _lastName.value];
            }
        ];
    }
    return self;
}

@end

#if false   //(!doxygen)
```

Discuss the calculator aspect. 

```objc
#endif   //(!doxygen)

@interface TestUsage : XCTestCase

@end

@implementation TestUsage

#if false   //(!doxygen)
```

Lets make sure that the observables fire the notification event when they are changed.

```objc
#endif   //(!doxygen)

- (void) testObservableSendsNotification 
{    
    // Create our kensho manager object, and a Person to be our data model.
    Kensho* ken = [[Kensho alloc] init];
    Person* person = [[Person alloc] initWithKensho:ken];
    
    // Create a tester object to track if the notification is sent.
    ObservableTracker* tracker = [[ObservableTracker alloc] init];
    [person.firstName addObserver:tracker attribute:@"value" context:@"value"];

    XCTAssertFalse(tracker.wasUpdated);

    // Now update the value, and verify the tracker saw the update.
    person.firstName.value = @"David";
    XCTAssertTrue(tracker.wasUpdated);
}

#if false   //(!doxygen)
```

No biggie, right? Well, use a computed and see a bit more magic...

```objc
#endif   //(!doxygen)

- (void) testComputedSendsNotification
{
    // Create our kensho manager object, and a Person to be our data model.
    Kensho* ken = [[Kensho alloc] init];
    Person* person = [[Person alloc] initWithKensho:ken];

    // Verify our full name calculates correctly
    person.firstName.value = @"David";
    person.lastName.value = @"Blaine";
    XCTAssertEqualObjects(@"David Blaine", person.fullName.value);

    // Create a tester object to track if the notification is sent.
    ObservableTracker* tracker = [[ObservableTracker alloc] init];
    [person.fullName addObserver:tracker attribute:@"value" context:@"value"];
    XCTAssertFalse(tracker.wasUpdated);

    // Now update the value, and verify the tracker saw the update.
    person.lastName.value = @"Hasselhoff";
    XCTAssertTrue(tracker.wasUpdated);
    XCTAssertEqualObjects(@"David Hasselhoff", person.fullName.value);
}


#if false   //(!doxygen)
```

Automatic change propogation, even for a method? Woah.  This works for as many computeds as we can throw at it, as deep as we want.

Still, the read magic comes from the bindings.  Lets demonstrate with a text field.

```objc
#endif   //(!doxygen)

- (void) testTextFieldBinding
{
    // Create our kensho manager object, and a Person to be our data model.
    Kensho* ken = [[Kensho alloc] init];
    Person* person = [[Person alloc] initWithKensho:ken];

    person.firstName.value = @"David";
    person.lastName.value = @"Blaine";

    UITextField* textField = [[UITextField alloc] init];
    textField.text = @"<unset>";

    KenshoLuaWrapper* lua = [[KenshoLuaWrapper alloc] initWithKensho:ken context:person code:@"firstName"];
    UITextFieldBinding* binding = [[UITextFieldBinding alloc] initWithKensho:ken target:textField type:@"text" value:lua context:person];
    
    // Verify the text field was set upon binding
    XCTAssertEqualObjects(@"David", textField.text);

    // Verify the text field automatically updates
    person.firstName.value = @"James G.";
    XCTAssertEqualObjects(@"James G.", textField.text);
}

#if false   //(!doxygen)
```

Nice, the text field value auto updated.  Wait - what about typing into the field?

```objc
#endif   //(!doxygen)


- (void) testTextFieldReverseBinding
{
    // Create our kensho manager object, and a Person to be our data model.
    Kensho* ken = [[Kensho alloc] init];
    Person* person = [[Person alloc] initWithKensho:ken];

    person.firstName.value = @"David";
    person.lastName.value = @"Blaine";
    
    UITextField* textField = [[UITextField alloc] initWithFrame:CGRectMake(10,10,100,100)];
    textField.text = @"<unset>";

    KenshoLuaWrapper* lua = [[KenshoLuaWrapper alloc] initWithKensho:ken context:person code:@"firstName"];
    UITextFieldBinding* binding = [[UITextFieldBinding alloc] initWithKensho:ken target:textField type:@"text" value:lua context:person];

    // Verify the text field was set upon binding
    XCTAssertEqualObjects(@"David", textField.text);

    // Verify the text field updates the observable as well
    // We have to simulate the event of someone entering this
    textField.text = @"Michael";
    [textField sendActionsForControlEvents:UIControlEventEditingChanged];

    // Did the value update?
    XCTAssertEqualObjects(@"Michael", person.firstName.value);
}

#if false   //(!doxygen)
```
Awesome, the value updated! Cool!

That was very manual.  How can we do this with a little more... pazzaz?

Screenshot of a xib with a two text fields, and a label.  Screenshots of the properties as set for each.

Bind the views automatically.

```objc
#endif   //(!doxygen)

- (Kensho*) ken{return nil;}

- (void) testAutomaticViewBinding
{
    // Get the application kensho manager
    Kensho* ken = [(id)[[UIApplication sharedApplication] delegate] ken];

    Person* person = [[Person alloc] initWithKensho:ken];
    person.firstName.value = @"Roger";
    person.lastName.value = @"Moore";

    // Get the main view controller

}

#if false   //(!doxygen)
```

Nice.   Now we start to see it coming together.

More complicated scenario - tables and cells.

Themeing

Dynamic localization!

    #endif   //(!doxygen)

    @end  //(!doxygen)
