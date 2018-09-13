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

final class CentralManagerProxy : NSObject {
  ///
  weak var delegate: CBCentralManagerDelegate?

  ///
  weak var receiver: CentralManagerProxyReceiver?

  ///
  weak var manager: CBCentralManager?

  ///
  init(route manager: CBCentralManager) {
    self.manager = manager
    delegate = manager.delegate
    super.init()
  }

  ///
  func link(
    _ receiver: CentralManagerProxyReceiver,
    to manager: CBCentralManager
  ) {
    // If there is a connection to this object remove it
    if self.receiver?.centralManagerProxy === self {
      self.receiver?.centralManagerProxy = nil
    }
    // Assign caller to self
    self.receiver = receiver
    // Create a new connection
    receiver.centralManagerProxy = self
    // Link the delegation to self
    manager.delegate = self
  }

  ///
  func unlink(from manager: CBCentralManager) {
    // The manager must be linked to self or the delegate is must be nil
    guard
      manager.delegate === self || manager.delegate === nil
    else { return }
    // Re-assign the old delegate back to the peripheral
    manager.delegate = delegate
    // Remove self from the receiver
    receiver?.centralManagerProxy = nil
    // Remove any connections
    delegate = nil
    receiver = nil
  }

  ///
  deinit {
    print(
      """
      CentralManagerProxy will be deallocated.
      Delegate: \(delegate as Any)
      Receiver: \(receiver as Any)
      """
    )
    manager.map(unlink(from:))
  }
}

extension CentralManagerProxy : CBCentralManagerDelegate {
  /// Helper computed propery
  private var delegates: [CBCentralManagerDelegate] {
    return [delegate, receiver].compactMap { $0 }
  }

  func centralManagerDidUpdateState(_ central: CBCentralManager) {
    delegates.forEach { $0.centralManagerDidUpdateState(central) }
  }

  ///
  func centralManager(
    _ central: CBCentralManager,
    willRestoreState dict: [String : Any]
  ) {
    delegates.forEach { $0.centralManager?(central, willRestoreState: dict) }
  }

  ///
  func centralManager(
    _ central: CBCentralManager,
    didDiscover peripheral: CBPeripheral,
    advertisementData: [String : Any],
    rssi RSSI: NSNumber
  ) {
    delegates.forEach {
      $0.centralManager?(
        central,
        didDiscover: peripheral,
        advertisementData: advertisementData,
        rssi: RSSI
      )
    }
  }

  ///
  func centralManager(
    _ central: CBCentralManager,
    didConnect peripheral: CBPeripheral
  ) {
    delegates.forEach { $0.centralManager?(central, didConnect: peripheral) }
  }

  ///
  func centralManager(
    _ central: CBCentralManager,
    didFailToConnect peripheral: CBPeripheral,
    error: Error?
  ) {
    delegates.forEach {
      $0.centralManager?(central, didFailToConnect: peripheral, error: error)
    }
  }

  ///
  func centralManager(
    _ central: CBCentralManager,
    didDisconnectPeripheral peripheral: CBPeripheral,
    error: Error?
  ) {
    delegates.forEach {
      $0.centralManager?(
        central,
        didDisconnectPeripheral: peripheral,
        error: error
      )
    }
  }
}
