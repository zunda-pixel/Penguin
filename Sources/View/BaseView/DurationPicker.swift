//
//  DurationPicker.swift
//

import SwiftUI

struct DurationPicker: ViewRepresentable {
  @Binding var duration: TimeInterval

  #if os(macOS)
    func makeCoordinator() -> Coordinator {
      Coordinator(self)
    }

    func makeNSView(context: Context) -> NSDatePicker {
      let datePicker = NSDatePicker()
      datePicker.datePickerMode = .range
      return datePicker
    }

    func updateNSView(_ datePicker: NSDatePicker, context: Context) {
    }
  #else
    func makeUIView(context: Context) -> UIDatePicker {
      let datePicker = UIDatePicker()
      datePicker.datePickerMode = .countDownTimer
      datePicker.addTarget(
        context.coordinator,
        action: #selector(Coordinator.updateDuration),
        for: .valueChanged
      )
      return datePicker
    }

    func updateUIView(_ datePicker: UIDatePicker, context: Context) {
      datePicker.countDownDuration = duration
    }

    func makeCoordinator() -> Coordinator {
      Coordinator(self)
    }
  #endif

  class Coordinator: NSObject {
    let parent: DurationPicker

    init(_ parent: DurationPicker) {
      self.parent = parent
    }

    #if !os(macOS)
      @MainActor @objc func updateDuration(datePicker: UIDatePicker) {
        parent.duration = datePicker.countDownDuration
      }
    #endif
  }
}

struct DurationPicker_Previews: PreviewProvider {
  @State static var timeInterval: TimeInterval = 0

  static var previews: some View {
    DurationPicker(duration: $timeInterval)
  }
}
