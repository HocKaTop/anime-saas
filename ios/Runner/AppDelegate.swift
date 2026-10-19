import AVKit
import Flutter
import UIKit

@main
@objc class AppDelegate: FlutterAppDelegate, FlutterImplicitEngineDelegate {
  override func application(
    _ application: UIApplication,
    didFinishLaunchingWithOptions launchOptions: [
      UIApplication.LaunchOptionsKey: Any
    ]?
  ) -> Bool {
    return super.application(
      application,
      didFinishLaunchingWithOptions: launchOptions
    )
  }

  func didInitializeImplicitFlutterEngine(
    _ engineBridge: FlutterImplicitEngineBridge
  ) {
    GeneratedPluginRegistrant.register(with: engineBridge.pluginRegistry)

    guard let registrar = engineBridge.pluginRegistry.registrar(
      forPlugin: "NativeHlsPlayer"
    ) else {
      return
    }

    registrar.register(
      NativeHlsFactory(messenger: registrar.messenger()),
      withId: "anime/native_hls"
    )
  }
}

final class NativeHlsFactory: NSObject, FlutterPlatformViewFactory {
  private let messenger: FlutterBinaryMessenger

  init(messenger: FlutterBinaryMessenger) {
    self.messenger = messenger
    super.init()
  }

  func createArgsCodec() -> FlutterMessageCodec & NSObjectProtocol {
    FlutterStandardMessageCodec.sharedInstance()
  }

  func create(
    withFrame frame: CGRect,
    viewIdentifier viewId: Int64,
    arguments args: Any?
  ) -> FlutterPlatformView {
    NativeHlsView(
      frame: frame,
      viewId: viewId,
      args: args,
      messenger: messenger
    )
  }
}

final class NativeHlsView: NSObject, FlutterPlatformView {
  private let container: NativePlayerContainer
  private let player = AVPlayer()
  private let channel: FlutterMethodChannel
  private var startPosition: Double
  private var resumePlayback = false
  private var sourceVersion = 0

  private var ready = false
  private var restoring = false
  private var disposed = false

  init(
    frame: CGRect,
    viewId: Int64,
    args: Any?,
    messenger: FlutterBinaryMessenger
  ) {
    let values = args as? [String: Any] ?? [:]

    startPosition = max(
      0,
      (values["positionSec"] as? NSNumber)?.doubleValue ?? 0
    )

    container = NativePlayerContainer(frame: frame)

    channel = FlutterMethodChannel(
      name: "anime/native_hls/\(viewId)",
      binaryMessenger: messenger
    )

    super.init()

    container.controller.player = player
    container.controller.showsPlaybackControls = false
    container.controller.allowsPictureInPicturePlayback = false
    container.controller.videoGravity = .resizeAspect

    if let address = values["url"] as? String,
       let url = URL(string: address),
       url.scheme == "http" || url.scheme == "https" {
      player.replaceCurrentItem(with: AVPlayerItem(url: url))
    }

    try? AVAudioSession.sharedInstance().setCategory(
      .playback,
      mode: .moviePlayback
    )
    try? AVAudioSession.sharedInstance().setActive(true)

    channel.setMethodCallHandler { [weak self] call, result in
      guard let self = self, !self.disposed else {
        result(
          FlutterError(
            code: "disposed",
            message: "Player closed",
            details: nil
          )
        )
        return
      }

      switch call.method {
      case "state":
        result(self.snapshot())

      case "pause":
        self.player.pause()
        result(self.snapshot())

      case "replaceSource":
      self.replaceSource(call.arguments, result: result)

      case "dispose":
        self.close()
        result(nil)

      default:
        result(FlutterMethodNotImplemented)
      }
    }
  }

  func view() -> UIView {
    container
  }

  private func snapshot() -> [String: Any] {
  guard let item = player.currentItem else {
    return ["error": "Не удалось открыть видео"]
  }

  if item.status == .failed {
    return [
      "error":
        "Не удалось загрузить видео. Проверьте соединение и доступ к просмотру"
    ]
  }

  if item.status == .readyToPlay && !ready && !restoring {
    restoring = true

    let duration = item.duration.seconds
    let position = duration.isFinite && duration > 0
      ? min(startPosition, duration)
      : startPosition

    if position == 0 {
      ready = true
      restoring = false
      container.controller.showsPlaybackControls = true

      if resumePlayback {
        player.play()
      }

      resumePlayback = false
    } else {
      let version = sourceVersion

      player.seek(
        to: CMTime(seconds: position, preferredTimescale: 600),
        toleranceBefore: .zero,
        toleranceAfter: .zero
      ) { [weak self] finished in
        DispatchQueue.main.async {
          guard let self = self,
                !self.disposed,
                self.sourceVersion == version else {
            return
          }

          self.restoring = false
          self.ready = finished
          self.container.controller.showsPlaybackControls = finished

          if finished && self.resumePlayback {
            self.resumePlayback = false
            self.player.play()
          }
        }
      }
    }
  }

  let duration = item.duration.seconds
  let position = player.currentTime().seconds

  return [
    "ready": ready,
    "positionSec": position.isFinite ? Int(max(0, position)) : 0,
    "durationSec": duration.isFinite ? Int(max(0, duration)) : 0,
    "playing": player.timeControlStatus == .playing
  ]
}

  private func replaceSource(
  _ args: Any?,
  result: FlutterResult
) {
  guard let values = args as? [String: Any],
        let address = values["url"] as? String,
        let url = URL(string: address),
        url.scheme == "http" || url.scheme == "https" else {
    result(
      FlutterError(
        code: "invalid_url",
        message: "Invalid video URL",
        details: nil
      )
    )
    return
  }

  let position = player.currentTime().seconds

  if position.isFinite {
    startPosition = max(0, position)
  }

  resumePlayback = player.timeControlStatus != .paused
  sourceVersion += 1

  player.pause()

  ready = false
  restoring = false
  container.controller.showsPlaybackControls = false

  // Сохраняем существующие AVPlayer и AVPlayerViewController.
  player.replaceCurrentItem(with: AVPlayerItem(url: url))

  result(nil)
  }

  private func close() {
    guard !disposed else {
      return
    }

    disposed = true
    sourceVersion += 1
    channel.setMethodCallHandler(nil)

    player.pause()
    container.detach()
    container.controller.player = nil
    player.replaceCurrentItem(with: nil)
  }

  deinit {
    close()
  }
}

final class NativePlayerContainer: UIView {
  let controller = AVPlayerViewController()

  override init(frame: CGRect) {
    super.init(frame: frame)
    backgroundColor = .black
  }

  required init?(coder: NSCoder) {
    fatalError("init(coder:) is not supported")
  }

  override func didMoveToWindow() {
    super.didMoveToWindow()

    guard window != nil, controller.parent == nil else {
      return
    }

    // Подключаем AVPlayerViewController как дочерний контроллер.
    // Это необходимо для штатного fullscreen.
    var responder: UIResponder? = next

    while let current = responder {
      if let parent = current as? UIViewController {
        parent.addChild(controller)

        controller.view.frame = bounds
        controller.view.autoresizingMask = [
          .flexibleWidth,
          .flexibleHeight
        ]

        addSubview(controller.view)
        controller.didMove(toParent: parent)
        return
      }

      responder = current.next
    }
  }

  override func layoutSubviews() {
    super.layoutSubviews()

    if controller.view.superview === self {
      controller.view.frame = bounds
    }
  }

  func detach() {
    if controller.presentedViewController != nil {
      controller.dismiss(animated: false)
    }

    controller.willMove(toParent: nil)
    controller.view.removeFromSuperview()
    controller.removeFromParent()
  }
}
