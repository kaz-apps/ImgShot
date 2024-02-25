import SwiftUI

class ScreenshotManager: ObservableObject {
	@Published var screenshots: [NSImage] = []
	
	func addScreenshot(_ screenshot: NSImage) {
		screenshots.append(screenshot)
	}
}

struct ContentView: View {
	@StateObject private var screenshotManager = ScreenshotManager()
	
	var body: some View {
		ScrollView {
			ZStack {
				// 背景をブルーに設定
				Color.blue.edgesIgnoringSafeArea(.all)
				
				ScrollView {
					VStack {
						
						// タイトル
						Text("ImgShot")
							.padding()
							.font(.largeTitle)
							.foregroundColor(.white)
						
						// テキストボックス
						Text("スクリーンショットを保存して後から見返すことのできるアプリです。デザインの参考集めに活用してみてください。Cmd + shift + Sでスクショを保存してみましょう。")
							.padding()
							.frame(maxWidth: .infinity)
							.background(Color.white)
							.cornerRadius(10)
							.foregroundColor(.blue)
							.padding()
						
						ForEach(screenshotManager.screenshots, id: \.self) { screenshot in
							ScreenshotCard(image: Image(nsImage: screenshot))
								.padding()
						}
					}
				}
			}
		}
		.onAppear(perform: setupLocalKeyMonitor) // ここを追加
	}
	
	private func setupLocalKeyMonitor() {
		NSEvent.addLocalMonitorForEvents(matching: .keyDown) { event in
			if event.modifierFlags.contains([.command, .shift]), event.keyCode == 0x01 {
				self.takeScreenshot()
				return nil
			}
			return event
		}
	}
	
	private func takeScreenshot() {
		let task = Process()
		task.launchPath = "/usr/sbin/screencapture"
		
		let dateFormatter = DateFormatter()
		dateFormatter.dateFormat = "yyyyMMddHHmmss"
		let timeStamp = dateFormatter.string(from: Date())
		
		let tmpPath = NSTemporaryDirectory().appending("screenshot_\(timeStamp).png")
		task.arguments = ["-i", tmpPath]
		
		task.terminationHandler = { process in
			DispatchQueue.main.async {
				if let image = NSImage(contentsOfFile: tmpPath) {
					self.screenshotManager.addScreenshot(image)
					try? FileManager.default.removeItem(atPath: tmpPath)
				}
			}
		}
		
		task.launch()
	}
	
	
	struct ScreenshotCard: View {
		var image: Image
		
		var body: some View {
			image
				.resizable()
				.aspectRatio(contentMode: .fill)
				.frame(width: 300, height: 200)
				.clipped()
				.cornerRadius(10)
				.shadow(radius: 5)
				.overlay(
					RoundedRectangle(cornerRadius: 10)
						.stroke(Color.gray, lineWidth: 1)
				)
		}
	}
}
