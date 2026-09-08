import Flutter
import Foundation

/// Bridges [GpTomLog] to the Dart side. Kept apart from GpTomPlugin, which is
/// already the stream handler of the events channel.
final class GpTomLogStreamHandler: NSObject, FlutterStreamHandler {

    public func onListen(
        withArguments arguments: Any?, eventSink events: @escaping FlutterEventSink
    )
        -> FlutterError?
    {
        GpTomLog.attachSink { entry in events(entry) }
        return nil
    }

    public func onCancel(withArguments arguments: Any?) -> FlutterError? {
        GpTomLog.detachSink()
        return nil
    }
}
