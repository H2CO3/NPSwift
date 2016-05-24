class Foo {
    // ...
}

func use_foo(foo: Foo) {
}

func juggle_foo() {
    var f1 = Foo() // allocate f1
    let f2 = f1    // strong_retain f2

}                  // strong_release f2 (end-of-scope, LIFO)
                   // strong_release f1 (end-of-scope, LIFO)
