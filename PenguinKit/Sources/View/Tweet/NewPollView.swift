//
//  NewPollView.swift
//

import Sweet
import SwiftUI

struct NewPollView: View {
  @Binding var options: [String]
  @Binding var duration: TimeInterval
  @State var isPresentedDatePicker = false

  var displayDate: String {
    let dateFormatter = DateComponentsFormatter()
    dateFormatter.unitsStyle = .abbreviated
    dateFormatter.allowedUnits = [.hour, .minute]
    let dateString = dateFormatter.string(from: duration)!
    return dateString
  }

  var body: some View {
    VStack {
      ForEach($options.indices, id: \.self) { index in
        HStack {
          TextField("Answer \(index + 1) \(index < 2 ? "" : "(Optional)")", text: $options[index])
            .textFieldStyle(.roundedBorder)

          let isLast = index == options.count - 1

          Button(
            action: {
              if isLast {
                options.append("")
              } else {
                options.remove(at: index)
              }
            },
            label: {
              Image(systemName: isLast ? "plus.app" : "minus.square")
            }
          )
        }
      }

      Button(
        action: {
          isPresentedDatePicker.toggle()
        },
        label: {
          HStack {
            Text("Vote Duration")
            Spacer()
            Text(displayDate)
            Image(systemName: isPresentedDatePicker ? "chevron.up" : "chevron.down")
          }
        }
      )
      if isPresentedDatePicker {
        DurationPicker(duration: $duration)
      }
    }
  }
}

struct NewPollView_Previews: PreviewProvider {
  @State static var options: [String] = ["", ""]
  @State static var duration: TimeInterval = 10 * 60

  static var previews: some View {
    NewPollView(options: $options, duration: $duration)
  }
}
