/*
 * Copyright (c) 2016, Nordic Semiconductor
 * All rights reserved.
 *
 * Redistribution and use in source and binary forms, with or without modification, are permitted provided that the following conditions are met:
 *
 * 1. Redistributions of source code must retain the above copyright notice, this list of conditions and the following disclaimer.
 *
 * 2. Redistributions in binary form must reproduce the above copyright notice, this list of conditions and the following disclaimer in the
 * documentation and/or other materials provided with the distribution.
 *
 * 3. Neither the name of the copyright holder nor the names of its contributors may be used to endorse or promote products derived from this
 * software without specific prior written permission.
 *
 * THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS" AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT
 * LIMITED TO, THE IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT
 * HOLDER OR CONTRIBUTORS BE LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT
 * LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND ON
 * ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE
 * USE OF THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
 */

import CoreBluetooth

final class PeripheralProxy : NSObject {
  ///
  weak var delegate: CBPeripheralDelegate?

  ///
  weak var receiver: PeripheralProxyReceiver?

  ///
  weak var peripheral: CBPeripheral?

  ///
  init(route peripheral: CBPeripheral) {
    self.peripheral = peripheral
    delegate = peripheral.delegate
    print("❇️", String(format: "PeripheralProxy<%p>", self))
  }

  ///
  func link(_ receiver: PeripheralProxyReceiver, to peripheral: CBPeripheral) {
    // If there is a connection to this object remove it
    if self.receiver?.peripheralProxy === self {
      self.receiver?.peripheralProxy = nil
    }
    print("1️⃣✅", receiver)
    // Assign caller to self
    self.receiver = receiver
    // Create a new connection
    receiver.peripheralProxy = self
    // Link the delegation to self
    print("3️⃣✅")
    peripheral.delegate = self
    print("4️⃣✅", self)
  }

  ///
  func unlink(from peripheral: CBPeripheral) {
    // The peripheral must be linked to self
    guard
      peripheral.delegate === self
    else { return print("❎", peripheral.delegate) }
    // Re-assign the old delegate back to the peripheral
    peripheral.delegate = delegate
    print("1️⃣❎", peripheral.delegate)

    // Remove self from the receiver
    receiver?.peripheralProxy = nil
    print("2️⃣❎", receiver?.peripheralProxy)
    // Remove any connections
    delegate = nil
    receiver = nil
    print("3️⃣❎", delegate, receiver)
  }

  ///
  deinit {
    print(
      """
      🚸 deallocating \(String(format: "PeripheralProxy<%p>", self))
      Delegate: \(delegate as Any)
      Receiver: \(receiver as Any)
      """
    )
    peripheral.map(unlink(from:))
  }
}

extension PeripheralProxy : CBPeripheralDelegate {
  /// Helper computed propery
  private var delegates: [CBPeripheralDelegate] {
    return [delegate, receiver].compactMap { $0 }
  }

  ///
  func peripheralDidUpdateName(_ peripheral: CBPeripheral) {
    delegates.forEach { $0.peripheralDidUpdateName?(peripheral) }
  }

  ///
  func peripheral(
    _ peripheral: CBPeripheral,
    didModifyServices invalidatedServices: [CBService]
  ) {
    delegates.forEach {
      $0.peripheral?(peripheral, didModifyServices: invalidatedServices)
    }
  }

  ///
  func peripheral(
    _ peripheral: CBPeripheral,
    didReadRSSI RSSI: NSNumber, error: Error?
  ) {
    delegates.forEach {
      $0.peripheral?(peripheral, didReadRSSI: RSSI, error: error)
    }
  }

  ///
  func peripheral(
    _ peripheral: CBPeripheral,
    didDiscoverServices error: Error?
  ) {
    delegates.forEach {
      $0.peripheral?(peripheral, didDiscoverServices: error)
    }
  }

  ///
  func peripheral(
    _ peripheral: CBPeripheral,
    didDiscoverIncludedServicesFor service: CBService, error: Error?
  ) {
    delegates.forEach {
      $0.peripheral?(
        peripheral,
        didDiscoverIncludedServicesFor: service,
        error: error
      )
    }
  }

  ///
  func peripheral(
    _ peripheral: CBPeripheral,
    didDiscoverCharacteristicsFor service: CBService,
    error: Error?
  ) {
    delegates.forEach {
      $0.peripheral?(
        peripheral,
        didDiscoverCharacteristicsFor: service,
        error: error
      )
    }
  }

  ///
  func peripheral(
    _ peripheral: CBPeripheral,
    didUpdateValueFor characteristic: CBCharacteristic,
    error: Error?
  ) {
    delegates.forEach {
      $0.peripheral?(
        peripheral,
        didUpdateValueFor: characteristic,
        error: error
      )
    }
  }

  ///
  func peripheral(
    _ peripheral: CBPeripheral,
    didWriteValueFor characteristic: CBCharacteristic,
    error: Error?
  ) {
    delegates.forEach {
      $0.peripheral?(peripheral, didWriteValueFor: characteristic, error: error)
    }
  }

  ///
  func peripheral(
    _ peripheral: CBPeripheral,
    didUpdateNotificationStateFor characteristic: CBCharacteristic,
    error: Error?
  ) {
    delegates.forEach {
      $0.peripheral?(
        peripheral,
        didUpdateNotificationStateFor: characteristic,
        error: error
      )
    }
  }

  ///
  func peripheral(
    _ peripheral: CBPeripheral,
    didDiscoverDescriptorsFor characteristic: CBCharacteristic,
    error: Error?
  ) {
    delegates.forEach {
      $0.peripheral?(
        peripheral,
        didDiscoverDescriptorsFor: characteristic,
        error: error
      )
    }
  }

  ///
  func peripheral(
    _ peripheral: CBPeripheral,
    didUpdateValueFor descriptor: CBDescriptor,
    error: Error?
  ) {
    delegates.forEach {
      $0.peripheral?(peripheral, didUpdateValueFor: descriptor, error: error)
    }
  }

  ///
  func peripheral(
    _ peripheral: CBPeripheral,
    didWriteValueFor descriptor: CBDescriptor,
    error: Error?
  ) {
    delegates.forEach {
      $0.peripheral?(peripheral, didWriteValueFor: descriptor, error: error)
    }
  }

  ///
  func peripheralIsReady(toSendWriteWithoutResponse peripheral: CBPeripheral) {
    delegates.forEach {
      $0.peripheralIsReady?(toSendWriteWithoutResponse: peripheral)
    }
  }

  ///
  @available(iOS 11.0, *)
  func peripheral(
    _ peripheral: CBPeripheral,
    didOpen channel: CBL2CAPChannel?,
    error: Error?
  ) {
    delegates.forEach {
      $0.peripheral?(peripheral, didOpen: channel, error: error)
    }
  }
}
