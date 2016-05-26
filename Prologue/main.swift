import Cocoa

let N = 300_000

var x: Int? = 0
let ht = HashTable<Int, Int>()
let t0 = NSDate()

for i in 0 ..< N {
    ht[i] = i
    x = ht[i]
    assert(x == i)
    assert(ht.count == i + 1)
}

let dt = NSDate().timeIntervalSinceDate(t0)
print(String(format:"%.0f ms", dt * 1000))
