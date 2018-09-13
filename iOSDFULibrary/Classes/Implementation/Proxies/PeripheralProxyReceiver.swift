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

protocol PeripheralProxyReceiver : CBPeripheralDelegate {
  //
  var peripheralProxy: PeripheralProxy? { get set }

  //
  func link(to peripheral: CBPeripheral)

  //
  func unlink(from peripheral: CBPeripheral)
}

extension PeripheralProxyReceiver {
  //
  func link(to peripheral: CBPeripheral) {
    if let proxy = peripheral.delegate as? PeripheralProxy {
      proxy.link(self, to: peripheral)
    } else if let proxy = peripheralProxy {
      proxy.link(self, to: peripheral)
    } else {
      let proxy = PeripheralProxy(route: peripheral)
      proxy.link(self, to: peripheral)
    }
  }

  //
  func unlink(from peripheral: CBPeripheral) {
    precondition(
      peripheral.delegate !== self &&
      peripheral.delegate as? Self == nil,
      "Something linked this or a similar object directly to the peripheral."
    )
    guard
      let proxy = peripheral.delegate as? PeripheralProxy,
      proxy.receiver === self
    else { return }
    // Unlink the proxy
    proxy.unlink(from: peripheral)
    // Remove the object if possible
    if peripheralProxy === proxy {
      peripheralProxy = nil
    }
    precondition(
      peripheralProxy == nil,
      "Peripheral proxy still set on \(self)."
    )
  }
}
