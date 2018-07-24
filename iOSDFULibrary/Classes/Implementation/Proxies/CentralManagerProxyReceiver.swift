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

protocol CentralManagerProxyReceiver : CBCentralManagerDelegate {
  //
  var centralManagerProxy: CentralManagerProxy? { get set }

  //
  func link(to manager: CBCentralManager)

  //
  func unlink(from manager: CBCentralManager)
}

extension CentralManagerProxyReceiver {
  //
  func link(to manager: CBCentralManager) {
    if let proxy = manager.delegate as? CentralManagerProxy {
      proxy.link(self, to: manager)
    } else if let proxy = centralManagerProxy {
      proxy.link(self, to: manager)
    } else {
      let proxy = CentralManagerProxy(route: manager)
      proxy.link(self, to: manager)
    }
  }

  //
  func unlink(from manager: CBCentralManager) {
    precondition(
      manager.delegate !== self &&
      manager.delegate as? Self == nil,
      """
      Something linked this or a similar object directly \
      to the CentralManager.
      """
    )
    guard
      let proxy = manager.delegate as? CentralManagerProxy,
      proxy.receiver === self
    else { return }
    // Unlink the proxy
    proxy.unlink(from: manager)
    // Remove the object if possible
    if centralManagerProxy === proxy {
      centralManagerProxy = nil
    }
    precondition(
      centralManagerProxy == nil,
      "CentralManager proxy still set on \(self)."
    )
  }
}
