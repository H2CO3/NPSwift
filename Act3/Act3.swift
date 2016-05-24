func incrementResult(fn: () -> Int) -> Int {
    return fn() + 1
}

func getAnswer() -> Int {
    return 42
}

func doStuff() {
    getAnswer()
    incrementResult(getAnswer)
}


