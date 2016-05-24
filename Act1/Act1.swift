func FnWithInout(inout x: Int) {
    x = 1337
}

func CallInout() {
    var x = 42
    FnWithInout(&x)
}

