// Reads the standard BLE Battery Service (0x180F) of every connected
// Bluetooth device that has one and prints "<name>|<percent>" per device.
// macOS doesn't surface this for many third party keyboards (e.g. RT65).
import CoreBluetooth
import Foundation

let batteryService = CBUUID(string: "180F")
let batteryLevel = CBUUID(string: "2A19")
let hidService = CBUUID(string: "1812")

class Reader: NSObject, CBCentralManagerDelegate, CBPeripheralDelegate {
  var central: CBCentralManager!
  var pending = [CBPeripheral]()

  override init() {
    super.init()
    central = CBCentralManager(delegate: self, queue: nil)
  }

  func done(_ p: CBPeripheral) {
    pending.removeAll { $0 == p }
    if pending.isEmpty { exit(0) }
  }

  func centralManagerDidUpdateState(_ c: CBCentralManager) {
    guard c.state == .poweredOn else {
      if c.state != .unknown && c.state != .resetting { exit(1) }
      return
    }
    pending = c.retrieveConnectedPeripherals(withServices: [batteryService, hidService])
    if pending.isEmpty { exit(0) }
    for p in pending {
      p.delegate = self
      c.connect(p)
    }
  }

  func centralManager(_ c: CBCentralManager, didConnect p: CBPeripheral) {
    p.discoverServices([batteryService])
  }

  func centralManager(_ c: CBCentralManager, didFailToConnect p: CBPeripheral, error: Error?) {
    done(p)
  }

  func peripheral(_ p: CBPeripheral, didDiscoverServices error: Error?) {
    guard let service = p.services?.first(where: { $0.uuid == batteryService }) else { return done(p) }
    p.discoverCharacteristics([batteryLevel], for: service)
  }

  func peripheral(_ p: CBPeripheral, didDiscoverCharacteristicsFor s: CBService, error: Error?) {
    guard let ch = s.characteristics?.first(where: { $0.uuid == batteryLevel }) else { return done(p) }
    p.readValue(for: ch)
  }

  func peripheral(_ p: CBPeripheral, didUpdateValueFor ch: CBCharacteristic, error: Error?) {
    if let level = ch.value?.first { print("\(p.name ?? "?")|\(level)") }
    fflush(stdout)
    done(p)
  }
}

setvbuf(stdout, nil, _IOLBF, 0)
let reader = Reader()
RunLoop.main.run(until: Date().addingTimeInterval(5))
