import Foundation

// 默认优先级 只带一个尾随闭包
let item1 = DispatchWorkItem {
    for i in 0...10{
        print("item1 -> \(i)  thread: \(Thread.current)")
    }
}


// qos:任务优先级
// DispatchQoS.userInteractive 最高优先级，通常只做些短的快的事情，比如一些用户交互,这些事几乎是可以选择在主队列运行的
// DispatchQoS.userInitiated 也有高优先级，可能会花一点时间，但必须立即执行，因为是用户要求的,比如用户按了个按钮的开关
// DispatchQos.background 非用户强制要求的事情，可以等后台有空的情况下运行，优先级较低
// DispatchQos.utility 通常是你的应用程序想做的事，优先级低

// flags：特殊标记
let item2 = DispatchWorkItem(qos: DispatchQoS.userInitiated, flags: DispatchWorkItemFlags.barrier) {
    for i in 0...10{
        print("item2 -> \(i)  thread: \(Thread.current)")
    }
}

let item3 = DispatchWorkItem {
    for i in 0...10{
        print("item3 -> \(i)  thread: \(Thread.current)")
    }
}

let item4 = DispatchWorkItem {
    for i in 0...10{
        print("item4 -> \(i)  thread: \(Thread.current)")
    }
}


// 获得主队列(用来运行UI活动)
let mainQueue1 = DispatchQueue.main
//主队列追加同步任务，会引起死锁 item1和item2相互等待对方先执行完
//mainQueue1.sync(execute: item1)
//mainQueue1.sync(execute: item2)

//主队列追加异步任务，按顺序打印
//mainQueue1.async(execute: item1)
//mainQueue1.async(execute: item2)


// 同一队列上异步执行多个任务，而无需阻塞特定线程
let globalQueue1 = DispatchQueue.global()
//全局队列追加同步任务，按顺序打印
//globalQueue1.sync(execute: item1)
//globalQueue1.sync(execute: item2)
//全局队列追加异步任务，随机打印
//globalQueue1.async(execute: item1)
//globalQueue1.async(execute: item2)



// label:附加到队列的字符串标签，便于调试
// attributes:队列的执行方式，省略按照串行执行，指定concurrent则为并列执行
//串行队列
let serialQueue1 = DispatchQueue(label: "com.serialQueue1")
//并行队列
let concurrentQueue1 = DispatchQueue(label: "com.concurrentQueue1", attributes: .concurrent)
// 自定义串行队列追加同步任务，按顺序打印
//serialQueue1.sync(execute: item1)
//serialQueue1.sync(execute: item2)

// 自定义串行队列追加异步任务，按顺序打印
//serialQueue1.async(execute: item1)
//serialQueue1.async(execute: item2)

// 自定义并行队列追加同步任务，按顺序打印
//concurrentQueue1.sync(execute: item1)
//concurrentQueue1.sync(execute: item2)

// 自定义并行队列追加异步任务，随机打印
//concurrentQueue1.async(execute: item1)
//concurrentQueue1.async(execute: item2)
//concurrentQueue1.async(execute: item3)
//concurrentQueue1.async(execute: item4)

// 自定义串行队列追加混合任务 顺序打印
//serialQueue1.async(execute: item1)
//serialQueue1.sync(execute: item2)
//serialQueue1.async(execute: item3)
//serialQueue1.async(execute: item4)


// 自定义并行队列追加混合任务 随机打印，同步任务执行期间不会穿插异步任务，并行队列同步任务，回到主线程执行
//concurrentQueue1.async(execute: item1)
//concurrentQueue1.async(execute: item2)
//concurrentQueue1.async(execute: item3)
//concurrentQueue1.sync(execute: item4)


//let group1 = DispatchGroup()
//concurrentQueue1.async(group: group1, execute: item1)
//concurrentQueue1.async(group: group1, execute: item2)
//group1.notify(queue: concurrentQueue1) {
//    print("group1 执行完毕 thread: \(Thread.current)")
//    // 需要注意这里不会阻塞线程，所以不是主线程，需要UI变化操作，需要回调主线程
//    DispatchQueue.main.async {
//        print("刷新UI")
//    }
//}

//let group2 = DispatchGroup()
//concurrentQueue1.async(group: group2, execute: item1)
//concurrentQueue1.async(group: group2, execute: item2)
//let result = group2.wait(timeout: DispatchTime.now() + 0.1)
//switch result {
//case .success:
//    print("success")
//case .timedOut:
//    print("timedOut")
//}

let group3 = DispatchGroup()
// 将并行队列挂起
concurrentQueue1.suspend()
serialQueue1.async(group: group3, execute: {
    // 模拟网络加载
    sleep(2)
    print("serialQueue1执行完毕")
    // 将并行队列恢复
    concurrentQueue1.resume()
})
concurrentQueue1.async(group: group3, execute: {
    // 模拟网络加载
    sleep(2)
    print("concurrentQueue1执行完毕")
})

// queue:回调所在的线程，这里直接回调到了主线程
group3.notify(queue: DispatchQueue.main) {
    print("监听group3执行完毕")
}

// 这里会报timedOut，因为是两个耗时任务
let result2 = group3.wait(timeout: DispatchTime.now() + 1)
switch result2 {
case.success:
    print("success")
case.timedOut:
    print("timedOut")
}


