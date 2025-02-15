//
//  ContentView.swift
//  BarTuner
//
//  Created by s1xu on 2025/2/14.
//

import SwiftUI
import AppKit



struct ContentView: View {
    @State private var spacingValue: Int = 16
    @State private var showPermissionAlert = false

    var body: some View {
        VStack {
            Text("Menu Tuner")
                .font(.title)

            Slider(value: Binding<Double>(
                get: { Double(spacingValue) },
                set: { newValue in
                    spacingValue = Int(newValue)
                    print("Slider value changed to: \(spacingValue)")
                    applySettings()
                }
            ), in: 0...32, step: 1)

            Text("Current spacing: \(spacingValue)")

            Button("Restore Defaults") {
                spacingValue = 16
                applySettings()
            }
        }
        .padding()
        .frame(width: 400, height: 200)
        .onAppear {
            checkFullDiskAccess { hasPermission in
                guard hasPermission else {
                    showPermissionAlert = true
                    return
                }
                loadCurrentSettings()
            }
        }
        .alert("需要完全磁盘访问权限", isPresented: $showPermissionAlert) {
            Button("打开设置") {
                openSecurityPreferences()
            }
            Button("取消", role: .cancel) {}
        } message: {
            Text("请前往系统偏好设置 → 安全性与隐私 → 完全磁盘访问，并添加本应用到权限列表")
        }
        .onDisappear {
            NSApp.terminate(nil)
        }
    }

    private func checkFullDiskAccess(completion: @escaping (Bool) -> Void) {
        let protectedPath = NSHomeDirectory().appending("/Library/Preferences/.TestWriteAccess")

        do {
            try "test".write(toFile: protectedPath, atomically: true, encoding: .utf8)
            try FileManager.default.removeItem(atPath: protectedPath)
            completion(true)
        } catch {
            print("权限检测失败: \(error.localizedDescription)")
            completion(false)
        }
    }

    private func openSecurityPreferences() {
        let url = URL(string: "x-apple.systempreferences:com.apple.preference.security?Privacy_AllFiles")!
        NSWorkspace.shared.open(url)
    }

    private func loadCurrentSettings() {
        let spacing = shell("defaults -currentHost read -globalDomain NSStatusItemSpacing") ?? "16"
        spacingValue = Int(spacing) ?? 16
    }

    private func applySettings() {
        let defaultsCommand1 = "defaults -currentHost write -globalDomain NSStatusItemSpacing -int \(spacingValue)"
        let defaultsCommand2 = "defaults -currentHost write -globalDomain NSStatusItemSelectionPadding -int \(spacingValue)"
        let killCommands = ["killall ControlCenter", "killall SystemUIServer"]

        shell(defaultsCommand1)
        shell(defaultsCommand2)
        killCommands.forEach { shell($0) }
    }

    private func shell(_ command: String) -> String? {
        let task = Process()
        let pipe = Pipe()

        task.standardOutput = pipe
        task.arguments = ["-c", command]
        task.launchPath = "/bin/zsh"

        do {
            try task.run()
            let data = pipe.fileHandleForReading.readDataToEndOfFile()
            return String(data: data, encoding: .utf8)?.trimmingCharacters(in: .whitespacesAndNewlines)
        } catch {
            print("执行命令失败: \(error.localizedDescription)")
            return nil
        }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
