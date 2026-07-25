import IOBluetooth

fileprivate enum AirPodsBluetoothPID: UInt16 {
    case gen1 = 0x2002
    case gen2 = 0x200F
    case gen3 = 0x2013
    case gen4 = 0x201B
    case max1 = 0x200A
    case max1UsbC = 0x201F
    case max2 = 0x202D
    case pro1 = 0x200E
    case pro2 = 0x2014
    case pro2UsbC = 0x2024
    case pro3 = 0x202F
}

fileprivate let unsupportedRegularAirPodsModels: Set<AirPodsBluetoothPID> = [.gen1, .gen2]
fileprivate let regularAirPodsModels: Set<AirPodsBluetoothPID> = [.gen3, .gen4]
fileprivate let airpodsMaxModels: Set<AirPodsBluetoothPID> = [.max1, .max1UsbC, .max2]
fileprivate let airpodsProModels: Set<AirPodsBluetoothPID> = [.pro1, .pro2, .pro2UsbC, .pro3]

enum AirPodsModel {
    case unsupportedRegular // Gen 1, Gen 2
    case regular // Gen 3, Gen 4
    case pro
    case max
}

private final class SDPQuery: NSObject {
    private var continuation: CheckedContinuation<Bool, Never>?

    func perform(on device: IOBluetoothDevice) async -> Bool {
        await withCheckedContinuation { continuation in
            self.continuation = continuation

            let status = device.performSDPQuery(self)
            if status != kIOReturnSuccess {
                complete(with: status)
            }
        }
    }

    @objc func sdpQueryComplete(_ device: IOBluetoothDevice, status: IOReturn) {
        complete(with: status)
    }

    private func complete(with status: IOReturn) {
        guard let continuation else { return }
        self.continuation = nil
        continuation.resume(returning: status == kIOReturnSuccess)
    }
}

func getConnectedAirPods() async -> Set<AirPodsModel> {
    guard let pairedDevices = IOBluetoothDevice.pairedDevices() as? [IOBluetoothDevice] else { return [] }
    var models: Set<AirPodsModel> = []

    for device in pairedDevices where device.isConnected() {
        guard
            await SDPQuery().perform(on: device),
            let record = device.getServiceRecord(for: IOBluetoothSDPUUID(uuid16: 0x1200)),
            let vendorID = record.getAttributeDataElement(0x0201)?.getNumberValue()?.uint16Value,
            vendorID == 0x004C,
            let productID = record.getAttributeDataElement(0x0202)?.getNumberValue()?.uint16Value
        else { continue }

        guard let model = AirPodsBluetoothPID(rawValue: productID) else { continue }
        
        if unsupportedRegularAirPodsModels.contains(model) { models.insert(.unsupportedRegular) }
        else if regularAirPodsModels.contains(model) { models.insert(.regular) }
        else if airpodsMaxModels.contains(model) { models.insert(.max) }
        else if airpodsProModels.contains(model) { models.insert(.pro) }
    }

    return models
}
