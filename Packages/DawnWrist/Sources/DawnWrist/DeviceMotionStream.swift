#if canImport(CoreMotion) && os(watchOS)
import CoreMotion
import DawnCore
import Foundation

/// Device motion at ten readings a second, gravity removed (motion monitor from WakeTF, MIT).
public actor DeviceMotionStream: MotionStream {
    private let manager = CMMotionManager()
    private let queue: OperationQueue = {
        let queue = OperationQueue()
        queue.maxConcurrentOperationCount = 1
        queue.qualityOfService = .userInitiated
        return queue
    }()

    public init() {}

    public func start() async -> AsyncStream<MotionSample> {
        let (stream, sink) = AsyncStream<MotionSample>.makeStream()
        guard manager.isDeviceMotionAvailable else {
            sink.finish()
            return stream
        }
        // Device-motion timestamps count from boot; the reading's moment is taken as when it lands.
        manager.deviceMotionUpdateInterval = Tuning.Wake.motionInterval
        manager.startDeviceMotionUpdates(to: queue) { motion, _ in
            guard let motion else { return }
            let acceleration = motion.userAcceleration, rotation = motion.rotationRate
            sink.yield(MotionSample(
                date: Date(), acceleration: SIMD3(acceleration.x, acceleration.y, acceleration.z),
                rotation: SIMD3(rotation.x, rotation.y, rotation.z)
            ))
        }
        return stream
    }

    public func stop() async {
        manager.stopDeviceMotionUpdates()
    }
}
#endif
